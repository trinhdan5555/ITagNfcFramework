//
//  ITagNfcApduResponse.swift
//  ITagNfcFramework
//
//  Created by atrinh on 3/22/24.
//

import CoreNFC

public enum ITagNfcApduResponse {
    
    private static let minimumRequiredArrLength = 2

    public static func isSuccessResponse(_ apdu: NFCISO7816ResponseAPDU) -> Bool {
        guard let payload = apdu.payload else {
            return false
        }
        
        return ITagNfcCommandResponse.isSuccessCommandResponse(from: payload)
    }

    /// Get Response from payload
    public static func getResponse(_ payloadArr: [UInt8], flightDataDictionary: inout [ITagFlightDataEnum: String]) {
        guard payloadArr.count > minimumRequiredArrLength else { return }
        
        let dataTypeIndex = 0
        let dataLengthIndex = 1
        let startPosition = dataLengthIndex + 1

        let dataType = Int(payloadArr[dataTypeIndex])
        let dataLength = Int(payloadArr[dataLengthIndex])

        /// The count of the value should start at position 2 because 1st postion is to type, 2nd position is the length of the value
        ///
        
        if let type = ITagFlightDataEnum.getType(dataType),
           startPosition <= dataLength,
           let value = String(bytes: payloadArr[startPosition...(1 + dataLength)], encoding: .utf8) {
            flightDataDictionary[type] = value
            // check for the last element
            if (value.count + startPosition != payloadArr.count) {
                getResponse(Array(payloadArr[(startPosition + dataLength)...]), flightDataDictionary: &flightDataDictionary)
            }
        }
    }

    static func getPayload(_ apdu: NFCISO7816ResponseAPDU) -> ITagNfcFlightData? {
        let minPayloadResponseLength = 10
        
        guard let payload = apdu.payload,
              payload.count > minPayloadResponseLength else {
            return nil
        }

        let bytesArr = [UInt8](payload)
        
        let footersPostion = bytesArr.count - 2

        let payloadArr = Array(bytesArr[minPayloadResponseLength...footersPostion])
        var flightDataDictionary: [ITagFlightDataEnum: String] = [:]

        getResponse(payloadArr, flightDataDictionary: &flightDataDictionary)

        guard flightDataDictionary.count > 0 else {
            return nil
        }

        var destination = ""
        var flightNumber = ""
        var flightDate = ""
        var passengerName = ""
        var pnr = ""
        var barcode = ""
        var journeyStatus = ""
        var destination2 = ""
        var flightDate2 = ""
        var flightNumber2 = ""
        var euIndicator = ""
        var tagOrigin = ""
        var securitySequenceNumber = ""
        var destination3 = ""
        var flightNumber3 = ""
        var flightDate3 = ""

        for (type, value) in flightDataDictionary {
            switch type {
            case .destination:
                destination = value
            case.flightNumber:
                    flightNumber = value
            case.flightDate:
                    flightDate = value
            case.passengerName:
                    passengerName = value
            case.pnr:
                    pnr = value
            case.barcode:
                    barcode = value
            case.journeyStatus:
                    journeyStatus = value
            case.flightDate2:
                    flightDate2 = value
            case.destination2:
                    destination2 = value
            case.flightNumber2:
                    flightNumber2 = value
            case.euIndicator:
                    euIndicator = value
            case.tagOrigin:
                    tagOrigin = value
            case.securitySequenceNumber:
                    securitySequenceNumber = value
            case.destination3:
                    destination3 = value
            case.flightNumber3:
                    flightNumber3 = value
            case.flightDate3:
                    flightDate3 = value
            case .flightTime:
                break
            }
        }

        return ITagNfcFlightData(
            passengerName: passengerName,
            pnr: pnr,
            barcode: barcode,
            journeyStatus: journeyStatus,
            destination: destination,
            destination2: destination2,
            flightDate: flightDate,
            flightDate2: flightDate2,
            flightNumber: flightNumber,
            flightNumber2: flightNumber2,
            euIndicator: euIndicator,
            tagOrigin: tagOrigin,
            securitySequenceNumber: securitySequenceNumber,
            destination3: destination3,
            flightNumber3: flightNumber3,
            flightDate3: flightDate3
        )
    }
}
