import Cocoa

class ViewController: NSViewController {

    // MARK: - Properties

    @IBOutlet weak var scriptPathTextField: NSTextField!
    @IBOutlet weak var executeButton: NSButton!
    @IBOutlet var outputTextView: NSTextView!

    // MARK: - Functions

    // MARK: Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        executeButton.target = self
        executeButton.action = #selector(executeButtonPressed)
        scriptPathTextField.target = self
        scriptPathTextField.action = #selector(executeButtonPressed)

    }

    // MARK: Outlet actions

    @objc func executeButtonPressed() {
        executeScript(at: scriptPathTextField.stringValue)
    }

    // MARK: Script execution

    func executeScript(at path: String) {
        guard !path.isEmpty else { return }

        do {
            try ExecutionService.executeScript(at: path){ [weak self] result in
                DispatchQueue.main.async { self?.updateTextView(with: result) }
            }
        } catch {
            outputTextView.string = error.localizedDescription
        }
    }

    func updateTextView(with result: Result<String, Error>) {
        switch result {

        case .success(let output):
            outputTextView.string = output

        case .failure(let error):
            outputTextView.string = error.localizedDescription
        }
    }
}
