//
//  ITagNfc.swift
//
//
//  Created by atrinh on 2/29/24.
//

import Combine
import CoreNFC
import Foundation

/**
 `ITagNfcDelegate`
 */
@available(iOS 13.0, *)
public protocol ITagNfcDelegate: AnyObject {
    func iTagNfcGetFlightData(results: ITagNfcFlightData?, error: ITagNfcApduError?)
    func iTagNfcGetTagData(results: TagDataResponse?, error: ITagNfcApduError?)
    func iTagNfcUpdateData(isSuccess: Bool, error: ITagNfcApduError?, info: [String: Any]?)
    func iTagNfcUpdateLayout(isSuccess: Bool, error: ITagNfcApduError?)
}

/**
 `ITagNfc` class
 */
@available(iOS 13.0, *)
open class ITagNfc: NSObject, ObservableObject, NFCTagReaderSessionDelegate {

    /// Properties
    private var type: ITagNfcType? = nil
    private(set) var session: NFCTagReaderSession?
    private(set) var tag: NFCISO7816Tag? = nil
    private var request: [UInt8]
    public var delegate: ITagNfcDelegate?
    private var keepSessionAlive: Bool = false

    /// Initialize
    ///
    /// - Parameters:
    ///   - request: The *request*.
    ///
    public init(_ request: [UInt8] = []) {
        self.request = request
    }

    /// Set iTag type to perform read/write to the tag
    ///
    /// - Parameters:
    ///   - type: The *type* to be used.
    ///
    public func setType(_ type: ITagNfcType) {
        self.type = type
    }

    /// Start action to the tag
    ///
    /// - Parameters:
    ///   - message: The *message* to be display in NFC modal
    ///
    public func start(_ message: String) {
        session = NFCTagReaderSession(pollingOption: .iso14443, delegate: self)
        session?.alertMessage = message
        session?.begin()
    }
    
    /// Upate request
    ///
    /// - Parameters:
    ///   - request: The *request*
    ///
    func updateRequest(_ request: [UInt8]) {
        self.request = request
    }
    
    /// Upate session
    ///
    /// - Parameters:
    ///   - request: The *request*
    ///
    func updateSession(status: Bool) {
        keepSessionAlive = status
        
        if !keepSessionAlive {
            session?.invalidate()
            session = nil
            tag = nil
        }
    }

    // MARK: - NFCNDEFReaderSessionDelegate

    /// Gets called when a session becomes invalid.  At this point the client is expected to discard the returned session object.
    ///
    /// - Parameters:
    ///   - session:    The session object that is invalidated.
    ///   - error:      The error indicates the invalidation reason.
    public func readerSession(_ session: NFCTagReaderSession, didInvalidateWithError error: Error) {
        if let readerError = error as? NFCReaderError {
            // Show an alert when the invalidation reason is not because of a
            // successful read during a single-tag read session, or because the
            // user canceled a multiple-tag read session from the UI or
            // programmatically using the invalidate method call.
            if (readerError.code != .readerSessionInvalidationErrorFirstNDEFTagRead)
                && (readerError.code != .readerSessionInvalidationErrorUserCanceled) {
                guard let type else {
                    return
                }

                switch type {
                case .getFlightData:
                    delegate?.iTagNfcGetFlightData(results: nil, error: .tagReaderError(readerError))
                case .getTagData:
                    delegate?.iTagNfcGetTagData(results: nil, error: .tagReaderError(readerError))
                case .updateData:
                    delegate?.iTagNfcUpdateData(isSuccess: false, error: .tagReaderError(readerError), info: nil)
                case .updateLayout:
                    delegate?.iTagNfcUpdateLayout(isSuccess: false, error: .tagReaderError(readerError))
                }
            }
        }

        // To read new tags, a new session instance is required.
        self.session = nil
    }

    /// Gets called when the NFC reader session has become active. RF is enabled and reader is scanning for tags.
    /// The `tagReaderSession(_:didDetect:)` will be called when a tag is detected.
    ///
    /// - Parameters:
    ///   - session:    The session object in the active state.
    public func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) {
        print("Session Begun!")
    }

    /// Gets called when a session becomes invalid.  At this point the client is expected to discard the returned session object.
    ///
    /// - Parameters:
    ///   - session:    The session object that is invalidated.
    ///   - error:      The error indicates the invalidation reason.
    public func tagReaderSession(_ session: NFCTagReaderSession, didInvalidateWithError error: Error) {
        print("Tag Reader Session Closed with Reason: \(error.localizedDescription)")
    }

    /// Gets called when the reader detects NFC tag(s) in the polling sequence.
    ///
    /// - Parameters:
    ///   - session:   The session object used for tag detection.
    ///   - tags:      Array of `NFCTag` objects.
    public func tagReaderSession(_ session: NFCTagReaderSession, didDetect tags: [NFCTag]) {
        if tags.count > 1 {
            self.handleError("More Than One Tag Detected, Please try again", session)
        }

        guard let tag = tags.first else {
            self.handleError("Tag is not valid", session)
            return
        }

        if case let NFCTag.iso7816(tag) = tag {
            session.connect(to: tags.first!) { (error: Error?) in
                guard let type = self.type else {
                    return
                }
                
                self.tag = tag

                guard error == nil else {
                    self.handleError("Connection error. Please try again.", session)
                    return
                }

                switch type {
                case .getFlightData:
                    self.getFlightData(tag, session)
                case .getTagData:
                    self.getTagData(tag, session, completion: { result in
                        switch result {
                        case .success(let response):
                            self.delegate?.iTagNfcGetTagData(results: response, error: nil)
                        case .failure(let error):
                            self.delegate?.iTagNfcGetTagData(results: nil, error: .exception(error))
                        }
                    })
                case .updateData:
                    self.updateData(tag, session, self.request)
                case .updateLayout(let type):
                    self.updateLayout(tag, session, ITagNfcLayout.getHexString(from: type))
                }
            }
        } else {
            self.handleError("Unsupported tag!", session)
        }

    }
}

/// Extensions
extension ITagNfc {

    /// Get Tag data
    ///
    /// - Parameters:
    ///   - tags:          Array of `NFCTag` objects.
    ///   - session:       The session object used for tag detection.
    ///   - completion:    The completion callback.
    func getTagData(
        _ tag: NFCISO7816Tag,
        _ session: NFCTagReaderSession,
        completion: @escaping (Result<TagDataResponse, any Error>) -> Void
    ) {
        let tagDataApdu = TagDataRequest.createRequestCommand(
            originType: TagDataRequest.getTagIdRequest.originType,
            apiVersion: TagDataRequest.getTagIdRequest.apiVersion,
            tagId: TagDataRequest.zeroTagId,
            nOnce: TagDataRequest.zeroNOnce,
            commandId: TagDataRequest.getTagIdRequest.commandId,
            payloadLength: TagDataRequest.zeroPayloadLength,
            signature: TagDataRequest.getTagIdRequest.signature
        )

        sendCommand(tag, session, tagDataApdu, completion: { result in
            switch result {
            case .success(let apdu):
                guard let payload = apdu.payload else {
                    completion(.failure(ITagNfcApduError.missingDataInResponse))
                    return
                }

                let isSuccess = ITagNfcApduResponse.isSuccessResponse(apdu)

                if isSuccess {
                    let tagDataReponse = ITagNfcCommandResponse.getTagDataResponse(from: payload)
                    completion(.success(tagDataReponse))
                } else {
                    completion(.failure(ITagNfcApduError.getError(apdu)))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        })
    }

    /// Send command
    ///
    /// - Parameters:
    ///   - tags:          Array of `NFCTag` objects.
    ///   - session:       The session object used for tag detection.
    ///   - apdu:          The apdu from the tag.
    ///   - completion:    The completion callback.
    ///
    public func sendCommand(_ tag: NFCISO7816Tag, _ session: NFCTagReaderSession, _ apdu: NFCISO7816APDU, completion: @escaping (Result<NFCISO7816ResponseAPDU, any Error>) -> Void) {
        if #available(iOS 14.0, *) {
            tag.sendCommand(apdu: apdu) { result in
                completion(result)
            }
        }
    }
}

/// Extension
extension ITagNfc {

    /// Get flight data
    ///
    /// - Parameters:
    ///   - tags:          Array of `NFCTag` objects.
    ///   - session:       The session object used for tag detection.
    ///
    func getFlightData(
        _ tag: NFCISO7816Tag,
        _ session: NFCTagReaderSession
    ) {
        self.getTagData(tag, session, completion: { result in
            switch result {
            case .success(let response):
                let apdu = TagDataRequest.createRequestCommand(
                    originType: TagDataRequest.getFlightDataRequest.originType,
                    apiVersion: TagDataRequest.getFlightDataRequest.apiVersion,
                    tagId: response.tagId,
                    nOnce: response.nOnce,
                    commandId: TagDataRequest.getFlightDataRequest.commandId,
                    payloadLength: TagDataRequest.zeroPayloadLength,
                    signature: TagDataRequest.getFlightDataRequest.signature
                )

                self.sendCommand(tag, session, apdu, completion: {
                    result in
                    switch result {
                    case .success(let apdu):
                        if ITagNfcApduResponse.isSuccessResponse(apdu) {
                            self.handlegGetFlightDataSuccess(session, apdu)
                        } else {
                            let error = ITagNfcApduError.getError(apdu)
                            self.handlegGetFlightDataError(session, error)
                        }
                    case .failure(let error):
                        self.handlegGetFlightDataError(session, .exception(error))
                    }
                })
            case .failure(let error):
                self.handlegGetFlightDataError(session, .exception(error))
            }
        })
    }

    /// Update layout
    ///
    /// - Parameters:
    ///   - tags:                 Array of `NFCTag` objects.
    ///   - session:              The session object used for tag detection.
    ///   - base64HexString:      The layout hex string.
    func updateLayout(
        _ tag: NFCISO7816Tag,
        _ session: NFCTagReaderSession,
        _ base64HexString: String
    ) {
        self.getTagData(tag, session, completion: { result in
            switch result {
            case .success(let response):
                let payload = TagDataRequest.getBytes(from: base64HexString)
                let apdu = TagDataRequest.createRequestCommand(
                    originType: TagDataRequest.updateLayoutRequest.originType,
                    apiVersion: TagDataRequest.updateLayoutRequest.apiVersion,
                    tagId: response.tagId,
                    nOnce: response.nOnce,
                    commandId: ITagNfcLayout.TwoSectorLayout.commandId,
                    payloadLength: TagDataRequest.getPayloadLength(payload.count),
                    payload: payload,
                    signature: TagDataRequest.updateLayoutRequest.signature
                )

                self.sendCommand(tag, session, apdu, completion: {
                    result in
                    switch result {
                    case .success(let apdu):
                        if ITagNfcApduResponse.isSuccessResponse(apdu) {
                            self.handlegUpdateLayoutSuccess(session, apdu)
                        } else {
                            if ITagNfcApduError.getError(apdu) == .incompleteResponse {
                                self.getPreviousResponse(tag, session, response, completion: { previousResponseResult in
                                    switch previousResponseResult {
                                    case .success(let previousResponseApdu):
                                        ITagNfcApduResponse.isSuccessResponse(previousResponseApdu) ?
                                            self.handlegUpdateLayoutSuccess(session, previousResponseApdu) :
                                            self.handlegUpdateLayoutError(session, ITagNfcApduError.getError(previousResponseApdu))
                                    case .failure(let error):
                                        self.handlegUpdateLayoutError(session, .exception(error))
                                    }
                                })
                            } else {
                                self.handlegUpdateLayoutError(session, ITagNfcApduError.getError(apdu))
                            }
                        }
                    case .failure(let error):
                        self.handlegUpdateLayoutError(session, .exception(error))
                    }
                })
            case .failure(let error):
                self.handlegUpdateLayoutError(session, .exception(error))
            }
        })
    }

    /// Update data
    ///
    /// - Parameters:
    ///   - tags:                 Array of `NFCTag` objects.
    ///   - session:              The session object used for tag detection.
    ///   - nfcRequest:           The nfcRequest to be updated.
    func updateData(
        _ tag: NFCISO7816Tag,
        _ session: NFCTagReaderSession,
        _ nfcRequest: [UInt8]
    ) {
        self.getTagData(tag, session, completion: { result in
            switch result {
            case .success(let response):
                let apdu = TagDataRequest.createRequestCommand(
                    originType: TagDataRequest.updateDataRequest.originType,
                    apiVersion: TagDataRequest.updateDataRequest.apiVersion,
                    tagId: response.tagId,
                    nOnce: response.nOnce,
                    commandId: TagDataRequest.updateDataRequest.commandId,
                    payloadLength: TagDataRequest.getPayloadLength(nfcRequest.count),
                    payload: nfcRequest,
                    signature: TagDataRequest.updateDataRequest.signature
                )

                self.sendCommand(tag, session, apdu, completion: {
                    result in
                    switch result {
                    case .success(let apdu):
                        if ITagNfcApduResponse.isSuccessResponse(apdu) {
                            self.handlegUpdateDataSuccess(session, apdu)
                        } else {
                            if ITagNfcApduError.getError(apdu) == .incompleteResponse {
                                self.getPreviousResponse(tag, session, response, completion: { previousResponseResult in
                                    switch previousResponseResult {
                                    case .success(let previousResponseApdu):
                                        ITagNfcApduResponse.isSuccessResponse(previousResponseApdu) ?
                                            self.handlegUpdateDataSuccess(session, previousResponseApdu) :
                                            self.handlegUpdateDataError(session, ITagNfcApduError.getError(previousResponseApdu))
                                    case .failure(let error):
                                        self.handlegUpdateDataError(session, .exception(error))
                                    }
                                })
                            } else {
                                self.handlegUpdateDataError(session, ITagNfcApduError.getError(apdu))
                            }
                        }
                    case .failure(let error):
                        self.handlegUpdateDataError(session, .exception(error))
                    }
                })
            case .failure(let error):
                self.handlegUpdateDataError(session, .exception(error))
            }
        })
    }
    
    /// Get previous response
    ///
    /// - Parameters:
    ///   - tags:                 Array of `NFCTag` objects.
    ///   - session:              The session object used for tag detection.
    ///   - tagDataResponse:      The tag response from the nfc tag.
    func getPreviousResponse(
        _ tag: NFCISO7816Tag,
        _ session: NFCTagReaderSession,
        _ tagDataResponse: TagDataResponse,
        completion: @escaping (Result<NFCISO7816ResponseAPDU, any Error>) -> Void
    ) {
        print("Executing getPreviousResponse...")
        let apdu = TagDataRequest.createRequestCommand(
            originType: TagDataRequest.getPreviousResponseRequest.originType,
            apiVersion: TagDataRequest.getPreviousResponseRequest.apiVersion,
            tagId: tagDataResponse.tagId,
            nOnce: tagDataResponse.nOnce,
            commandId: TagDataRequest.getPreviousResponseRequest.commandId,
            payloadLength: TagDataRequest.zeroPayloadLength,
            signature: TagDataRequest.getFlightDataRequest.signature
        )

        self.sendCommand(tag, session, apdu, completion: { result in
            completion(result)
        })
    }
}

/// Extension
private extension ITagNfc {
    
    /// Handle invalid response
    ///
    /// - Parameters:
    ///   - session:     The session object used for tag detection.
    ///   - apdu:        The apdu response from the nfc tag.
    func handleInvalidResponse(
        _ session: NFCTagReaderSession,
        _ apdu: NFCISO7816ResponseAPDU
    ) {
        let error = ITagNfcApduError.getError(apdu)
        let message = "Error: \(error.localizedDescription)"
        handleError(message, session)
    }

    /// Handle error case
    ///
    /// - Parameters:
    ///   - message:     The message to be displayed on the tag modal.
    ///   - session:     The session object used for tag detection.
    func handleError(
        _ message: String,
        _ session: NFCTagReaderSession
    ) {
        session.alertMessage = message
        session.invalidate(errorMessage: message)
    }

    /// Handle Success case
    ///
    /// - Parameters:
    ///   - message:     The message to be displayed on the tag modal.
    ///   - session:     The session object used for tag detection.
    func handleSuccess(
        _ message: String,
        _ session: NFCTagReaderSession
    ) {
        session.alertMessage = message
        session.invalidate()
    }
}

/// getFlightData Response Handler
private extension ITagNfc {
    
    /// Get flight data success callback
    ///
    /// - Parameters:
    ///   - session:     The session object used for tag detection.
    ///   - apdu:        The apdu response from the nfc tag.
    func handlegGetFlightDataSuccess(_ session: NFCTagReaderSession, _ apdu: NFCISO7816ResponseAPDU) {
        self.handleSuccess("Get Flight Data Successfully", session)
        let flightData = ITagNfcApduResponse.getPayload(apdu)

        self.delegate?.iTagNfcGetFlightData(results: flightData, error: nil)
    }
    
    /// Get flight data error callback
    ///
    /// - Parameters:
    ///   - session:     The session object used for tag detection.
    ///   - error:       The error response that is returned.
    func handlegGetFlightDataError(_ session: NFCTagReaderSession, _ error: ITagNfcApduError) {
        self.handleError("Error in Getting Flight Data: \(error.localizedDescription)", session)
        self.delegate?.iTagNfcGetFlightData(results: nil, error: error)
    }
}

/// updateLayout Response Handler
private extension ITagNfc {
    
    /// Update layout success callback
    ///
    /// - Parameters:
    ///   - session:     The session object used for tag detection.
    ///   - apdu:        The apdu response from the nfc tag.
    func handlegUpdateLayoutSuccess(_ session: NFCTagReaderSession, _ apdu: NFCISO7816ResponseAPDU) {
        self.handleSuccess("Update Layout Successfully", session)
        self.delegate?.iTagNfcUpdateLayout(isSuccess: true, error: nil)
    }
    
    /// Update layout error callback
    ///
    /// - Parameters:
    ///   - session:     The session object used for tag detection.
    ///   - error:       The error response that is returned.
    func handlegUpdateLayoutError(_ session: NFCTagReaderSession, _ error: ITagNfcApduError) {
        self.handleError("Error in Updating Layout: \(error.localizedDescription)", session)
        self.delegate?.iTagNfcUpdateLayout(isSuccess: false, error: .exception(error))
    }
}

/// updateData Response Handler
private extension ITagNfc {
    
    /// Update data success callback
    ///
    /// - Parameters:
    ///   - session:     The session object used for tag detection.
    ///   - apdu:        The apdu response from the nfc tag.
    func handlegUpdateDataSuccess(_ session: NFCTagReaderSession, _ apdu: NFCISO7816ResponseAPDU) {
        self.handleSuccess("Update Layout Successfully", session)
        self.delegate?.iTagNfcUpdateData(isSuccess: true, error: nil, info: nil)
    }
    
    /// Update data error callback
    ///
    /// - Parameters:
    ///   - session:     The session object used for tag detection.
    ///   - error:       The error response that is returned.
    func handlegUpdateDataError(_ session: NFCTagReaderSession, _ error: ITagNfcApduError) {
        self.handleError("Error in Updating Data: \(error.localizedDescription)", session)
        self.delegate?.iTagNfcUpdateData(isSuccess: false, error: .exception(error), info: nil)
    }
}
