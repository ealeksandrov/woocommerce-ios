import UIKit
import Yosemite

/// Provides view data for Linked Products, and handles init/UI/navigation actions needed.
///
final class LinkedProductsViewModel {

    typealias Section = LinkedProductsViewController.Section
    typealias Row = LinkedProductsViewController.Row

    private let product: ProductFormDataModel

    private(set) var upsellIDs: [Int64]
    private(set) var crossSellIDs: [Int64]

    init(product: ProductFormDataModel) {
        self.product = product
        upsellIDs = product.upsellIDs
        crossSellIDs = product.crossSellIDs
    }

    var sections: [Section] {
        var rows = [Row]()

        rows.append(.upsells)
        if upsellIDs.count > 0 {
            rows.append(.upsellsProducts)
        }
        rows.append(.upsellsButton)

        rows.append(.crossSells)
        if crossSellIDs.count > 0 {
            rows.append(.crossSellsProducts)
        }
        rows.append(.crossSellsButton)

        return [Section(rows: rows)]
    }
}

extension LinkedProductsViewModel {

    func handleUpsellIDsChange(_ upsellIDs: [Int64]) {
        self.upsellIDs = upsellIDs
    }

    func handleCrossSellIDsChange(_ crossSellIDs: [Int64]) {
        self.crossSellIDs = crossSellIDs
    }

    func hasUnsavedChanges() -> Bool {
        guard upsellIDs != product.upsellIDs || crossSellIDs != product.crossSellIDs else {
            return false
        }

        return true
    }
}
