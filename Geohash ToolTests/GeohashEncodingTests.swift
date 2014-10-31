//
//  GeohashEncodingTests.swift
//  Geohash Tool
//
//  Created by Vy-Shane Sin Fat on 30/09/2014.
//  Copyright (c) 2014 Vy-Shane Sin Fat. All rights reserved.
//

import Foundation

import Cocoa
import XCTest

class GeohashEncodingTests: XCTestCase {

    let geohashEncoding = Geohash.encoding

    func testIsValidString() {
        XCTAssertTrue(geohashEncoding.isValidString("0123456789bcdefghjkmnpqrstuvwxyz"))
        XCTAssertTrue(geohashEncoding.isValidString(""))
        XCTAssertFalse(geohashEncoding.isValidString("a"))
        XCTAssertFalse(geohashEncoding.isValidString("i"))
        XCTAssertFalse(geohashEncoding.isValidString("l"))
        XCTAssertFalse(geohashEncoding.isValidString("o"))
    }
    
    func testValueForCharacter() {
        switch geohashEncoding.valueForCharacter("0") {
        case Result.Ok(let value):
            XCTAssert(value() == 0, "Value for character \"0\" is 0")
        case .Error:
            XCTAssert(false, "Value for character \"0\" should be 0")
        }

        switch geohashEncoding.valueForCharacter("b") {
        case Result.Ok(let value):
            XCTAssert(value() == 10, "Value for character \"b\" is 10")
        case .Error:
            XCTAssert(false, "Value for character \"b\" should be 10")
        }

        switch geohashEncoding.valueForCharacter("z") {
        case Result.Ok(let value):
            XCTAssert(value() == 31, "Value for character \"z\" is 31")
        case .Error:
            XCTAssert(false, "Value for character \"z\" should be 31")
        }

        switch geohashEncoding.valueForCharacter("a") {
        case Result.Ok(let value):
            XCTAssert(false, "Finding the value for character \"a\" should result in an error")
        case .Error:
            XCTAssert(true, "Finding the value for character \"a\" results in an error")
        }
    }

    func testCharacterForValue() {
        switch geohashEncoding.characterForValue(0) {
        case Result.Ok(let character):
            XCTAssert(character() == "0", "Character for value 0 is \"0\"")
        case .Error:
            XCTAssert(false, "Character for value 0 should be \"0\"")
        }

        switch geohashEncoding.characterForValue(11) {
        case Result.Ok(let character):
            XCTAssert(character() == "c", "Character for value 11 is \"c\"")
        case .Error:
            XCTAssert(false, "Character for value 11 should be \"c\"")
        }

        switch geohashEncoding.characterForValue(31) {
        case Result.Ok(let character):
            XCTAssert(character() == "z", "Character for value 31 is \"c\"")
        case .Error:
            XCTAssert(false, "Character for value 31 should be \"c\"")
        }

        switch geohashEncoding.characterForValue(32) {
        case Result.Ok(let character):
            XCTAssert(false, "Character for value 32 should result in an error")
        case .Error:
            XCTAssert(true, "Character for value 32 results in an error")
        }

        switch geohashEncoding.characterForValue(-1) {
        case Result.Ok(let character):
            XCTAssert(false, "Character for value -1 should result in an error")
        case .Error:
            XCTAssert(true, "Character for value -1 results in an error")
        }
    }
}