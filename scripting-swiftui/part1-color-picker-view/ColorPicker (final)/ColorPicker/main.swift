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
import SwiftUI

// MARK: - Constants

let app = NSApplication.shared
let origin = CGPoint(x: NSScreen.main?.frame.midX ?? 50, y: NSScreen.main?.frame.midY ?? 50)
let colors: [(name: String, value: Color)] = [("Red", .red),
                                              ("Green", .green),
                                              ("Yellow", .yellow),
                                              ("Orange", .orange)]

// MARK: - Views

struct MainView: View {

    @State private var selectedColor = 0

    var body: some View {
        HStack {
            Picker(selection: $selectedColor, label: Text("Select a color")) {
                ForEach(0..<colors.count) { index in
                    Text(colors[index].name)
                }
            }

            Rectangle()
                .fill(colors[selectedColor].value)
                .frame(width: 25, height: 25)
                .cornerRadius(5)
        }
    }
}

// MARK: - Setup

class AppDelegate: NSObject, NSApplicationDelegate {

    let window = NSWindow(
        contentRect: NSRect(origin: origin, size: CGSize(width: 400, height: .zero)),
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

        window.contentView = NSHostingView(rootView: MainView().padding(30))
    }

    func applicationShouldTerminateAfterLastWindowClosed( _ sender: NSApplication) -> Bool { true }
}

let delegate = AppDelegate()
app.delegate = delegate
app.run()
