
import Foundation
import Yosemite

/// Encapsulates data management for `OrdersTabbedViewController`.
///
final class OrdersTabbedViewModel {

    private lazy var storageManager = ServiceLocator.storageManager
    private lazy var stores = ServiceLocator.stores
    private lazy var sessionManager = stores.sessionManager

    /// ResultsController: Handles all things order status
    ///
    private lazy var statusResultsController: ResultsController<StorageOrderStatus> = {
        let descriptor = NSSortDescriptor(key: "slug", ascending: true)
        let predicate = NSPredicate(format: "siteID == %lld", siteID)
        return ResultsController<StorageOrderStatus>(storageManager: storageManager,
                                                     matching: predicate,
                                                     sortedBy: [descriptor])
    }()

    /// The current `Site` `siteID`.
    ///
    private let siteID: Int64

    init(siteID: Int64) {
        self.siteID = siteID
    }

    /// Start all the operations that this `ViewModel` is responsible for.
    ///
    /// This should only be called once in the lifetime of `OrdersTabbedViewController`.
    ///
    func activate() {
        try? statusResultsController.performFetch()
    }

    /// Fetch all `OrderStatus` from the API
    ///
    func syncOrderStatuses() {
        let action = OrderStatusAction.retrieveOrderStatuses(siteID: siteID) { result in
            if case let .failure(error) = result {
                DDLogError("⛔️ Order List — Error synchronizing order statuses: \(error)")
            }
        }

        stores.dispatch(action)
    }
}
