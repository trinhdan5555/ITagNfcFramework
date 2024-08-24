//
//  ITagNfcType.swift
//
//
//  Created by atrinh on 3/5/24.
//

import CoreNFC

public enum ITagNfcType {
    case getFlightData
    case getTagData
    case updateData
    case updateLayout(_ type: ITagNfcLayout.LayoutType)
}
