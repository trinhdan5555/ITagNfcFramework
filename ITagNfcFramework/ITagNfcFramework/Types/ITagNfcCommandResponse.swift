//
//  ITagNfcCommandResponse.swift
//  ITagNfcFramework
//
//  Created by atrinh on 5/3/24.
//

import Foundation

public struct ITagNfcCommandResponse {
    var headers: [UInt8] = []
    var statusCode: [UInt8] = []
    var commadId: [UInt8] = []
    
    static let successResponseCode: [UInt8] = [0x00, 0x20]
    // headers
    static let headersStartIndex = 0
    static let headersEndIndex = 1
    
    // status code
    static let statusCodeStartIndex = 2
    static let statusCodeEndIndex = 3
    
    // coommand id
    static let commandIdStartIndex = 4
    static let commandIdEndIndex = 5
    
    // Tag Id
    static let tagIdStartIndex = 7
    static let tagIdEndIndex = 22
    
    // n-Once
    static let nOnceStartIndex = 23
    static let nOnceEndIndex = 30
}

extension ITagNfcCommandResponse {
    static func getCommandResponse(from payload: Data) -> ITagNfcCommandResponse {
        var headers: [UInt8] = []
        var statusCode: [UInt8] = []
        var commadId: [UInt8] = []

        for (index, element) in payload.enumerated() {
            if headersStartIndex ... headersEndIndex ~= index {
                headers.append(element)
            } else if statusCodeStartIndex ... statusCodeEndIndex ~= index {
                statusCode.append(element)
            } else if commandIdStartIndex ... commandIdEndIndex ~= index {
                commadId.append(element)
            }
        }
        
        return ITagNfcCommandResponse(headers: headers, statusCode: statusCode, commadId: commadId)
    }
    
    static func getStatusCode(from payload: Data) -> [UInt8] {
        return getCommandResponse(from: payload).statusCode
    }
    
    static func isSuccessCommandResponse(from payload: Data) -> Bool {
        return getStatusCode(from: payload) == successResponseCode
    }
    
    static func getTagDataResponse(from payload: Data) -> TagDataResponse {
        var tagId: [UInt8] = []
        var nOnce: [UInt8] = []

        for (index, element) in payload.enumerated() {
            if tagIdStartIndex ... tagIdEndIndex ~= index {
                tagId.append(element)
            } else if nOnceStartIndex ... nOnceEndIndex ~= index {
                nOnce.append(element)
            }
        }
        
        return TagDataResponse(tagId: tagId, nOnce: nOnce)
    }
}
