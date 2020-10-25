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
