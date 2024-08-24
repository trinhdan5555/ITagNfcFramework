//
//  ITagNfcApduErrorTests.swift
//  ITagNfcApduErrorTests
//
//  Created by atrinh on 3/15/24.
//

import XCTest
import ITagNfcFramework

final class ITagNfcApduErrorTests: XCTestCase {
    
    private var nfcApduError: ITagNfcApduError!

    override func tearDown() {
        nfcApduError = nil
    }

    func testGenericError() throws {
        nfcApduError = ITagNfcApduError.getError(from: ITagNfcApduError.genericErrorCode)
        XCTAssertEqual(nfcApduError, .genericError)
    }

    func testMalformError() throws {
        nfcApduError = ITagNfcApduError.getError(from: ITagNfcApduError.malformErrorCode)
        XCTAssertEqual(nfcApduError, .malformed)
    }
    
    func testUnsupportApiVersionError() throws {
        nfcApduError = ITagNfcApduError.getError(from: ITagNfcApduError.unsupportApiVersionErrorCode)
        XCTAssertEqual(nfcApduError, .unsupportApiVersion)
    }
    
    func testInvalidTagIdError() throws {
        nfcApduError = ITagNfcApduError.getError(from: ITagNfcApduError.invalidTagIdErrorCode)
        XCTAssertEqual(nfcApduError, .invalidTagId)
    }
    
    func testInvalidNonceError() throws {
        nfcApduError = ITagNfcApduError.getError(from: ITagNfcApduError.invalidNonceErrorCode)
        XCTAssertEqual(nfcApduError, .invalidNonce)
    }
    
    func testUnknownCommandIdError() throws {
        nfcApduError = ITagNfcApduError.getError(from: ITagNfcApduError.unknownCommandIdErrorCode)
        XCTAssertEqual(nfcApduError, .unknownCommandId)
    }
    
    func testCommandTooShortError() throws {
        nfcApduError = ITagNfcApduError.getError(from: ITagNfcApduError.commandTooShortErrorCode)
        XCTAssertEqual(nfcApduError, .commandTooShort)
    }
    
    func testInvalidSignatureError() throws {
        nfcApduError = ITagNfcApduError.getError(from: ITagNfcApduError.invalidSignatureErrorCode)
        XCTAssertEqual(nfcApduError, .invalidSignature)
    }
    
    func testIncompleteResponseError() throws {
        nfcApduError = ITagNfcApduError.getError(from: ITagNfcApduError.incompleteResponseErrorCode)
        XCTAssertEqual(nfcApduError, .incompleteResponse)
    }
}
