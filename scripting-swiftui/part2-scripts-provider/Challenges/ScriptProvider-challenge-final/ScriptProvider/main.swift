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
import SwiftUI

// MARK: - Constants

let app = NSApplication.shared
let origin = CGPoint(x: NSScreen.main?.frame.midX ?? 50, y: NSScreen.main?.frame.midY ?? 50)
let windowWidth = CGFloat(700)
let windowHeight = CGFloat(500)
let scriptListWidth = windowWidth * 0.35
let scriptsDetailWidth = windowWidth * 0.65

extension Color {
    static let controlBackground = Color(NSColor.controlBackgroundColor)
    static let selectedText = Color(NSColor.selectedTextBackgroundColor)
}

// MARK: - Models

struct Script {
    let name: String
    let details: String
    let path: String
    var isRunning = false
}

extension Script {
    static let task = Script(name: "Task",
                             details: "Echo the date in /tmp",
                             path: "/Users/alexisbridoux/Desktop/task.sh")

    static let longTask = Script(name: "Task (long)",
                                 details: "Echo the date in /tmp after 2 seconds",
                                 path: "/Users/alexisbridoux/Desktop/long-task.sh")
}

final class ScriptsProvider: ObservableObject {
    @Published var scripts: [Script] = [.task, .longTask]
    @Published var selectedScriptIndex = 0

    var selectedScript: Script {
        scripts[selectedScriptIndex]
    }

    func runSelectedScript() {
        let selectedIndex = selectedScriptIndex
        let selectedScript = self.selectedScript
        let url = URL(fileURLWithPath: selectedScript.path)

        let task: NSUserScriptTask
        do {
            task = try NSUserScriptTask(url: url)
        } catch {
            print("✖︎ Error while loading the script at \(selectedScript.path). \(error), \(error.localizedDescription)\n")
            return
        }

        scripts[selectedIndex].isRunning = true

        task.execute { [unowned self] error in
            if let error = error {
                print("✖︎ The script at \(selectedScript.path) finished with an error: \(error), \(error.localizedDescription)\n")
            } else {
                print("✓ The script at \(selectedScript.path) finished successfully\n")
            }
            DispatchQueue.main.async {
                self.scripts[selectedIndex].isRunning = false
            }
        }
    }

    func runSelectedScriptWithOutput(_ completion: @escaping (Result<String, Error>) -> Void) {
        let selectedIndex = selectedScriptIndex
        let selectedScript = self.selectedScript
        let url = URL(fileURLWithPath: selectedScript.path)

        let process = Process()
        process.executableURL = url
        process.arguments = ["/usr/bin/env"]
        let pipe = Pipe()
        process.standardOutput = pipe

        scripts[selectedIndex].isRunning = true

        DispatchQueue.global(qos: .background).async {

            defer {
                DispatchQueue.main.async {
                    self.scripts[selectedIndex].isRunning = false
                }
            }

            do {
                try process.run()
            } catch {
                completion(.failure(error))
            }

            let outputData = pipe.fileHandleForReading.readDataToEndOfFile()
            if let output = String(data: outputData, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) {
                completion(.success(output))
            } else {
                let userInfo = ["reason": "Unable to convert data output", "path": selectedScript.path]
                completion(.failure(NSError(domain: "scriptsProvider", code: 2, userInfo: userInfo)))
            }
        }
    }
}

// MARK: - Views

struct Spinner: NSViewRepresentable {

    @EnvironmentObject var scriptsProvider: ScriptsProvider
    let size: NSControl.ControlSize

    func makeNSView(context: Context) -> NSProgressIndicator {
        let indicatorView = NSProgressIndicator()
        indicatorView.isDisplayedWhenStopped = false
        indicatorView.controlSize = size
        indicatorView.style = .spinning

        return indicatorView
    }

    func updateNSView(_ nsView: NSProgressIndicator, context: Context) {
        scriptsProvider.selectedScript.isRunning ? nsView.startAnimation(nil) : nsView.stopAnimation(nil)
    }
}

struct ScriptList: View {

    @EnvironmentObject var scriptsProvider: ScriptsProvider

    var body: some View {
        List(0..<scriptsProvider.scripts.count) { index in
            VStack(alignment: .leading) {
                Text(scriptsProvider.scripts[index].name)
                    .fontWeight(.semibold)
                Text(scriptsProvider.scripts[index].details)
                    .lineLimit(2)
            }
            .padding(.vertical, 5)
            .padding(.horizontal, 20)
            .frame(maxWidth: scriptListWidth, minHeight: 60, maxHeight: 60, alignment: .leading)
            .background(Color.selectedText.opacity(opacity(for: index)))
            .cornerRadius(5)
            .contentShape(Rectangle())
            .onTapGesture {
                scriptsProvider.selectedScriptIndex = index
            }
        }
    }

    func opacity(for index: Int) -> Double {
        scriptsProvider.selectedScriptIndex == index ? 1 : 0
    }
}

struct ScriptDetail: View {

    @State var scriptOutput = ""
    @EnvironmentObject var scriptsProvider: ScriptsProvider

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(scriptsProvider.selectedScript.name)
                    .font(.title)
                Spacer()
                Spinner(size: .small)
                Button("Run") {
                    scriptsProvider.runSelectedScriptWithOutput { (result) in
                        switch result {
                        case .success(let output):
                            DispatchQueue.main.async { scriptOutput = output }
                        case .failure(let error):
                            print("Something went wrong when executing the script: \(error), \(error.localizedDescription)")
                        }
                    }
                }
                .disabled(scriptsProvider.selectedScript.isRunning)
            }
            Text(scriptsProvider.selectedScript.details)
                .padding(.bottom, 5)
            Text(scriptOutput)
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .background(Color.selectedText)
                .cornerRadius(5)
                .padding(5)

            Spacer()
        }
        .padding()
    }
}

struct MainView: View {

    @StateObject var scriptsProvider = ScriptsProvider()

    var body: some View {
        HStack {
            ScriptList()
                .environmentObject(scriptsProvider)
                .frame(width: scriptListWidth, height: windowHeight)
                .border(Color.gray)
            ScriptDetail()
                .environmentObject(scriptsProvider)
                .frame(width: scriptsDetailWidth, height: windowHeight)
                .background(Color.controlBackground) // 1
                .border(Color.gray)
        }
    }
}

// MARK: - Setup

class AppDelegate: NSObject, NSApplicationDelegate {

    let window = NSWindow(
        contentRect: NSRect(origin: origin, size: CGSize(width: windowWidth, height: windowHeight)),
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

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool { true }
}

let delegate = AppDelegate()
app.delegate = delegate
app.run()
