//
//  GeohashTests.swift
//  Geohash Tool
//
//  Created by Vy-Shane Sin Fat on 1/10/2014.
//  Copyright (c) 2014 Vy-Shane Sin Fat. All rights reserved.
//

import Cocoa
import XCTest
import CoreLocation

class GeohashTests: XCTestCase {

    func testDecode() {
        let geohash = Geohash("qd66hrhk")
        let location = geohash.location()

        XCTAssert(String(format: "%.3f", location.latitude) == "-31.953"
            && String(format: "%.3f", location.longitude) == "115.857",
            "Decoding \"qd66hrhk\" should result in lat -31.953 and lon 115.857")
    }

    func testEncode() {
        let location = CLLocationCoordinate2D(latitude: -31.953, longitude: 115.857)
        let geohash = Geohash(location: location, length: 8)

        XCTAssert(geohash.stringValue == "qd66hrhk",
            "Encoding latitude -31.953 and longitude 115.857 " + "should result in \"qd66hrhk\"")
    }

    func testGeohashAtDirectionRight() {
        XCTAssert(Geohash("u1pb").geohashAtDirection(Direction.Right) == Geohash("u300"),
            "Geohash at the right of u1pb is u300")

        XCTAssert(Geohash("u1pb").right() == Geohash("u300"),
            "Geohash at the right of u1pb is u300")
    }

    func testGeohashAtDirectionLeft() {
        XCTAssert(Geohash("u1pb").geohashAtDirection(Direction.Left) == Geohash("u1p8"),
            "Geohash at the left of u1pb is u1p8")

        XCTAssert(Geohash("u1pb").left() == Geohash("u1p8"),
            "Geohash at the left of u1pb is u1p8")
    }

    func testGeohashAtDirectionTop() {
        XCTAssert(Geohash("u1pb").geohashAtDirection(Direction.Top) == Geohash("u1pc"),
            "Geohash at the top of u1pb is u1pc")

        XCTAssert(Geohash("u1pb").top() == Geohash("u1pc"),
            "Geohash at the top of u1pb is u1pc")
    }

    func testGeohashAtDirectionBottom() {
        XCTAssert(Geohash("u1pb").geohashAtDirection(Direction.Bottom) == Geohash("u0zz"),
            "Geohash at the bottom of u1pb is u0zz")

        XCTAssert(Geohash("u1pb").bottom() == Geohash("u0zz"),
            "Geohash at the bottom of u1pb is u0zz")
    }
}