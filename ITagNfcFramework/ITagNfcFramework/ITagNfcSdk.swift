// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftUI
import CoreNFC

/**
 `ITagNfcFramework`
 */
@available(iOS 13.0, *)
public protocol ITagNfcSdkDelegate: AnyObject {
    func iTagNfcSdkGetFlightData(results: ITagNfcFlightData?, error: ITagNfcApduError?)
    func iTagNfcGetTagData(results: TagDataResponse?, error: ITagNfcApduError?)
    func iTagNfcSdkUpdateData(isSuccess: Bool, error: ITagNfcApduError?, info: [String: Any]?)
    func iTagNfcSdkUpdateLayout(isSuccess: Bool, error: ITagNfcApduError?)
}

/**
 `ITagNfcSdk`
 */
@available(iOS 13.0, *)
public class ITagNfcSdk: ITagNfcProtocol {

    // MARK: - Properties

    private var message: String
    private var apiKey: String
    public weak var delegate: ITagNfcSdkDelegate?
    public var sessionOpen: Bool = false
    public let nfcTag = ITagNfc()

    /// Initializer
    public init(message: String = "Hold your iPhone near the item.", apiKey: String) {
        self.message = message
        self.apiKey = apiKey
        self.nfcTag.delegate = self
    }

    /// Get flight data
    public func getFlightData() {
        // TODO: validate API Key, throw error if key is not valid
        nfcTag.setType(.getFlightData)
        nfcTag.start(message)
    }

    /// Update data
    ///
    /// - Parameters:
    ///   - request: The data to be updated
    public func updateData(_ request: ITagNfcFlightData) {
        // TODO: validate API Key, throw error if key is not valid
        updateData(request.getAllUInt8Array())
    }

    /// Update data
    ///
    /// - Parameters:
    ///   - request: The data to be updated
    public func updateData(_ request: [UInt8]) {
        // TODO: validate API Key, throw error if key is not valid
        nfcTag.setType(.updateData)
        nfcTag.updateRequest(request)
        nfcTag.start(message)
    }
    
    /// Update layout
    ///
    /// - Parameters:
    ///   - type: The layout type to be updated
    public func updateLayout(_ type: ITagNfcLayout.LayoutType) {
        // TODO: validate API Key, throw error if key is not valid
        nfcTag.setType(.updateLayout(type))
        nfcTag.start(message)
    }
    
    /// Get tag data
    public func getTagData() {
        // TODO: validate API Key, throw error if key is not valid
        nfcTag.setType(.getTagData)
        nfcTag.start(message)
    }
    
    /// Run diagnostics from the input data
    ///
    /// - Parameters:
    ///   - data: The data to write to iTag
    public func runDiagnostics(_ data: [ITagNfcApduError: NFCISO7816APDU]) {
        guard let session = nfcTag.session, let tag = nfcTag.tag else { return }
        var diagnosticsResults: [String: Bool] = [:]
        
        for (key, value) in data {
            nfcTag.sendCommand(tag, session, value, completion: { result in
                let testResult: Bool
                defer {
                    if let errorDescription = key.errorDescription {
                        diagnosticsResults[errorDescription] = testResult
                        if (diagnosticsResults.count == data.count) {
                            self.delegate?.iTagNfcSdkUpdateData(isSuccess: true, error: nil, info: diagnosticsResults)
                            // Close session
                            self.updateSessionStatus(status: false)
                        }
                    }
                }
                switch result {
                case .success(let apdu):
                    testResult = ITagNfcApduError.getError(apdu) == key
                case .failure:
                    testResult = false
                }
            })
        }
    }
    
    /// Update iTag session status to keep open/close
    ///
    /// - Parameters:
    ///   - status: The status to be updated
    public func updateSessionStatus(status: Bool) {
        nfcTag.updateSession(status: status)
    }
}

//MARK: - PiReadNfcDelegate

@available(iOS 13.0, *)
extension ITagNfcSdk: ITagNfcDelegate {

    /// Get flight data callback from ITagNfcDelegate
    ///
    /// - Parameters:
    ///   - results:     The results.
    ///   - error:       The error response that is returned.
    public func iTagNfcGetFlightData(results: ITagNfcFlightData?, error: ITagNfcApduError?) {
        delegate?.iTagNfcSdkGetFlightData(results: results, error: error)
    }
    
    /// Get tag data callback from ITagNfcDelegate
    ///
    /// - Parameters:
    ///   - results:     The results.
    ///   - error:       The error response that is returned.
    public func iTagNfcGetTagData(results: TagDataResponse?, error: ITagNfcApduError?) {
        delegate?.iTagNfcGetTagData(results: results, error: error)
    }
    
    /// Update data callback from ITagNfcDelegate
    ///
    /// - Parameters:
    ///   - results:     The results.
    ///   - error:       The error response that is returned.
    ///   - info:        The extra info such as notes
    public func iTagNfcUpdateData(isSuccess: Bool, error: ITagNfcApduError?, info: [String: Any]?) {
        delegate?.iTagNfcSdkUpdateData(isSuccess: isSuccess, error: error, info: info)
    }
    
    /// Update layout callback from ITagNfcDelegate
    ///
    /// - Parameters:
    ///   - isSuccess:   The results indicator.
    ///   - error:       The error response that is returned.
    public func iTagNfcUpdateLayout(isSuccess: Bool, error: ITagNfcApduError?) {
        delegate?.iTagNfcSdkUpdateLayout(isSuccess: isSuccess, error: error)
    }
}
