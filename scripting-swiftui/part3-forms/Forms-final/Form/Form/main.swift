#!/usr/bin/swift

// Written by Alexis Bridoux for Woody's Findings tutorials
// Scripting with SwiftUI (3) - Forms

import AppKit
import SwiftUI

// MARK: - Constants

let app = NSApplication.shared
let origin = CGPoint(x: NSScreen.main?.frame.midX ?? 50, y: NSScreen.main?.frame.midY ?? 50)
let windowWidth = CGFloat(400)
let labelsWidth = windowWidth / 4

final class Infos: ObservableObject {

    @Published var firstName = ""
    @Published var lastName = ""
    @Published var department = Department.sales
    @Published var equipmentUpdate = false
    @Published var equipment = Equipment()
    @Published private var shouldDisplayWarnings = false
}

// MARK: Infos+Export

extension Infos {

    func export(to path: String) -> Bool {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(self)
            FileManager.default.createFile(atPath: path, contents: data)
            return true
        } catch {
            print("Something went wrong when exporting the inputs. \(error.localizedDescription)")
            return false
        }
    }
}

extension Infos: Encodable {

    enum CodingKeys: String, CodingKey {
        case firstName, lastName, department, equipment
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(firstName, forKey: .firstName)
        try container.encode(lastName, forKey: .lastName)
        try container.encode(department, forKey: .department)
        try container.encode(equipment, forKey: .equipment)
    }
}

enum Department: String, CaseIterable, Identifiable, Encodable {
    case sales = "Sales"
    case it = "IT"
    case marketing = "Marketing"
    case communication = "Communication"

    var id: String { rawValue }
}

extension Infos {

    struct Equipment: Encodable {
        var mac = false
        var headset = false
        var mouse = false
        var keyboard = false
    }
}

// MARK: Info+Validation

extension Infos {

    var isFirstNameValid: Bool { !firstName.isEmpty }
    var isLastNameValid: Bool { !lastName.isEmpty }
    var isValid: Bool { isFirstNameValid && isLastNameValid }

    var shouldDisplayWarningForFirstName: Bool {
        shouldDisplayWarnings && !isFirstNameValid
    }

    var shouldDisplayWarningForLastName: Bool {
        shouldDisplayWarnings && !isLastNameValid
    }

    func validate() -> Bool {
        shouldDisplayWarnings = !isValid
        return isValid
    }
}

// MARK: - Views

struct WarningPopover: View {

    var text: String
    var shouldDisplay: Bool
    @State private var showPopover = false

    var body: some View {
        HStack {
            Spacer()
            if shouldDisplay {
                Image(systemName: "xmark.octagon")
                    .foregroundColor(.red)
                    .padding(2)
                    .popover(isPresented: $showPopover) {
                        Text(text)
                            .padding()
                    }
                    .onHover { (hoverring) in
                        showPopover = hoverring
                    }
            }
        }
    }
}

struct NameRow: View {

    @Binding var value: String
    let label: String
    var shouldDisplayWarning: Bool

    var body: some View {
        HStack {
            Text("\(label):")
                .frame(minWidth: labelsWidth, alignment: .trailing)
            TextField(label, text: $value)
                .overlay(
                    WarningPopover(
                        text: "Invalid value. Please provide a non empty value",
                        shouldDisplay: shouldDisplayWarning)
                    )
        }
    }
}

struct DepartmentRow: View {

    @Binding var department: Department

    var body: some View {
        Picker(
            selection: $department,
            label:
                Text("Department:")
                    .frame(minWidth: labelsWidth, alignment: .trailing))
        {
            ForEach(Department.allCases) { department in
                Text(department.rawValue).tag(department)
            }
        }
    }
}

struct EquipmentRow: View {

    @ObservedObject var infos: Infos

    var body: some View {
        VStack(spacing: 5) {
            HStack {
                Text("Equipment:")
                    .frame(minWidth: labelsWidth, alignment: .trailing)
                Toggle(isOn: $infos.equipmentUpdate) {
                    Text("I wish to update my equipment")
                }
                Spacer()
            }
            if infos.equipmentUpdate {
                NewEquipmentRow(text: "New Mac", isOn: $infos.equipment.mac)
                NewEquipmentRow(text: "New headset", isOn: $infos.equipment.headset)
                NewEquipmentRow(text: "New keyboard", isOn: $infos.equipment.keyboard)
                NewEquipmentRow(text: "New mouse", isOn: $infos.equipment.mouse)
            }
        }
    }
}

struct NewEquipmentRow: View {

    let text: String
    @Binding var isOn: Bool

    var body: some View {
        HStack {
            Text("")
                .frame(minWidth: labelsWidth)
            Toggle(isOn: $isOn) {
                Text(text)
            }
            Spacer()
        }
    }
}

struct MainView: View {

    @StateObject var infos = Infos()
    @State private var showAlert = false

    var body: some View {
        Form {
            VStack {
                NameRow(
                    value: $infos.firstName,
                    label: "First name",
                    shouldDisplayWarning: infos.shouldDisplayWarningForFirstName)
                NameRow(
                    value: $infos.lastName,
                    label: "Last name",
                    shouldDisplayWarning: infos.shouldDisplayWarningForLastName)
                DepartmentRow(department: $infos.department)
                EquipmentRow(infos: infos)
                HStack {
                    Spacer()
                    Button("Send") {
                        guard infos.validate() else { return }
                        // export data
                        showAlert = !infos.export(to: "/Users/Shared/inputs.json")

                        guard !showAlert else { return }
                        NSApp.terminate(nil)
                    }
                }
            }
        }
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
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
        window.makeKeyAndOrderFront(nil)
        window.makeMain()

        window.contentView = NSHostingView(
            rootView:
                MainView()
                .padding(10)
                .frame(maxWidth: windowWidth)
                .environmentObject(Infos())
        )
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool { true }
}

let delegate = AppDelegate()
app.delegate = delegate
app.run()
