//
//  TagDataRequestTests.swift
//  ITagNfcFrameworkTests
//
//  Created by atrinh on 4/7/24.
//

import XCTest
import ITagNfcFramework

final class TagDataRequestTests: XCTestCase {
    
    private let validPayloadArr: [UInt8] = [144, 0, 0, 32, 0, 16, 25, 0, 0, 0, 0, 0, 0, 64, 0,160, 0 , 0 , 0 , 0, 69, 66, 84, 239, 205, 171, 137, 103, 69, 35, 1, 100]
    
    
    private let invalidPayloadArr: [UInt8] = [144, 0, 0, 42, 0]
    
    func testBaseRequest() throws {
        let request = TagDataRequest.getTagIdRequest
        XCTAssertEqual(request.originType.count, 1)
        XCTAssertEqual(request.apiVersion.count, 3)
        XCTAssertEqual(request.signature.count, 64)
    }
    
    func testGetTagIdRequest() throws {
        let request = TagDataRequest.getTagIdRequest
        XCTAssertEqual(request.commandId, [0x00, 0x10])
    }
    
    func testUpdateLayoutRequest() throws {
        let request = TagDataRequest.updateLayoutRequest
        XCTAssertEqual(request.commandId, [0x01, 0x10])
    }
    
    func testUpdateDataRequest() throws {
        let request = TagDataRequest.updateDataRequest
        XCTAssertEqual(request.commandId, [0x02, 0x10])
    }
    
    func testGetFlightDataRequest() throws {
        let request = TagDataRequest.getFlightDataRequest
        XCTAssertEqual(request.commandId, [0x03, 0x10])
    }
    
    func testGetBytesFromInvalidBase64String() throws {
        let response = TagDataRequest.getBytes(from: "123")
        XCTAssertTrue(response.count == 0)
    }
    
    func testGetBytesFromValidBase64String() throws {
        let response = TagDataRequest.getBytes(from: ITagNfcLayout.OneSectorLayout.base64HexString)
        XCTAssertTrue(response.count > 0)
    }

}
