import Foundation

struct ExecutionService {

    // MARK: - Constants

    static let programURL = URL(fileURLWithPath: "/usr/bin/env")
    typealias Handler = (Result<String, Error>) -> Void

    // MARK: - Functions

    static func executeScript(at path: String, then completion: @escaping Handler) throws {
        let remote = try HelperRemote().getRemote()
        
        remote.executeScript(at: path) { (output, error) in
            completion(Result(string: output, error: error))
        }
    }
}
