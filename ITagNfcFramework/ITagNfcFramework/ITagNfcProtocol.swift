//
//  ITagNfcProtocol.swift
//
//
//  Created by atrinh on 2/29/24.
//

import CoreNFC
import Foundation

/**
  `ITagNfcProtocol`
 */
protocol ITagNfcProtocol {
    /// get Data from NFC Tag
    func getFlightData()

    /// Update data to NFC Tag
    func updateData(_ request: ITagNfcFlightData)
    
    /// Update data to NFC Tag
    func updateData(_ request: [UInt8])

    /// Update layout
    func updateLayout(_ type: ITagNfcLayout.LayoutType)
}
