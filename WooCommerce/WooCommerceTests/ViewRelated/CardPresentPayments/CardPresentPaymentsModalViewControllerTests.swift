import XCTest
@testable import WooCommerce

final class CardPresentPaymentsModalViewControllerTests: XCTestCase {

    func test_viewcontroller_presents_top_title_provided_by_viewmodel() throws {
        let viewModel = ModalViewModel(mode: .fullInfo)
        let viewController = CardPresentPaymentsModalViewController(viewModel: viewModel)

        _ = try XCTUnwrap(viewController.view)

        XCTAssertEqual(viewController.getTopTitleLabel().text, viewModel.topTitle)
    }

    func test_viewcontroller_presents_top_subtitle_provided_by_viewmodel() throws {
        let viewModel = ModalViewModel(mode: .fullInfo)
        let viewController = CardPresentPaymentsModalViewController(viewModel: viewModel)

        _ = try XCTUnwrap(viewController.view)

        XCTAssertEqual(viewController.getTopSubtitleLabel().text, viewModel.topSubtitle)
    }

    func test_viewcontroller_presents_image_provided_by_viewmodel() throws {
        let viewModel = ModalViewModel(mode: .fullInfo)
        let viewController = CardPresentPaymentsModalViewController(viewModel: viewModel)

        _ = try XCTUnwrap(viewController.view)
        let image = viewController.getImageView().image

        XCTAssertEqual(image, viewModel.image)
    }

    func test_viewcontroller_presents_bottom_title_provided_by_viewmodel() throws {
        let viewModel = ModalViewModel(mode: .fullInfo)
        let viewController = CardPresentPaymentsModalViewController(viewModel: viewModel)

        _ = try XCTUnwrap(viewController.view)

        XCTAssertEqual(viewController.getBottomTitleLabel().text, viewModel.bottomTitle)
    }

    func test_viewcontroller_presents_bottom_subtitle_provided_by_viewmodel() throws {
        let viewModel = ModalViewModel(mode: .fullInfo)
        let viewController = CardPresentPaymentsModalViewController(viewModel: viewModel)

        _ = try XCTUnwrap(viewController.view)

        XCTAssertEqual(viewController.getBottomSubtitleLabel().text, viewModel.bottomSubtitle)
    }

    func test_viewcontroller_propagates_tap_in_primary_button_to_viewmodel() throws {
        let viewModel = ModalViewModel(mode: .twoActionButtons)
        let viewController = CardPresentPaymentsModalViewController(viewModel: viewModel)

        _ = try XCTUnwrap(viewController.view)

        let primaryButton = viewController.getPrimaryActionButton()
        primaryButton.sendActions(for: .touchUpInside)

        XCTAssertTrue(viewModel.primaryButtonTapped)
    }

    func test_viewcontroller_propagates_tap_in_primary_button_to_viewmodel_in_oneaction_mode() throws {
        let viewModel = ModalViewModel(mode: .oneActionButton)
        let viewController = CardPresentPaymentsModalViewController(viewModel: viewModel)

        _ = try XCTUnwrap(viewController.view)

        let primaryButton = viewController.getPrimaryActionButton()
        primaryButton.sendActions(for: .touchUpInside)

        XCTAssertTrue(viewModel.primaryButtonTapped)
    }

    func test_viewcontroller_propagates_tap_in_primary_button_to_viewmodel_in_reducedInfo_mode() throws {
        let viewModel = ModalViewModel(mode: .reducedInfoOneActionButton)
        let viewController = CardPresentPaymentsModalViewController(viewModel: viewModel)

        _ = try XCTUnwrap(viewController.view)

        let primaryButton = viewController.getPrimaryActionButton()
        primaryButton.sendActions(for: .touchUpInside)

        XCTAssertTrue(viewModel.primaryButtonTapped)
    }

    func test_viewcontroller_propagates_tap_in_secondary_button_to_viewmodel() throws {
        let viewModel = ModalViewModel(mode: .twoActionButtons)
        let viewController = CardPresentPaymentsModalViewController(viewModel: viewModel)

        _ = try XCTUnwrap(viewController.view)

        let secondaryButton = viewController.getSecondaryActionButton()
        secondaryButton.sendActions(for: .touchUpInside)

        XCTAssertTrue(viewModel.secondaryButtonTapped)
    }

    func test_viewcontroller_propagates_tap_in_primary_button_is_not_initialized_in_full_info_mode() throws {
        let viewModel = ModalViewModel(mode: .fullInfo)
        let viewController = CardPresentPaymentsModalViewController(viewModel: viewModel)

        _ = try XCTUnwrap(viewController.view)

        let primaryButton = viewController.getPrimaryActionButton()
        primaryButton.sendActions(for: .touchUpInside)

        XCTAssertFalse(viewModel.primaryButtonTapped)
    }

    func test_viewcontroller_propagates_tap_in_secondary_button_is_not_initialized_in_full_info_mode() throws {
        let viewModel = ModalViewModel(mode: .fullInfo)
        let viewController = CardPresentPaymentsModalViewController(viewModel: viewModel)

        _ = try XCTUnwrap(viewController.view)

        let secondaryButton = viewController.getSecondaryActionButton()
        secondaryButton.sendActions(for: .touchUpInside)

        XCTAssertFalse(viewModel.secondaryButtonTapped)
    }

    func test_viewcontroller_hides_bottom_subtitle_label_in_reduced_info_mode() throws {
        let viewModel = ModalViewModel(mode: .reducedInfo)
        let viewController = CardPresentPaymentsModalViewController(viewModel: viewModel)

        _ = try XCTUnwrap(viewController.view)

        let bottomSubtitleLabel = viewController.getBottomSubtitleLabel()

        XCTAssertTrue(bottomSubtitleLabel.isHidden)
    }
}


private final class ModalViewModel: CardPresentPaymentsModalViewModel {
    let mode: PaymentsModalMode

    /// The title at the top of the modal view.
    let topTitle: String = "top_title"

    /// The second line of text of the modal view. Right over the illustration
    let topSubtitle: String? = "top_subtitle"

    /// An illustration accompanying the modal
    let image: UIImage = .loginNoJetpackError

    /// Provides a title for a primary action button
    let primaryButtonTitle: String? = "primary_button_title"

    /// Provides a title for a secondary action button
    let secondaryButtonTitle: String? = "secondary_button_title"

    /// The title in the bottom section of the modal. Right below the image
    let bottomTitle: String? = "bottom_title"

    /// The subtitle in the bottom section of the modal. Right below the image
    let bottomSubtitle: String? = "bottom_subtitle"


    /// Flag indicating that the primary button has been tapped
    var primaryButtonTapped: Bool = false

    /// Flag indicating that the secondary button has been tapped
    var secondaryButtonTapped: Bool = false

    init(mode: PaymentsModalMode) {
        self.mode = mode
    }

    func didTapPrimaryButton(in viewController: UIViewController?) {
        primaryButtonTapped = true
    }

    func didTapSecondaryButton(in viewController: UIViewController?) {
        secondaryButtonTapped = true
    }
}
