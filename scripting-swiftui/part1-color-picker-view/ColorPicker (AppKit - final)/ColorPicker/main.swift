#!/usr/bin/swift

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
import AppKit

// MARK: - Constants

let app = NSApplication.shared
let origin = CGPoint(x: NSScreen.main?.frame.midX ?? 50, y: NSScreen.main?.frame.midY ?? 50)
let colors: [(name: String, value: NSColor)] = [("Red", .systemRed),
                                              ("Green", .systemGreen),
                                              ("Yellow", .systemYellow),
                                              ("Orange", .systemOrange)]

// MARK: - Views

final class MainViewController: NSViewController {

    var selectedColor = 0

    let stackView = NSStackView()
    let label = NSTextField(labelWithString: "Select a color")
    let popupButton = NSPopUpButton()
    let colorView = NSView()

    override func loadView() {
        self.view = NSView(frame: NSRect(origin: .zero, size: CGSize(width: 300, height: 100)))
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupLayout()
    }

    func setupViews() {

        stackView.orientation = .horizontal
        stackView.alignment = .centerY
        stackView.distribution = .equalCentering
        view.addSubview(stackView)
        stackView.wantsLayer = true

        stackView.addArrangedSubview(label)

        popupButton.addItems(withTitles: colors.map(\.name))
        popupButton.action = #selector(itemSelected)
        popupButton.target = self
        stackView.addArrangedSubview(popupButton)

        colorView.wantsLayer = true
        colorView.layer?.backgroundColor = colors[selectedColor].value.cgColor
        colorView.layer?.cornerRadius = 5
        stackView.addArrangedSubview(colorView)
    }

    func setupLayout() {
        stackView.frame = view.frame.insetBy(dx: 30, dy: 30)

        colorView.translatesAutoresizingMaskIntoConstraints = false
        colorView.heightAnchor.constraint(equalToConstant: 25).isActive = true
        colorView.widthAnchor.constraint(equalToConstant: 25).isActive = true
    }

    func updateViews() {
        colorView.layer?.backgroundColor = colors[selectedColor].value.cgColor
    }

    @objc
    func itemSelected() {
        selectedColor = popupButton.indexOfSelectedItem
        updateViews()
    }
}

// MARK: - Setup

class AppDelegate: NSObject, NSApplicationDelegate {

    let window = NSWindow(
        contentRect: .zero,
        styleMask: [.titled, .closable],
        backing: .buffered,
        defer: false,
        screen: nil
    )

    func applicationDidFinishLaunching(_ notification: Notification) {

        // setup the window
        window.makeKeyAndOrderFront(nil)
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)

        window.setFrameOrigin(origin)
        window.contentViewController = MainViewController()
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool { true }
}

let delegate = AppDelegate()
app.delegate = delegate
app.run()
