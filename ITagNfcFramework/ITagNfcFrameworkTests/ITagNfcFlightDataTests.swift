//
//  ITagNfcFlightDataTests.swift
//  ITagNfcFrameworkTests
//
//  Created by atrinh on 4/6/24.
//

import XCTest
import ITagNfcFramework

final class ITagNfcFlightDataTests: XCTestCase {
    private let passengerName = "Jane Doe"
    private let pnr = "DYH2IB"
    private let barcode = "0123456789"
    private let journeyStatus = "ELITE P1"
    private let destination = "LAX"
    private let flightDate = "05Dec"
    private let flightNumber = "NZ538"
    
    private var itagNfcRequest: ITagNfcFlightData!

    override func setUp() {
        itagNfcRequest = ITagNfcFlightData(
            passengerName: passengerName,
            pnr: pnr,
            barcode: barcode,
            journeyStatus: journeyStatus,
            destination: destination,
            flightDate: flightDate,
            flightNumber: flightNumber
        )
    }

    override func tearDown() {
        itagNfcRequest = nil
    }

    func testValidRequest() throws {
        do {
            try itagNfcRequest.validate()
        } catch {
            XCTFail("Request is not valid")
        }
    }

    func testInvalidPassengerName() throws {
        do {
            itagNfcRequest = ITagNfcFlightData(
                passengerName: "",
                pnr: pnr,
                barcode: barcode,
                journeyStatus: journeyStatus,
                destination: destination,
                flightDate: flightDate,
                flightNumber: flightNumber
            )
            try itagNfcRequest.validate()
        } catch {
            XCTAssertEqual(error as! ITagNfcFlightData.ITagNfcFlightDataError, .invalidPassengerName)
        }
    }
    
    func testInvalidPnr() throws {
        do {
            itagNfcRequest = ITagNfcFlightData(
                passengerName: passengerName,
                pnr: "",
                barcode: barcode,
                journeyStatus: journeyStatus,
                destination: destination,
                flightDate: flightDate,
                flightNumber: flightNumber
            )
            try itagNfcRequest.validate()
        } catch {
            XCTAssertEqual(error as! ITagNfcFlightData.ITagNfcFlightDataError, .invalidPnr)
        }
    }
    
    func testInvalidBarcode() throws {
        do {
            itagNfcRequest = ITagNfcFlightData(
                passengerName: passengerName,
                pnr: pnr,
                barcode: "",
                journeyStatus: journeyStatus,
                destination: destination,
                flightDate: flightDate,
                flightNumber: flightNumber
            )
            try itagNfcRequest.validate()
        } catch {
            XCTAssertEqual(error as! ITagNfcFlightData.ITagNfcFlightDataError, .invalidBarcode)
        }
    }
    
    func testInvalidJourneyStatus() throws {
        do {
            itagNfcRequest = ITagNfcFlightData(
                passengerName: passengerName,
                pnr: pnr,
                barcode: barcode,
                journeyStatus: "",
                destination: destination,
                flightDate: flightDate,
                flightNumber: flightNumber
            )
            try itagNfcRequest.validate()
        } catch {
            XCTAssertEqual(error as! ITagNfcFlightData.ITagNfcFlightDataError, .invalidJourneyStatus)
        }
    }
    
    func testInvalidFDestination() throws {
        do {
            itagNfcRequest = ITagNfcFlightData(
                passengerName: passengerName,
                pnr: pnr,
                barcode: barcode,
                journeyStatus: journeyStatus,
                destination: "",
                flightDate: flightDate,
                flightNumber: flightNumber
            )
            try itagNfcRequest.validate()
        } catch {
            XCTAssertEqual(error as! ITagNfcFlightData.ITagNfcFlightDataError, .invalidDestination)
        }
    }
    
    func testInvalidFlightDate() throws {
        do {
            itagNfcRequest = ITagNfcFlightData(
                passengerName: passengerName,
                pnr: pnr,
                barcode: barcode,
                journeyStatus: journeyStatus,
                destination: destination,
                flightDate: "",
                flightNumber: flightNumber
            )
            try itagNfcRequest.validate()
        } catch {
            XCTAssertEqual(error as! ITagNfcFlightData.ITagNfcFlightDataError, .invalidFlightDate)
        }
    }
    
    func testValidFlightNumber() throws {
        do {
            itagNfcRequest = ITagNfcFlightData(
                passengerName: passengerName,
                pnr: pnr,
                barcode: barcode,
                journeyStatus: journeyStatus,
                destination: destination,
                flightDate: flightDate,
                flightNumber: flightNumber
            )
            try itagNfcRequest.validate()
        } catch {
            XCTAssertEqual(error as! ITagNfcFlightData.ITagNfcFlightDataError, .invalidFlightNumber)
        }
    }
    
    func testGetUInt8Array() throws {
        let expectedPayloadLengthForPassengerName = 10
        var arr = itagNfcRequest.getUInt8ArrayFrom(value: passengerName, type: .passengerName)
        XCTAssertEqual(arr.count, expectedPayloadLengthForPassengerName)
        
        let expectedPayloadLengthForPnr = 8
        arr = itagNfcRequest.getUInt8ArrayFrom(value: pnr, type: .pnr)
        XCTAssertEqual(arr.count, expectedPayloadLengthForPnr)
        
    }
    
    func testGetAllUInt8ArrayWithBaseData() throws {
        let expectedPayloadLength = 60
        let arr = itagNfcRequest.getAllUInt8Array()
        XCTAssertEqual(arr.count, expectedPayloadLength)
        
    }
    
    func testGetAllUInt8ArrayWithOptionalData() throws {
        let expectedPayloadLength = 105
        itagNfcRequest = ITagNfcFlightData(
            passengerName: passengerName,
            pnr: pnr,
            barcode: barcode,
            journeyStatus: journeyStatus,
            destination: destination,
            destination2: "BOS12",
            flightDate: flightDate,
            flightDate2: "Dec 2025",
            flightNumber: flightNumber,
            flightNumber2: "NZ538",
            destination3: "BS538",
            flightNumber3: "NZ539",
            flightDate3: flightDate
        )
        
        let arr = itagNfcRequest.getAllUInt8Array()
        XCTAssertEqual(arr.count, expectedPayloadLength)
        
    }

}
