import XCTest
@testable import Yosemite
@testable import Networking
@testable import Storage
@testable import Hardware

/// CardPresentPaymentStore Unit Tests
///
/// All mock properties are necessary because
/// CardPresentPaymentStore extends Store.
final class CardPresentPaymentStoreTests: XCTestCase {
    /// Mock Dispatcher!
    ///
    private var dispatcher: Dispatcher!

    /// Mock Storage: InMemory
    ///
    private var storageManager: MockStorageManager!

    /// Mock Network: Allows us to inject predefined responses!
    ///
    private var network: MockNetwork!

    /// Convenience Property: Returns the StorageType associated with the main thread.
    ///
    private var viewStorage: StorageType {
        return storageManager.viewStorage
    }

    /// Mock Card Reader Service: In memory
    private var mockCardReaderService: MockCardReaderService!

    override func setUp() {
        super.setUp()
        dispatcher = Dispatcher()
        storageManager = MockStorageManager()
        network = MockNetwork()
        mockCardReaderService = MockCardReaderService()
    }

    override func tearDown() {
        dispatcher = nil
        storageManager = nil
        network = nil
        mockCardReaderService = nil

        super.tearDown()
    }

    // MARK: - CardPresentPaymentAction.startCardReaderDiscovery

    /// Verifies that CardPresentPaymentAction.startCardReaderDiscovery hits the `start` method in the service.
    ///
    func test_start_discovery_action_hits_start_in_service() {
        let cardPresentStore = CardPresentPaymentStore(dispatcher: dispatcher,
                                                       storageManager: storageManager,
                                                       network: network,
                                                       cardReaderService: mockCardReaderService)

        let action = CardPresentPaymentAction.startCardReaderDiscovery { discoveredReaders in
            //
        }

        cardPresentStore.onAction(action)

        XCTAssertTrue(mockCardReaderService.didHitStart)
    }

    func test_start_discovery_action_returns_data_eventually() {
        let cardPresentStore = CardPresentPaymentStore(dispatcher: dispatcher,
                                                       storageManager: storageManager,
                                                       network: network,
                                                       cardReaderService: mockCardReaderService)

        let expectation = self.expectation(description: "Readers discovered")

        let action = CardPresentPaymentAction.startCardReaderDiscovery { discoveredReaders in
            expectation.fulfill()
        }

        cardPresentStore.onAction(action)

        wait(for: [expectation], timeout: Constants.expectationTimeout)
    }

    func test_connect_to_reader_action_updates_returns_provided_reader_on_success() {
        let cardPresentStore = CardPresentPaymentStore(dispatcher: dispatcher,
                                                       storageManager: storageManager,
                                                       network: network,
                                                       cardReaderService: mockCardReaderService)

        let expectation = self.expectation(description: "Connect to card reader")

        let reader = MockCardReader.bbposChipper2XBT()
        let action = CardPresentPaymentAction.connect(reader: reader) { result in
            switch result {
            case .failure:
                XCTFail()
            case .success(let connectedReaders):
                // This could be called with an empty collection of readers.
                // So we do not make the test fail if connectedReaders is Empty
                guard !connectedReaders.isEmpty else {
                    return
                }

                XCTAssertTrue(connectedReaders.contains(reader))

                expectation.fulfill()
            }
        }

        cardPresentStore.onAction(action)

        wait(for: [expectation], timeout: Constants.expectationTimeout)
    }
}