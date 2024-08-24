//
//  ITagNfcLayout.swift
//  ITagNfcFramework
//
//  Created by atrinh on 3/29/24.
//

import Foundation

public struct ITagNfcLayout {
    
    public enum LayoutType {
        case oneSectorLayout
        case twoSectorLayout
    }
    
    public let type: LayoutType
    public let commandId: [UInt8]
    public let base64HexString: String
    public static let commandId: [UInt8] = [0x01, 0x10]
    
    public static var OneSectorLayout: ITagNfcLayout {
        return ITagNfcLayout(type: .oneSectorLayout, commandId: commandId, base64HexString: "AgcAAAAAGAHyAAEC/wAKAQAAAAMS+gAtABgBxQAAAAAAAAAAAAABB/8AMgATAcAAAQBDQjI0CgEAAxIZAJUB/wCXAQEAAAAAAAAAAAIHAACsARgB4AEAAjQACgAAAAADCAAANgEbAOABAQAAAAAAAAAAAwj9ADYBGAHgAQEAAAAAAAAAAAMVUACsAcgAwAEBAAAAAAAAAAABCVAApgHIAMQBAABDQjI0CgAAAQEAAPIAGAFaAQAAUk1DNQoBAAECAABSARgBhgEAAENCNDgKAQABBQAAfAEYAZoBAABDQjI0CgEAAQMbAJYBjACqAQAAQ0IyNAoBAAEGjACWAf0AqgEAAENCMjQKAQA=")
    }
    
    public static var TwoSectorLayout: ITagNfcLayout {
        return ITagNfcLayout(type: .twoSectorLayout, commandId: [0x01, 0x10], base64HexString: "AgcAAAAAGAHwAAEC/wAKAQAAAAMS+gAtABgBxQAAAAAAAAAAAAABB/8AMgATAcAAAQBDQjI0CgEAAxIZAPAA/wCWAQEAAAAAAAAAAAMSGwDyAP0AQwEAAAAAAAAAAAADEhsARQH9AJQBAAAAAAAAAAAAAgcAAKwBGAHgAQACNAAKAAAAAAMIAAA2ARsA4AEBAAAAAAAAAAADCP0ANgEYAeABAQAAAAAAAAAAAxVQAKwByADAAQEAAAAAAAAAAAEJUACmAcgAxAEAAENCMjQKAAABAQAA8wAYAT8BAABSTTkwCgEAAQLXADkB/QBDAQAAQ0IxMgoBAAEFAACWARgBqgEAAENCMjQKAQABAxsAOQFBAEMBAABDQjEyCgEAAQwAAEYBGAGSAQAAUk05MAoBAAEN1wCKAf0AlAEAAENCMTIKAQABDhsAigFBAJQBAABDQjEyCgEA")
    }
}

extension ITagNfcLayout {
    public static func getHexString(from type: ITagNfcLayout.LayoutType) -> String {
        switch type {
        case .oneSectorLayout:
            return ITagNfcLayout.OneSectorLayout.base64HexString
        case .twoSectorLayout:
            return ITagNfcLayout.TwoSectorLayout.base64HexString
        }
    }
}
