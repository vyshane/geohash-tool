//
//  LongitudeTests.swift
//  Geohash Tool
//
//  Created by Vy-Shane Sin Fat on 7/11/2014.
//  Copyright (c) 2014 Vy-Shane Sin Fat. All rights reserved.
//

import Cocoa
import XCTest

class LongitudeTests: XCTestCase {

    let accuracy = 0.00001

    func testTo180() {
        XCTAssertEqualWithAccuracy(Longitude.to180(0), 0, accuracy)
        XCTAssertEqualWithAccuracy(Longitude.to180(10), 10, accuracy)
        XCTAssertEqualWithAccuracy(Longitude.to180(-10), -10, accuracy)
        XCTAssertEqualWithAccuracy(Longitude.to180(180), 180, accuracy)
        XCTAssertEqualWithAccuracy(Longitude.to180(-180), -180, accuracy)
        XCTAssertEqualWithAccuracy(Longitude.to180(190), -170, accuracy)
        XCTAssertEqualWithAccuracy(Longitude.to180(-190), 170, accuracy)
        XCTAssertEqualWithAccuracy(Longitude.to180(190 + 360), -170, accuracy)
    }

    func testDifferenceBetween() {
        XCTAssertEqualWithAccuracy(Longitude.differenceBetween(15, and: 5), 10, accuracy)
        XCTAssertEqualWithAccuracy(Longitude.differenceBetween(-175, and: 175), 10, accuracy)
        XCTAssertEqualWithAccuracy(Longitude.differenceBetween(175, and: -175), 10, accuracy)
        XCTAssertEqualWithAccuracy(Longitude.differenceBetween(149, and: 154), 5, accuracy)
    }
}