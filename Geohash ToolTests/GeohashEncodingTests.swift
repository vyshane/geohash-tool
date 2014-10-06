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
    
    func testValueForCharacter() {
        switch GeohashEncoding.valueForCharacter("0") {
        case Result.Ok(let value):
            XCTAssert(value() == 0, "Value for character \"0\" is 0")
        case .Error:
            XCTAssert(false, "Value for character \"0\" should be 0")
        }

        switch GeohashEncoding.valueForCharacter("b") {
        case Result.Ok(let value):
            XCTAssert(value() == 10, "Value for character \"b\" is 10")
        case .Error:
            XCTAssert(false, "Value for character \"b\" should be 10")
        }

        switch GeohashEncoding.valueForCharacter("z") {
        case Result.Ok(let value):
            XCTAssert(value() == 31, "Value for character \"z\" is 31")
        case .Error:
            XCTAssert(false, "Value for character \"z\" should be 31")
        }

        switch GeohashEncoding.valueForCharacter("a") {
        case Result.Ok(let value):
            XCTAssert(false, "Finding the value for character \"a\" should result in an error")
        case .Error:
            XCTAssert(true, "Finding the value for character \"a\" results in an error")
        }
    }

    func testCharacterForValue() {
        switch GeohashEncoding.characterForValue(0) {
        case Result.Ok(let character):
            XCTAssert(character() == "0", "Character for value 0 is \"0\"")
        case .Error:
            XCTAssert(false, "Character for value 0 should be \"0\"")
        }

        switch GeohashEncoding.characterForValue(11) {
        case Result.Ok(let character):
            XCTAssert(character() == "c", "Character for value 11 is \"c\"")
        case .Error:
            XCTAssert(false, "Character for value 11 should be \"c\"")
        }

        switch GeohashEncoding.characterForValue(31) {
        case Result.Ok(let character):
            XCTAssert(character() == "z", "Character for value 31 is \"c\"")
        case .Error:
            XCTAssert(false, "Character for value 31 should be \"c\"")
        }

        switch GeohashEncoding.characterForValue(32) {
        case Result.Ok(let character):
            XCTAssert(false, "Character for value 32 should result in an error")
        case .Error:
            XCTAssert(true, "Character for value 32 results in an error")
        }

        switch GeohashEncoding.characterForValue(-1) {
        case Result.Ok(let character):
            XCTAssert(false, "Character for value -1 should result in an error")
        case .Error:
            XCTAssert(true, "Character for value -1 results in an error")
        }
    }
}