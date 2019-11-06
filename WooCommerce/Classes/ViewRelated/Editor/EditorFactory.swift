import Yosemite

protocol Editor {
    typealias OnContentSave = (_ content: String) -> Void
    var onContentSave: OnContentSave? { get }
}

/// This class takes care of instantiating the editor.
///
final class EditorFactory {

    // MARK: - Editor: Instantiation

    func productDescriptionEditor(product: Product,
                                  onContentSave: @escaping Editor.OnContentSave) -> Editor & UIViewController {
        let editor = AztecEditorViewController(content: product.fullDescription)
        editor.onContentSave = onContentSave
        return editor
    }
}
