import Storage
import Hardware
import Networking
import Combine

/// MARK: CardPresentPaymentStore
///
public final class CardPresentPaymentStore: Store {
    // Retaining the reference to the card reader service might end up being problematic.
    // At this point though, the ServiceLocator is part of the WooCommerce binary, so this is a good starting point.
    // If retaining the service here ended up being a problem, we would need to move this Store out of Yosemite and push it up to WooCommerce.
    private let cardReaderService: CardReaderService

    private let remote: WCPayRemote

    private var cancellables: Set<AnyCancellable> = []

    public init(dispatcher: Dispatcher, storageManager: StorageManagerType, network: Network, cardReaderService: CardReaderService) {
        self.cardReaderService = cardReaderService
        self.remote = WCPayRemote(network: network)
        super.init(dispatcher: dispatcher, storageManager: storageManager, network: network)
    }

    /// Registers for supported Actions.
    ///
    override public func registerSupportedActions(in dispatcher: Dispatcher) {
        dispatcher.register(processor: self, for: CardPresentPaymentAction.self)
    }

    /// Receives and executes Actions.
    ///
    override public func onAction(_ action: Action) {
        guard let action = action as? CardPresentPaymentAction else {
            assertionFailure("\(String(describing: self)) received an unsupported action")
            return
        }

        switch action {
        case .startCardReaderDiscovery(let siteID, let completion):
            startCardReaderDiscovery(siteID: siteID, completion: completion)
        case .cancelCardReaderDiscovery(let completion):
            cancelCardReaderDiscovery(completion: completion)
        case .connect(let reader, let completion):
            connect(reader: reader, onCompletion: completion)
        case .observeKnownReaders(let completion):
            observeKnownReaders(onCompletion: completion)
        case .observeConnectedReaders(let completion):
            observeConnectedReaders(onCompletion: completion)
        case .collectPayment(let siteID, let orderID, let parameters, let event, let completion):
            collectPayment(siteID: siteID,
                           orderID: orderID,
                           parameters: parameters,
                           onCardReaderMessage: event,
                           onCompletion: completion)
        case .checkForCardReaderUpdate(onData: let data, onCompletion: let completion):
            checkForCardReaderUpdate(onData: data, onCompletion: completion)
        case .startCardReaderUpdate(onProgress: let progress, onCompletion: let completion):
            startCardReaderUpdate(onProgress: progress, onCompletion: completion)
        }
    }
}


// MARK: - Services
//
private extension CardPresentPaymentStore {
    func startCardReaderDiscovery(siteID: Int64, completion: @escaping (_ readers: [CardReader]) -> Void) {
        cardReaderService.start(WCPayTokenProvider(siteID: siteID, remote: self.remote))

        // Over simplification. This is the point where we would receive
        // new data via the CardReaderService's stream of discovered readers
        // In here, we should redirect that data to Storage and also up to the UI.
        // For now we are sending the data up to the UI directly
        cardReaderService.discoveredReaders.sink { readers in
            completion(readers)
        }.store(in: &cancellables)
    }

    func cancelCardReaderDiscovery(completion: @escaping (CardReaderServiceDiscoveryStatus) -> Void) {
        cardReaderService.discoveryStatus.sink { status in
            completion(status)
        }.store(in: &cancellables)

        cardReaderService.cancelDiscovery()
    }

    func connect(reader: Yosemite.CardReader, onCompletion: @escaping (Result<[Yosemite.CardReader], Error>) -> Void) {
        // We tiptoe around this for now. We will get into error handling later:
        // https://github.com/woocommerce/woocommerce-ios/issues/3734
        // https://github.com/woocommerce/woocommerce-ios/issues/3741
        cardReaderService.connect(reader).sink(receiveCompletion: { error in
        }, receiveValue: { (result) in
        }).store(in: &cancellables)

        // Dispatch completion block everytime the service published a new
        // collection of connected readers
        cardReaderService.connectedReaders.sink { connectedHardwareReaders in
            onCompletion(.success(connectedHardwareReaders))
        }.store(in: &cancellables)
    }

    /// Calls the completion block everytime the list of known readers changes
    ///
    func observeKnownReaders(onCompletion: @escaping ([Yosemite.CardReader]) -> Void) {
        // TODO: Hook up to storage (see #3559) - for now, we return an empty array
        onCompletion([])
    }

    /// Calls the completion block everytime the list of connected readers changes
    ///
    func observeConnectedReaders(onCompletion: @escaping ([Yosemite.CardReader]) -> Void) {
        cardReaderService.connectedReaders.sink { _ in
        } receiveValue: { readers in
            onCompletion(readers)
        }.store(in: &cancellables)
    }

    func collectPayment(siteID: Int64,
                        orderID: Int64,
                        parameters: PaymentParameters,
                        onCardReaderMessage: @escaping (CardReaderEvent) -> Void,
                        onCompletion: @escaping (Result<CardPresentReceiptParameters, Error>) -> Void) {
        cardReaderService.capturePayment(parameters).sink { error in
            switch error {
            case .failure(let error):
                onCompletion(.failure(error))
            default:
                break
            }
        } receiveValue: { intent in
            // A this point, the status of the PaymentIntent should be `requiresCapture`:
            // https://stripe.dev/stripe-terminal-ios/docs/Enums/SCPPaymentIntentStatus.html#/c:@E@SCPPaymentIntentStatus@SCPPaymentIntentStatusRequiresCapture
            // TODO. Persist PaymentIntent, so that we can use it later to print a receipt.
            // Persisting an instance of ReceiptParameters might be a better option.
            // Deferred to https://github.com/woocommerce/woocommerce-ios/issues/3825
            guard let receiptParameters = intent.receiptParameters() else {
                let error = CardReaderServiceError.paymentCapture()

                DDLogError("⛔️ Payment completed without valid regulatory metadata: \(error)")

                onCompletion(.failure(error))
                return
            }

            // Once ReceiptParameters is persisted, we would not propagate it out
            onCompletion(.success(receiptParameters))

            // Note: Here we transition from the Stripe Terminal Payment Intent
            // to the WCPay backend managed Payment Intent, which we need
            // to use to capture the payment.
            // This is always failing at this point. Commented out for now.
            self.remote.captureOrderPayment(for: siteID, orderID: orderID, paymentIntentID: intent.id) { result in
                switch result {
                case .success(let intent):
                    guard intent.status == .succeeded else {
                        DDLogDebug("Unexpected payment intent status \(intent.status) after attempting capture")
                        onCompletion(.failure(CardReaderServiceError.paymentCapture()))
                        return
                    }
                    onCompletion(.success(receiptParameters))
                case .failure(let error):
                    onCompletion(.failure(error))
                    return
                }
            }
        }.store(in: &cancellables)

        // Observe status events fired by the card reader
        cardReaderService.readerEvents.sink { event in
            onCardReaderMessage(event)
        }.store(in: &cancellables)
    }

    func checkForCardReaderUpdate(onData: @escaping (Result<CardReaderSoftwareUpdate, Error>) -> Void,
                        onCompletion: @escaping () -> Void) {
        cardReaderService.checkForUpdate().sink(receiveCompletion: { value in
            switch value {
            case .failure(let error):
                onData(.failure(error))
            case .finished:
                onCompletion()
            }
        }, receiveValue: {softwareUpdate in
            onData(.success(softwareUpdate))
        }).store(in: &cancellables)
    }

    func startCardReaderUpdate(onProgress: @escaping (Float) -> Void,
                        onCompletion: @escaping (Result<Void, Error>) -> Void) {
        cardReaderService.installUpdate().sink(receiveCompletion: { value in
            switch value {
            case .failure(let error):
                onCompletion(.failure(error))
            case .finished:
                onCompletion(.success(()))
            }
        }, receiveValue: {
            onCompletion(.success(()))
        }).store(in: &cancellables)
        // Observe update progress events fired by the card reader
        cardReaderService.softwareUpdateEvents.sink { progress in
            onProgress(progress)
        }.store(in: &cancellables)
    }
}


/// Implementation of the CardReaderNetworkingAdapter
/// that fetches a token using WCPayRemote
private final class WCPayTokenProvider: CardReaderConfigProvider {
    private let siteID: Int64
    private let remote: WCPayRemote

    init(siteID: Int64, remote: WCPayRemote) {
        self.siteID = siteID
        self.remote = remote
    }

    func fetchToken(completion: @escaping(String?, Error?) -> Void) {
        remote.loadConnectionToken(for: siteID) { token, error in
            completion(token?.token, error)
        }
    }
}