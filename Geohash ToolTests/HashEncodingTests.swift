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
        switch encoding.valueForCharacter("0") {
        case Result.Ok(let value):
            XCTAssert(value() == 0, "Value for character \"0\" is 0")
        case .Error:
            XCTFail("Value for character \"0\" should be 0")
        }

        switch encoding.valueForCharacter("b") {
        case Result.Ok(let value):
            XCTAssert(value() == 10, "Value for character \"b\" is 10")
        case .Error:
            XCTFail("Value for character \"b\" should be 10")
        }

        switch encoding.valueForCharacter("z") {
        case Result.Ok(let value):
            XCTAssert(value() == 31, "Value for character \"z\" is 31")
        case .Error:
            XCTFail("Value for character \"z\" should be 31")
        }

        switch encoding.valueForCharacter("a") {
        case Result.Ok(let value):
            XCTFail("Finding the value for character \"a\" should result in an error")
        case .Error:
            XCTAssert(true, "Finding the value for character \"a\" results in an error")
        }
    }

    func testCharacterForValue() {
        switch encoding.characterForValue(0) {
        case Result.Ok(let character):
            XCTAssert(character() == "0", "Character for value 0 is \"0\"")
        case .Error:
            XCTFail("Character for value 0 should be \"0\"")
        }

        switch encoding.characterForValue(11) {
        case Result.Ok(let character):
            XCTAssert(character() == "c", "Character for value 11 is \"c\"")
        case .Error:
            XCTFail("Character for value 11 should be \"c\"")
        }

        switch encoding.characterForValue(31) {
        case Result.Ok(let character):
            XCTAssert(character() == "z", "Character for value 31 is \"c\"")
        case .Error:
            XCTFail("Character for value 31 should be \"c\"")
        }

        switch encoding.characterForValue(32) {
        case Result.Ok(let character):
            XCTFail("Character for value 32 should result in an error")
        case .Error:
            XCTAssert(true, "Character for value 32 results in an error")
        }

        switch encoding.characterForValue(-1) {
        case Result.Ok(let character):
            XCTFail("Character for value -1 should result in an error")
        case .Error:
            XCTAssert(true, "Character for value -1 results in an error")
        }
    }
}