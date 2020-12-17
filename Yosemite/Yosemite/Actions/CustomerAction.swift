import Foundation

/// CustomerAction: Defines all of the Actions supported by the CustomerStore.
///
public enum CustomerAction: Action {

    /// Creates a new Customer for the provided siteID
    ///
    case createCustomer(siteID: Int64, customer: Customer, completion: (Result<Customer, Error>) -> Void)

    /// Synchronizes all customers for the provided siteID
    ///
    case synchronizeAllCustomers(siteID: Int64, completion: (Result<Void, Error>) -> Void)
}