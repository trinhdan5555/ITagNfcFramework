//
//  ITagNfcApduError.swift
//  ITagNfcFramework
//
//  Created by atrinh on 3/25/24.
//

import Foundation
import CoreNFC

/**
  The `ITagNfcApduError` enum that contains all different types of errors from the tag and some custom errors
 */
public enum ITagNfcApduError: Error, Equatable, Hashable {
    case genericError
    case malformed
    case unsupportApiVersion
    case invalidTagId
    case invalidNonce
    case unknownCommandId
    case commandTooShort
    case invalidSignature
    case emptyResponse
    case missingDataInResponse
    case incompleteResponse
    case tagReaderError(_ error: NFCReaderError)
    case exception(_ error: Error)
    
    /// Hash function
    ///
    /// - Parameters:
    ///   - hasher: The *hasher*
    ///
    public func hash(into hasher: inout Hasher) {
        return hasher.combine(UUID().uuidString)
    }

    
    /// Confronting Equatable protocol
    ///
    /// - Parameters:
    ///   - lhs: Left parameter.
    ///   - rhs: Right parameter.
    /// - Returns: true/false
    ///
    public static func == (lhs: ITagNfcApduError, rhs: ITagNfcApduError) -> Bool {
        return lhs.errorDescription == rhs.errorDescription && lhs.localizedDescription == rhs.localizedDescription
    }
    
    /// Get Error
    ///
    /// - Parameters:
    ///   - apdu: The *apdu* to get the error.
    /// - Returns: ITagNfcApduError
    ///
    public static func getError(_ apdu: NFCISO7816ResponseAPDU) -> ITagNfcApduError {
        guard let payload = apdu.payload else {
            return .emptyResponse
        }
        
        guard payload.count >= minResponseLength else {
            return .missingDataInResponse
        }
        
        let statusCode = ITagNfcCommandResponse.getStatusCode(from: payload)
        return getError(from: statusCode)
    }
    
    /// Get Error
    ///
    /// - Parameters:
    ///   - statusCode: The *statusCode* to get the error.
    /// - Returns: ITagNfcApduError
    ///
    public static func getError(from statusCode: [UInt8]) -> ITagNfcApduError {
        switch statusCode {
        case genericErrorCode:
            return .genericError
        case malformErrorCode:
            return .malformed
        case unsupportApiVersionErrorCode:
            return .unsupportApiVersion
        case invalidTagIdErrorCode:
            return .invalidTagId
        case invalidNonceErrorCode:
            return .invalidNonce
        case unknownCommandIdErrorCode:
            return .unknownCommandId
        case commandTooShortErrorCode:
            return .commandTooShort
        case invalidSignatureErrorCode:
            return .invalidSignature
        case incompleteResponseErrorCode:
            return .incompleteResponse
        default:
            return .genericError
        }
    }
}

/// Extension for LocalizedError
extension ITagNfcApduError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .genericError:
            return NSLocalizedString(Self.genericErrorDescription, comment: Self.genericErrorDescription)
        case .malformed:
            return NSLocalizedString(Self.malformErrorDescription, comment: Self.malformErrorDescription)
        case .unsupportApiVersion:
            return NSLocalizedString(Self.unsupportApiVersionDescription, comment: Self.unsupportApiVersionDescription)
        case .invalidTagId:
            return NSLocalizedString(Self.invalidTagIdDescription, comment: Self.invalidTagIdDescription)
        case .invalidNonce:
            return NSLocalizedString(Self.invalidNonceDescription, comment: Self.invalidNonceDescription)
        case .unknownCommandId:
            return NSLocalizedString(Self.unknownCommandIdDescription, comment: Self.unknownCommandIdDescription)
        case .commandTooShort:
            return NSLocalizedString(Self.commandTooShortDescription, comment: Self.commandTooShortDescription)
        case .invalidSignature:
            return NSLocalizedString(Self.invalidSignatureDescription, comment: Self.invalidSignatureDescription)
        case .emptyResponse:
            return NSLocalizedString(Self.emptyResponseDescription, comment: Self.emptyResponseDescription)
        case .missingDataInResponse:
            return NSLocalizedString(Self.missingDataInResponseDescription, comment: Self.missingDataInResponseDescription)
        case .incompleteResponse:
            return NSLocalizedString(Self.incompleteResponseDescription, comment: Self.incompleteResponseDescription)
        case .tagReaderError(let error):
            return NSLocalizedString(error.localizedDescription, comment: Self.genericErrorDescription)
        case .exception(let error):
            return NSLocalizedString(error.localizedDescription, comment: Self.genericErrorDescription)
        }
    }
}

/// Extension for static error variables
extension ITagNfcApduError {
    static let minResponseLength = 6
    public static let genericErrorCode: [UInt8] = [0x00, 0x40]
    public static let malformErrorCode: [UInt8] = [0x01, 0x40]
    public static let unsupportApiVersionErrorCode: [UInt8] = [0x02, 0x40]
    public static let invalidTagIdErrorCode: [UInt8] = [0x03, 0x40]
    public static let invalidNonceErrorCode: [UInt8] = [0x04, 0x40]
    public static let unknownCommandIdErrorCode: [UInt8] = [0x05, 0x40]
    public static let commandTooShortErrorCode: [UInt8] = [0x06, 0x40]
    public static let invalidSignatureErrorCode: [UInt8] = [0x07, 0x40]
    public static let incompleteResponseErrorCode: [UInt8] = [0x0A, 0x40]
}

/// Extension for static error variables
extension ITagNfcApduError {
    static let genericErrorDescription = "Generic Error"
    static let malformErrorDescription = "Malformed"
    static let unsupportApiVersionDescription = "Unsupport Api Version"
    static let invalidTagIdDescription = "Invalid Tag Id"
    static let invalidNonceDescription = "Invalid Nonce"
    static let unknownCommandIdDescription = "Unknown Command Id"
    static let commandTooShortDescription = "Command Too Short"
    static let invalidSignatureDescription = "Invalid Signature"
    static let emptyResponseDescription = "Empty Response"
    static let missingDataInResponseDescription = "Missing Response Data"
    static let incompleteResponseDescription = "Incomplete Response"
}
