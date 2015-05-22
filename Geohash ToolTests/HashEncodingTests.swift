//
//  HashEncodingTests.swift
//  Geohash Tool
//
//  Created by Vy-Shane Sin Fat on 30/09/2014.
//  Copyright (c) 2014 Vy-Shane Sin Fat. All rights reserved.
//

import Foundation

import Cocoa
import XCTest

class HashEncodingTests: XCTestCase {

    let encoding = HashEncoding("0123456789bcdefghjkmnpqrstuvwxyz")

    func testIsValidString() {
        XCTAssertTrue(encoding.isValidString("0123456789bcdefghjkmnpqrstuvwxyz"))
        XCTAssertTrue(encoding.isValidString(""))
        XCTAssertFalse(encoding.isValidString("a"))
        XCTAssertFalse(encoding.isValidString("i"))
        XCTAssertFalse(encoding.isValidString("l"))
        XCTAssertFalse(encoding.isValidString("o"))
    }
    
    func testValueForCharacter() {
        XCTAssert(encoding.valueForCharacter("0") == 0)
        XCTAssert(encoding.valueForCharacter("b") == 10)
        XCTAssert(encoding.valueForCharacter("z") == 31)
        XCTAssert(encoding.valueForCharacter("a") == nil)
    }

    func testCharacterForValue() {
        XCTAssert(encoding.characterForValue(0) == "0")
        XCTAssert(encoding.characterForValue(11) == "c")
        XCTAssert(encoding.characterForValue(31) == "z")
        XCTAssert(encoding.characterForValue(32) == nil)
        XCTAssert(encoding.characterForValue(-1) == nil)
    }
}