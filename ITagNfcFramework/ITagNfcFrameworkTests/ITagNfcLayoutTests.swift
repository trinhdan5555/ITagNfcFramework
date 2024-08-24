//
//  ITagNfcLayoutTests.swift
//  ITagNfcFrameworkTests
//
//  Created by atrinh on 4/6/24.
//

import XCTest
import ITagNfcFramework

final class ITagNfcLayoutTests: XCTestCase {

    func testOneSectorLayout() throws {
        let oneSectorLayout = ITagNfcLayout.OneSectorLayout
        XCTAssertEqual(oneSectorLayout.commandId, [0x01, 0x10])
        XCTAssertEqual(oneSectorLayout.type, .oneSectorLayout)
        XCTAssertFalse(oneSectorLayout.base64HexString.isEmpty)
    }

    func testTwoSectorLayout() throws {
        let twoSectorLayout = ITagNfcLayout.TwoSectorLayout
        XCTAssertEqual(twoSectorLayout.commandId, [0x01, 0x10])
        XCTAssertEqual(twoSectorLayout.type, .twoSectorLayout)
        XCTAssertFalse(twoSectorLayout.base64HexString.isEmpty)
    }
    
    func testHexstringForOneSectorLayout() throws {
        let hexString = ITagNfcLayout.getHexString(from: .oneSectorLayout)
        XCTAssertTrue(hexString.contains("0AqgEAAENCMjQKAQA="))
    }
    
    func testHexstringForTwoSectorLayout() throws {
        let hexString = ITagNfcLayout.getHexString(from: .twoSectorLayout)
        XCTAssertTrue(hexString.contains("FBAJQBAABDQjEyCgEA"))
    }

}
