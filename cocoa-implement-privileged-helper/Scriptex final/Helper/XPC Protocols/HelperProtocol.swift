import Foundation

@objc(HelperProtocol)
public protocol HelperProtocol {
    @objc func executeScript(at path: String, then completion: @escaping (String?, Error?) -> Void)
}

