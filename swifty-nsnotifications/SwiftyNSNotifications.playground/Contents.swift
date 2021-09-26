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

import Foundation

// MARK: Extensions

extension NSNotification.Name {

    static let orderIsReady = Self(rawValue: "orderIsReady")
}

extension NotificationCenter {

    func post(_ notificationName: NSNotification.Name) {
        post(name: notificationName, object: nil)
    }

    func addObserver(for notificationName: NSNotification.Name,
                     using block: @escaping (Notification) -> Void) -> NSObjectProtocol {
        addObserver(forName: notificationName, object: nil, queue: nil, using: block)
    }

    func removeObserver(_ observer: NSObjectProtocol, name: NSNotification.Name) {
        removeObserver(observer, name: name, object: nil)
    }
}

// MARK: NotificationObserver

final class NotificationObserver {

    var name: Notification.Name
    var observer: NSObjectProtocol
    var center = NotificationCenter.default

    init(for name: Notification.Name, block: @escaping (Notification) -> Void) {
        self.name = name
        observer = center.addObserver(for: name, using: block)
    }

    deinit {
        print("Removing observer for '\(name.rawValue)' notification...")
        center.removeObserver(observer, name: name)
    }
}

extension Array where Element == NotificationObserver {

    mutating func append(name: NSNotification.Name, using block: @escaping (Notification) -> Void) {
        append(NotificationObserver(for: name, block: block))
    }
}

// MARK: Test models

struct Cook {
    var center = NotificationCenter.default

    func notifyOrderReady() {
        center.post(.orderIsReady)
    }
}

final class Client {
    var observer: NotificationObserver?

    func startObserving() {
        observer = NotificationObserver(for: .orderIsReady) { [weak self] _ in self?.orderIsReady() }
    }

    func orderIsReady() {
        print("😋")
    }
}

// MARK: Test

let cook = Cook()
var client: Client? = Client()

client?.startObserving()
cook.notifyOrderReady()

client = nil // should print the removing observer message
