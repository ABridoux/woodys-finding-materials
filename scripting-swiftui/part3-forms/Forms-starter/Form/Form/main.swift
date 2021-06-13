#!/usr/bin/swift

// Written by Alexis Bridoux for Woody's Findings tutorials
// Scripting with SwiftUI (3) - Forms

import Cocoa
import AppKit
import SwiftUI

// MARK: - Constants

let app = NSApplication.shared
let origin = CGPoint(x: NSScreen.main?.frame.midX ?? 50, y: NSScreen.main?.frame.midY ?? 50)
let windowWidth = CGFloat(700)
let labelsWidth = CGFloat(windowWidth / 4)

// MARK: - Models

// Models to be implemented

// MARK: - Views

struct MainView: View {

    var body: some View {
        Text("Are you ready to rock?!")
    }
}

// MARK: - Setup

class AppDelegate: NSObject, NSApplicationDelegate {

    let window = NSWindow(
        contentRect: NSRect(origin: origin, size: CGSize(width: windowWidth, height: .zero)),
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
        window.makeKeyAndOrderFront(nil)
        window.makeMain()

        window.contentView = NSHostingView(rootView: MainView().padding(30))
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool { true }
}

let delegate = AppDelegate()
app.delegate = delegate
app.run()
