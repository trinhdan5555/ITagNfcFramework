//
//  ITagNfcFlightData.swift
//
//
//  Created by atrinh on 3/5/24.
//

import Foundation

public struct ITagNfcFlightData: Codable, Equatable {
    public let passengerName: String
    public let pnr: String
    public let barcode: String
    public let journeyStatus: String
    public let destination: String
    public let destination2: String?
    public let flightDate: String
    public let flightDate2: String?
    public let flightNumber: String
    public let flightNumber2: String?
    public let euIndicator: String?
    public let tagOrigin: String?
    public let securitySequenceNumber: String?
    public let destination3: String?
    public let flightNumber3: String?
    public let flightDate3: String?

    public init(
        passengerName: String,
        pnr: String,
        barcode: String,
        journeyStatus: String,
        destination: String,
        destination2: String? = nil,
        flightDate: String,
        flightDate2: String? = nil,
        flightNumber: String,
        flightNumber2: String? = nil,
        euIndicator: String? = nil,
        tagOrigin: String? = nil,
        securitySequenceNumber: String? = nil,
        destination3: String? = nil,
        flightNumber3: String? = nil,
        flightDate3: String? = nil
    ) {
        self.passengerName = passengerName
        self.pnr = pnr
        self.barcode = barcode
        self.journeyStatus = journeyStatus
        self.destination = destination
        self.destination2 = destination2
        self.flightDate = flightDate
        self.flightDate2 = flightDate2
        self.flightNumber = flightNumber
        self.flightNumber2 = flightNumber2
        self.euIndicator = euIndicator
        self.tagOrigin = tagOrigin
        self.securitySequenceNumber = securitySequenceNumber
        self.destination3 = destination3
        self.flightNumber3 = flightNumber3
        self.flightDate3 = flightDate3
    }

    public static func ==(lhs: Self, rhs: Self) -> Bool {
        return lhs.passengerName == rhs.passengerName
        && lhs.pnr == rhs.pnr
        && lhs.barcode == rhs.barcode
        && lhs.journeyStatus == rhs.journeyStatus
        && lhs.flightNumber == rhs.flightNumber
    }

    public enum ITagNfcFlightDataError: Error {
        case invalidPassengerName
        case invalidPnr
        case invalidBarcode
        case invalidJourneyStatus
        case invalidDestination
        case invalidDestinationLength
        case invalidFlightDate
        case invalidFlightDateLength
        case invalidFlightNumber
        case invalidFlightNumberLength

        public var description: String {
            switch self {
            case .invalidPassengerName:
                return "Invalid passenger name"
            case .invalidPnr:
                return "Invalid passenger name record"
            case .invalidBarcode:
                return "Invalid barcode"
            case .invalidJourneyStatus:
                return "Invalid journey status"
            case .invalidDestination:
                return "Invalid destination"
            case .invalidDestinationLength:
                return "Destination length should be \(destinationLength)"
            case .invalidFlightDate:
                return "Invalid flight date"
            case .invalidFlightDateLength:
                return "Flight date length should be \(flightDateLength) (e.g. 05Dec)"
            case .invalidFlightNumber:
                return "Invalid flight number"
            case .invalidFlightNumberLength:
                return "Flight number length should be from \(flightNumberLengthMin) to \(flightNumberLengthMax)"
            }
        }
    }

    public func validate() throws {
        if passengerName.isEmpty {
            throw ITagNfcFlightDataError.invalidPassengerName
        }

        if pnr.isEmpty {
            throw ITagNfcFlightDataError.invalidPnr
        }

        if barcode.isEmpty {
            throw ITagNfcFlightDataError.invalidBarcode
        }

        if journeyStatus.isEmpty {
            throw ITagNfcFlightDataError.invalidJourneyStatus
        }

        if destination.isEmpty {
            throw ITagNfcFlightDataError.invalidDestination
        } else if destination.count != ITagNfcFlightData.destinationLength {
            throw ITagNfcFlightDataError.invalidDestinationLength
        }

        if flightDate.isEmpty {
            throw ITagNfcFlightDataError.invalidFlightDate
        } else if flightDate.count != ITagNfcFlightData.flightDateLength {
            throw ITagNfcFlightDataError.invalidDestinationLength
        }

        if flightNumber.isEmpty {
            throw ITagNfcFlightDataError.invalidFlightNumber
        } else if !(ITagNfcFlightData.flightNumberLengthMin...ITagNfcFlightData.flightNumberLengthMax).contains(flightNumber.count) {
            throw ITagNfcFlightDataError.invalidFlightNumberLength
        }

        if destination2 != nil && ((destination2?.isEmpty) == false) && destination2?.count != ITagNfcFlightData.destinationLength {
            throw ITagNfcFlightDataError.invalidDestinationLength
        }

        if flightDate2 != nil && ((flightDate2?.isEmpty) == false) && flightDate2?.count != ITagNfcFlightData.flightDateLength {
            throw ITagNfcFlightDataError.invalidFlightDateLength
        }

        if flightNumber2 != nil && ((flightNumber2?.isEmpty) == false) && !(ITagNfcFlightData.flightNumberLengthMin...ITagNfcFlightData.flightNumberLengthMax).contains(flightNumber2?.count ?? 0) {
            throw ITagNfcFlightDataError.invalidFlightNumberLength
        }

        if destination3 != nil && ((destination3?.isEmpty) == false) && destination3?.count != ITagNfcFlightData.destinationLength {
            throw ITagNfcFlightDataError.invalidDestinationLength
        }

        if flightDate3 != nil && ((flightDate3?.isEmpty) == false) && flightDate3?.count != ITagNfcFlightData.flightDateLength {
            throw ITagNfcFlightDataError.invalidFlightDateLength
        }

        if flightNumber3 != nil && ((flightNumber3?.isEmpty) == false) && !(ITagNfcFlightData.flightNumberLengthMin...ITagNfcFlightData.flightNumberLengthMax).contains(flightNumber3?.count ?? 0) {
            throw ITagNfcFlightDataError.invalidFlightNumberLength
        }
    }

    public func getUInt8ArrayFrom(value: String, type: ITagFlightDataEnum) -> [UInt8] {
        let str = value
        let valueFromType = type.value
        let count = str.count
        let bytes: [UInt8] = Array(str.utf8)

        return [UInt8(valueFromType) as UInt8, UInt8(count)] + bytes
    }

    public func getAllUInt8Array() -> [UInt8] {
        var arr: [UInt8] = []

        let passengerName = getUInt8ArrayFrom(value: passengerName, type: .passengerName)
        let pnrUInt8Arr = getUInt8ArrayFrom(value: pnr, type: .pnr)
        let barcodeUInt8Arr = getUInt8ArrayFrom(value: barcode, type: .barcode)
        let journeyStatusUInt8Arr = getUInt8ArrayFrom(value: journeyStatus, type: .journeyStatus)
        let destination1UInt8Arr = getUInt8ArrayFrom(value: destination, type: .destination)
        let flightDate1UInt8Arr = getUInt8ArrayFrom(value: flightDate, type: .flightDate)
        let flightNumber1UInt8Arr = getUInt8ArrayFrom(value: flightNumber, type: .flightNumber)

        arr = passengerName + pnrUInt8Arr + barcodeUInt8Arr + journeyStatusUInt8Arr + destination1UInt8Arr + flightDate1UInt8Arr + flightNumber1UInt8Arr

        if let destination2 = destination2, !destination2.isEmpty {
            arr += getUInt8ArrayFrom(value: destination2, type: .destination2)
        }

        if let flightDate2 = flightDate2, !flightDate2.isEmpty {
            arr += getUInt8ArrayFrom(value: flightDate2, type: .flightDate2)
        }

        if let flightNumber2 = flightNumber2, !flightNumber2.isEmpty {
            arr += getUInt8ArrayFrom(value: flightNumber2, type: .flightNumber2)
        }

        if let destination3 = destination3, !destination3.isEmpty {
            arr += getUInt8ArrayFrom(value: destination3, type: .destination3)
        }

        if let flightDate3 = flightDate3, !flightDate3.isEmpty {
            arr += getUInt8ArrayFrom(value: flightDate3, type: .flightDate3)
        }

        if let flightNumber3 = flightNumber3, !flightNumber3.isEmpty {
            arr += getUInt8ArrayFrom(value: flightNumber3, type: .flightNumber3)
        }

        if let euIndicator = euIndicator, !euIndicator.isEmpty {
            arr += getUInt8ArrayFrom(value: euIndicator, type: .euIndicator)
        }

        if let tagOrigin = tagOrigin, !tagOrigin.isEmpty {
            arr += getUInt8ArrayFrom(value: tagOrigin, type: .tagOrigin)
        }

        if let securitySequenceNumber = securitySequenceNumber, !securitySequenceNumber.isEmpty {
            arr += getUInt8ArrayFrom(value: securitySequenceNumber, type: .securitySequenceNumber)
        }

        // add [UInt8(255)] to indicate this is the end
        return arr + [UInt8(Self.endDataIndication)]
    }
}

extension ITagNfcFlightData {
    static let flightDateLength = 5
    static let destinationLength = 3
    static let flightNumberLengthMin = 5
    static let flightNumberLengthMax = 6
    static let endDataIndication = 255
}
