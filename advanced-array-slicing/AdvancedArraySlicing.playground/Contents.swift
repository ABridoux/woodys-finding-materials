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

// MARK: - Bounds

public struct Bounds: Equatable {

    private let lower: Bound
    private let upper: Bound

    public init(lower: Bound, upper: Bound) {
        self.lower = lower
        self.upper = upper
    }

    public func range(lastValidIndex: Int) throws -> ClosedRange<Int> {
        let lower = self.lower.value < 0 ?
                // count from the end of the array
                lastValidIndex + self.lower.value :
                self.lower.value

        let upper: Int
        if self.upper == .last {
            upper = lastValidIndex
        } else if self.upper.value < 0 {
            // count from the end of the array
            upper = lastValidIndex + self.upper.value
        } else {
            upper = self.upper.value
        }

        guard 0 <= lower, lower <= upper, upper <= lastValidIndex else {
            #warning("Throw a relevant error rather than a fatal error in your own implementation")
            fatalError("Incorrect bounds")
        }
        return lower...upper
  }
}

// MARK: Bound

public extension Bounds {

    struct Bound: ExpressibleByIntegerLiteral, Equatable {

        public static let first = Bound(0, identifier: "first")
        public static let last = Bound(0, identifier: "last")

        var value: Int
        private(set) var identifier: String?

        public init(integerLiteral value: Int) {
            self.value = value
        }

        public init(_ value: Int) {
            self.value = value
        }

        private init(_ value: Int, identifier: String) {
            self.value = value
            self.identifier = identifier
        }
    }
}

// MARK: - Array subscript

public extension Array {

    subscript(_ bounds: Bounds) -> ArraySlice<Element> {
        do {
            let range = try bounds.range(lastValidIndex: count - 1)
            return self[range]
        } catch {
            preconditionFailure("Incorrect bounds: \(error). \(error.localizedDescription)")
        }
    }
}

infix operator ~>

public func ~> (lhs: Bounds.Bound, rhs: Bounds.Bound) -> Bounds {
    Bounds(lower: lhs, upper: rhs)
}


// MARK: - Test

let array = ["Riri", "Fifi", "Loulou", "Donald", "Daisy"]
print(array[-1 ~> .last]) // ["Donald", "Daisy"]
print(array[1 ~> -1]) // ["Fifi", "Loulou", "Donald"]
print(array[-2 ~> -1]) // ["Loulou", "Donald"]
