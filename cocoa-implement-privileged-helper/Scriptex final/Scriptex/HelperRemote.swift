import Foundation
import XPC
import ServiceManagement

struct HelperRemote {

    // MARK: - Properties

    var isHelperInstalled: Bool { FileManager.default.fileExists(atPath: HelperConstants.helperPath) }

    // MARK: - Functions

    /// Install the Helper in the privileged helper tools folder and load the daemon
    private func installHelper() throws {
        // We will ask to the user to validate the helper installation in /Library/PrivilegedHelperTools and daemon loading

        // Empty authorization to test
        var authRef: AuthorizationRef?
        var authStatus = AuthorizationCreate(nil, nil, [.preAuthorize], &authRef)

        guard authStatus == errAuthorizationSuccess else {
            throw ScriptexError.helperInstallation("Unable to get a valid empty authorization reference to load Helper daemon")
        }

        // Validation for SMJobBless, which will install the helper and load the daemon
        var authItem = AuthorizationItem(name: kSMRightBlessPrivilegedHelper, valueLength: 0, value: nil, flags: 0)
        var authRights = AuthorizationRights(count: 1, items: &authItem)
        let flags: AuthorizationFlags = [[], .interactionAllowed, .extendRights, .preAuthorize]
        authStatus = AuthorizationCreate(&authRights, nil, flags, &authRef)

        guard authStatus == errAuthorizationSuccess else {
            throw ScriptexError.helperInstallation("Unable to get a valid loading authorization reference to load Helper daemon")
        }

        // Try to install the helper and to load the daemon with authorization
        var error: Unmanaged<CFError>?
        if SMJobBless(kSMDomainSystemLaunchd, HelperConstants.domain as CFString, authRef, &error) == false {
            let blessError = error!.takeRetainedValue() as Error
            throw ScriptexError.helperInstallation("Error while installing the Helper: \(blessError.localizedDescription)")
        }

        // Helper successfully installed
        // Release the authorization, as mentionned in the doc
        AuthorizationFree(authRef!, [])
    }

    private func createConnection() -> NSXPCConnection {
        let connection = NSXPCConnection(machServiceName: HelperConstants.domain, options: .privileged)
        connection.remoteObjectInterface = NSXPCInterface(with: HelperProtocol.self)
        connection.exportedInterface = NSXPCInterface(with: RemoteApplicationProtocol.self)
        connection.exportedObject = self

        connection.invalidationHandler = { [isHelperInstalled] in
            if isHelperInstalled {
                print("Unable to connect to Helper although it is installed")
            } else {
                print("Helper is not installed")
            }
        }

        connection.resume()

        return connection
    }

    private func getConnection() throws -> NSXPCConnection {
        if !isHelperInstalled {
            // we'll try to install the Helper if not already installed, but we need to get the admin authorization
            try installHelper()
        }
        return createConnection()
    }

    func getRemote() throws -> HelperProtocol {
        var proxyError: Error?

        // Try to get the helper
        let helper = try getConnection().remoteObjectProxyWithErrorHandler({ (error) in
            proxyError = error
        }) as? HelperProtocol

        // Try to unwrap the Helper
        if let unwrappedHelper = helper {
            return unwrappedHelper
        } else {
            throw ScriptexError.helperConnection(proxyError?.localizedDescription ?? "Unknown error")
        }
    }
}
