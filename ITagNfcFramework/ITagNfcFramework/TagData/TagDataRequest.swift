//
//  TagDataRequest.swift
//  ITagNfcFramework
//
//  Created by atrinh on 3/29/24.
//

import CoreNFC
import Foundation

/**
 `TagDataRequestProtocol`
 */
public protocol TagDataRequestProtocol {
    var originType: [UInt8] { get }
    var apiVersion: [UInt8] { get }
    var commandId: [UInt8] { get }
    var signature: [UInt8] { get }
}

/**
 `TagDataRequest`  object class
 */
public struct TagDataRequest: TagDataRequestProtocol {
    /// Static variables
    private static let defaultByte: UInt8 = 0x00
    private static let firstByte: UInt8 = 0x01
    private static let secondByte: UInt8 = 0x02
    private static let thirdByte: UInt8 = 0x03
    private static let fourthByte: UInt8 = 0x04
    private static let apiVersionLength = 3
    private static let signatureLength = 64
    private static let endByteIndicator = 0xFF
    private static let tagIdExpectedlength = 16
    private static let nOnceExpectedlength = 8
    private static let minimumByteLength = 2
    private static let commandIdBaseByte: UInt8 = 0x10
    public static let zeroPayloadLength: [UInt8] = Array(repeating: defaultByte, count: minimumByteLength)
    public static let zeroTagId: [UInt8] = Array(repeating: defaultByte, count: tagIdExpectedlength)
    public static let zeroNOnce: [UInt8] = Array(repeating: defaultByte, count: nOnceExpectedlength)
    
    public let originType: [UInt8] = [firstByte]
    public let apiVersion: [UInt8] = Array(repeating: defaultByte, count: apiVersionLength)
    public let commandId: [UInt8]
    public let signature: [UInt8] = Array(repeating: defaultByte, count: signatureLength)

    /// Get Tag Id request
    ///
    /// - Returns: TagDataRequest
    ///
    public static var getTagIdRequest: Self {
        return TagDataRequest(commandId: [defaultByte, commandIdBaseByte])
    }

    /// Update Layout request
    ///
    /// - Returns: TagDataRequest
    ///
    public static var updateLayoutRequest: Self {
        return TagDataRequest(commandId: [firstByte, commandIdBaseByte])
    }

    /// Get Data request
    ///
    /// - Returns: TagDataRequest
    ///
    public static var updateDataRequest: Self {
        return TagDataRequest(commandId: [secondByte, commandIdBaseByte])
    }

    /// Get Flight Data request
    ///
    /// - Returns: TagDataRequest
    ///
    public static var getFlightDataRequest: Self {
        return TagDataRequest(commandId: [thirdByte, commandIdBaseByte])
    }
    
    /// Get Previous Response request
    ///
    /// - Returns: TagDataRequest
    ///
    public static var getPreviousResponseRequest: Self {
        return TagDataRequest(commandId: [fourthByte, commandIdBaseByte])
    }
}

/// Extension
extension TagDataRequest {

    /// Create request command
    ///
    /// - Parameters:
    ///   - originType: The *originType* byte array.
    ///   - apiVersion: The *apiVersion* byte array.
    ///   - tagId: The *tagId* byte array.
    ///   - nOnce: The *nOnce* byte array.
    ///   - commandId: The *commandId* byte array.
    ///   - payloadLength: The *payloadLength* byte array.
    ///   - payloadLength: The *payloadLength* byte array.
    ///   - signature: The *signature* byte array.
    /// - Returns: NFCISO7816APDU
    ///
    public static func createRequestCommand(
        originType: [UInt8] = [],
        apiVersion: [UInt8] = [],
        tagId: [UInt8] = [],
        nOnce: [UInt8] = [],
        commandId: [UInt8] = [],
        payloadLength: [UInt8] = [],
        payload: [UInt8] = [],
        signature: [UInt8] = []
    ) -> NFCISO7816APDU {
        let requestArr = originType + apiVersion + tagId + nOnce + commandId + payloadLength + payload + signature
        return NFCISO7816APDU(
            instructionClass: firstByte,
            instructionCode: secondByte,
            p1Parameter: thirdByte,
            p2Parameter: fourthByte,
            data: Data(requestArr),
            expectedResponseLength: 16
        )
    }

    /// Get payload length. This method will return the bitshifting to UInt8 to get 2 bytes and return an array of two element.
    ///
    ///
    /// - Parameters:
    ///   - number: The integer number to be converted to [UInt8].
    /// - Returns: [UInt8]
    ///
    public static func getPayloadLength(_ number: Int) -> [UInt8] {
        return [UInt8(number & endByteIndicator), UInt8((number >> 8) & endByteIndicator)]
    }

    /// Get bytes from encoded string
    ///
    /// - Parameters:
    ///   - encodedBase64String: The *encodedBase64String* string  to be converted to [UInt8].
    /// - Returns: [UInt8]
    ///
    public static func getBytes(from encodedBase64String: String) -> [UInt8] {
        guard let base64EncodedData = encodedBase64String.data(using: .utf8),
              let data = Data(base64Encoded: base64EncodedData) else {
            return []
        }

        var arr: [UInt8] = []
        data.forEach { d in
            arr.append(d)
        }

        return arr
    }
}
