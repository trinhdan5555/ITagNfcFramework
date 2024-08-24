//
//  ITagNfcTests.swift
//  ITagNfcFrameworkTests
//
//  Created by atrinh on 4/8/24.
//

import CoreNFC
import ITagNfcFramework
import XCTest


final class ITagNfcTests: XCTestCase, ITagNfcDelegate {
    var expectation: XCTestExpectation? // 2
    private var nfcTag: ITagNfc!
    private var session: NFCTagReaderSession!
    private var isReaderSessionError = false

    override func setUp() {
        session = NFCTagReaderSession(pollingOption: .iso14443, delegate: self)
    }
    
    override func tearDown() {
        nfcTag = nil
        session = nil
        isReaderSessionError = false
        expectation = nil
    }
    
    func startNFC(_ type: ITagNfcType) {
        nfcTag = ITagNfc()
        nfcTag.setType(type)
        nfcTag.delegate = self
        nfcTag.start("Start NFC")
    }

    func testReaderSessionFirstNDEFTagReadErrorForGetFlightData() throws {
        expectation = expectation(description: "Get Flight Data Error")
        startNFC(.getFlightData)
        isReaderSessionError = true
        let error: NFCReaderError = NFCReaderError(NFCReaderError.Code.readerSessionInvalidationErrorSessionTimeout)
        
        nfcTag.readerSession(session, didInvalidateWithError: error)
        waitForExpectations(timeout: 1)
    }
    
    func testReaderSessionErrorForUpdateData() throws {
        expectation = expectation(description: "Update Data Error")
        startNFC(.updateData)
        isReaderSessionError = true
        let error: NFCReaderError = NFCReaderError(NFCReaderError.Code.readerSessionInvalidationErrorSessionTimeout)
        
        nfcTag.readerSession(session, didInvalidateWithError: error)
        waitForExpectations(timeout: 1)
    }
    
    func testReaderSessionErrorForUpdateLayout() throws {
        expectation = expectation(description: "Update Layout Error")
        startNFC(.updateLayout(.oneSectorLayout))
        isReaderSessionError = true
        let error: NFCReaderError = NFCReaderError(NFCReaderError.Code.readerSessionInvalidationErrorSessionTimeout)
        
        nfcTag.readerSession(session, didInvalidateWithError: error)
        waitForExpectations(timeout: 1)
    }
    
    /// ITagNfcDelegate
    func iTagNfcGetFlightData(results: ITagNfcFramework.ITagNfcFlightData?, error: ITagNfcFramework.ITagNfcApduError?) {
        if isReaderSessionError {
            XCTAssertNil(results)
            XCTAssertNotNil(error)
            expectation?.fulfill()
        }
    }
    
    func iTagNfcUpdateData(isSuccess: Bool, error: ITagNfcFramework.ITagNfcApduError?) {
        if isReaderSessionError {
            XCTAssertFalse(isSuccess)
            XCTAssertNotNil(error)
            expectation?.fulfill()
        }
    }
    
    func iTagNfcUpdateLayout(isSuccess: Bool, error: ITagNfcFramework.ITagNfcApduError?) {
        if isReaderSessionError {
            XCTAssertFalse(isSuccess)
            XCTAssertNotNil(error)
            expectation?.fulfill()
        }
    }

}

extension ITagNfcTests: NFCTagReaderSessionDelegate {
    func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) {}
    
    func tagReaderSession(_ session: NFCTagReaderSession, didInvalidateWithError error: any Error) {}
    
    func tagReaderSession(_ session: NFCTagReaderSession, didDetect tags: [NFCTag]) {}
}
