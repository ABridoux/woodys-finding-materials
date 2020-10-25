#!/usr/bin/swift

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
