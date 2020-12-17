import UIKit

final class OrderCreationFormDataSource: NSObject {
    private let viewModel: OrderCreationFormViewModel

    init(viewModel: OrderCreationFormViewModel) {
        self.viewModel = viewModel
        super.init()
    }

    func registerTableViewCells(_ tableView: UITableView) {
        for row in OrderCreationFormViewModel.Row.allCases {
            tableView.registerNib(for: row.type)
        }

        let headerType = TwoColumnSectionHeaderView.self
        tableView.register(headerType.loadNib(), forHeaderFooterViewReuseIdentifier: headerType.reuseIdentifier)
    }
}

extension OrderCreationFormDataSource: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.sections[section].rows.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = viewModel.sections[indexPath.section]
        let reuseIdentifier = section.rows[indexPath.row].reuseIdentifier
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        configure(cell, section: section, indexPath: indexPath)
        return cell
    }

    func heightForHeaderInSection(_ section: Int, tableView: UITableView) -> CGFloat {
        // Hide header for summary
        if viewModel.sections[section].category == .summary {
            return CGFloat.leastNormalMagnitude
        }

        return UITableView.automaticDimension
    }

    func viewForHeaderInSection(_ section: Int, tableView: UITableView) -> UIView? {
        let reuseIdentifier = TwoColumnSectionHeaderView.reuseIdentifier
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: reuseIdentifier) as? TwoColumnSectionHeaderView else {
            return nil
        }

        header.leftText = viewModel.sections[section].title
        header.rightText = nil

        return header
    }
}

private extension OrderCreationFormDataSource {
    func configure(_ cell: UITableViewCell, section: OrderCreationFormViewModel.Section, indexPath: IndexPath) {
        let row = section.rows[indexPath.row]
        switch cell {
        case let cell as SummaryTableViewCell:
            configureSummary(cell: cell)
        case let cell as LeftImageTableViewCell where row == .addOrderItem:
            configureAddItem(cell: cell)
        case let cell as LeftImageTableViewCell where row == .addCustomer:
            configureAddCustomer(cell: cell)
        case let cell as LeftImageTableViewCell where row == .addOrderNote:
            configureAddNote(cell: cell)
        default:
            fatalError("Unknown cell in Order Creation Form")
        }
    }


    func configureSummary(cell: SummaryTableViewCell) {
        // TODO: add 'new draft' state
    }

    func configureAddItem(cell: LeftImageTableViewCell) {
        cell.leftImage = Icons.addItemIcon
        cell.imageView?.tintColor = .accent
        cell.textLabel?.textColor = .accent
        cell.labelText = Localization.addItemsTitle

        cell.accessibilityTraits = .button
        cell.accessibilityLabel = Localization.addItemsAccessibilityLabel
        cell.accessibilityHint = Localization.addItemsAccessibilityHint
    }

    func configureAddCustomer(cell: LeftImageTableViewCell) {
        cell.leftImage = Icons.addItemIcon
        cell.imageView?.tintColor = .accent
        cell.textLabel?.textColor = .accent
        cell.labelText = Localization.addCustomerTitle

        cell.accessibilityTraits = .button
        cell.accessibilityLabel = Localization.addCustomerAccessibilityLabel
        cell.accessibilityHint = Localization.addCustomerAccessibilityHint
    }

    func configureAddNote(cell: LeftImageTableViewCell) {
        cell.leftImage = Icons.addItemIcon
        cell.imageView?.tintColor = .accent
        cell.textLabel?.textColor = .accent
        cell.labelText = Localization.addNoteTitle

        cell.accessibilityTraits = .button
        cell.accessibilityLabel = Localization.addNoteAccessibilityLabel
        cell.accessibilityHint = Localization.addNoteAccessibilityHint
    }
}

extension OrderCreationFormViewModel.Row {
    var type: UITableViewCell.Type {
        switch self {
        case .summary:
            return SummaryTableViewCell.self
        case .addOrderItem, .addCustomer, .addOrderNote:
            return LeftImageTableViewCell.self
        }
    }

    var reuseIdentifier: String {
        return type.reuseIdentifier
    }
}

private extension OrderCreationFormDataSource {
    enum Icons {
        static let addItemIcon = UIImage.plusImage
    }

    enum Localization {
        static let addItemsTitle = NSLocalizedString("Add Items", comment: "Button text for adding a new item on 'Create Order' screen.")
        static let addItemsAccessibilityLabel = NSLocalizedString("Add Items", comment: "Accessibility label for the 'Add Items' button.")
        static let addItemsAccessibilityHint = NSLocalizedString(
            "Adds a new product or custom item into the order.",
            comment: "VoiceOver accessibility hint, informing the user that the button can be used to add a product or create custom item."
        )

        static let addCustomerTitle = NSLocalizedString("Add Customer", comment: "Button text for adding a customer on 'Create Order' screen.")
        static let addCustomerAccessibilityLabel = NSLocalizedString("Add Customer", comment: "Accessibility label for the 'Add Customer' button.")
        static let addCustomerAccessibilityHint = NSLocalizedString(
            "Adds a customer into the order.",
            comment: "VoiceOver accessibility hint, informing the user that the button can be used to add a customer."
        )

        static let addNoteTitle = NSLocalizedString("Add Note", comment: "Button text for adding a new note on 'Create Order' screen.")
        static let addNoteAccessibilityLabel = NSLocalizedString("Add Note", comment: "Accessibility label for the 'Add Note' button.")
        static let addNoteAccessibilityHint = NSLocalizedString(
            "Composes a new order note.",
            comment: "VoiceOver accessibility hint, informing the user that the button can be used to create a new order note."
        )
    }
}