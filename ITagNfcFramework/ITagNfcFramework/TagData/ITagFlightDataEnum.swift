//
//  ITagFlightDataEnum.swift
//  ITagNfcFramework
//
//  Created by atrinh on 3/10/24.
//

import Foundation

public enum ITagFlightDataEnum: Int {
    case destination = 1
    case flightNumber = 2
    case flightDate = 3
    case flightTime = 4
    case passengerName = 5
    case pnr = 6
    case barcode = 7
    case euIndicator = 8
    case journeyStatus = 9
    case tagOrigin = 10
    case securitySequenceNumber = 11
    case destination2 = 12
    case flightDate2 = 14
    case flightNumber2 = 13
    case destination3 = 15
    case flightNumber3 = 16
    case flightDate3 = 17

    public var value: Int {
        return self.rawValue
    }

    public static func getType(_ number: Int) -> Self? {
        return Self(rawValue: number)
    }

    public var name: String {
        return String(describing: self)
    }
}
