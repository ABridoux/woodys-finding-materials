/**
MIT License

Copyright (c) [2020] Alexis Bridoux

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

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
