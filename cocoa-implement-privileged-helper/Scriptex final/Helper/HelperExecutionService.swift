import Foundation

struct HelperExecutionService {

    // MARK: - Constants

    static let programURL = URL(fileURLWithPath: "/usr/bin/env")
    typealias Handler = (Result<String, Error>) -> Void

    // MARK: - Functions

    static func executeScript(at path: String, then completion: @escaping Handler) throws {
        let process = Process()
        process.executableURL = programURL
        process.arguments = [path]

        let outputPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = outputPipe
        try process.run()

        DispatchQueue.global(qos: .userInteractive).async {
            process.waitUntilExit()

            let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()

            guard let output = String(data: outputData, encoding: .utf8) else {
                completion(.failure(ScriptexError.invalidStringConversion))
                return
            }

            completion(.success(output))
        }
    }
}
