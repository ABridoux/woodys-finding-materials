import Foundation

extension Result where Success == String, Failure == Error {

    // MARK: - Properties

    var string: Success? {
        if case let Self.success(string) = self {
            return string
        }
        return nil
    }

    var error: Failure? {
        if case let Self.failure(error) = self {
            return error
        }
        return nil
    }

    // MARK: - Initialisation

    init(string: String?, error: Error?) {
        if let string = string {
            self = .success(string)
        } else if let error = error {
            self = .failure(error)
        } else {
            self = .failure(ScriptexError.unknown)
        }
    }
}
