@testable import Hardware

extension ReceiptLineItem {
    /// Generates a sample line item with the given number in the title
    static func sampleItem(number: Int) -> ReceiptLineItem {
        ReceiptLineItem(title: "Sample product #\(number)", amount: "2500")
    }
}

extension CardPresentReceiptParameters {
    /// Generates a set of sample CardPresentReceiptParameters with the given total receipt amount
    static func sampleParameters(amount: UInt) -> CardPresentReceiptParameters {
        CardPresentReceiptParameters(
            amount: amount,
            currency: "USD",
            storeName: "Test Store",
            cardDetails: .init(
                last4: "1234",
                expMonth: 12,
                expYear: 26,
                cardholderName: "John Smith",
                brand: .masterCard,
                fingerprint: "fpr*****",
                generatedCard: "pm_******",
                receipt: .init(
                    applicationPreferredName: "Stripe Credit",
                    dedicatedFileName: "A00000000000000",
                    authorizationResponseCode: "0000",
                    applicationCryptogram: "XXXXXXXXXXXX",
                    terminalVerificationResults: "101010101010101010",
                    transactionStatusInformation: "6800",
                    accountType: "credit"
                ),
                emvAuthData: "AD*******")
        )
    }
}

extension ReceiptContent {
    /// Generates a sample receipt with the given number of line items
    static func sampleReceipt(items: Int) -> ReceiptContent {
        let items = (1...items)
            .map(ReceiptLineItem.sampleItem)
        let amount = items
            .map(\.amount)
            .compactMap(UInt.init)
            .reduce(0, +)

        let parameters: CardPresentReceiptParameters = .sampleParameters(amount: amount)
        return ReceiptContent(parameters: parameters, lineItems: items)
    }


}
