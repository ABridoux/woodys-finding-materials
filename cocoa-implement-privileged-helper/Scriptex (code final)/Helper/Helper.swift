import Foundation

class Helper: NSObject, NSXPCListenerDelegate, HelperProtocol {

    // MARK: - Properties

    let listener: NSXPCListener

    // MARK: - Initialisation

    override init() {
        self.listener = NSXPCListener(machServiceName: HelperConstants.domain)
        super.init()
        self.listener.delegate = self
    }

    // MARK: - Functions

    // MARK: HelperProtocol

    func executeScript(at path: String, then completion: @escaping (String?, Error?) -> Void) {
        NSLog("Executing script at \(path)")
        do {
            try ExecutionService.executeScript(at: path) { (result) in
                NSLog("Output: \(result.string ?? ""). Error: \(result.error?.localizedDescription ?? "")")
                completion(result.string, result.error)
            }
        } catch {
            NSLog("Error: \(error.localizedDescription)")
            completion(nil, error)
        }
    }

    func run() {
        // start listening on new connections
        self.listener.resume()
        // prevent the terminal application to exit
        RunLoop.current.run()
    }

    func listener(_ listener: NSXPCListener, shouldAcceptNewConnection newConnection: NSXPCConnection) -> Bool {
        newConnection.exportedInterface = NSXPCInterface(with: HelperProtocol.self)
        newConnection.remoteObjectInterface = NSXPCInterface(with: RemoteApplicationProtocol.self)
        newConnection.exportedObject = self

        newConnection.resume()

        return true
    }
}
