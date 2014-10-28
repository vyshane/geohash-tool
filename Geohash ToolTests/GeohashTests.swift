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
        let center = geohash.center()

        XCTAssert(String(format: "%.3f", center.latitude) == "-31.953"
            && String(format: "%.3f", center.longitude) == "115.857",
            "Decoding \"qd66hrhk\" should result in lat -31.953 and lon 115.857")
    }

    func testEncode() {
        let location = CLLocationCoordinate2D(latitude: -31.953, longitude: 115.857)
        let geohash = Geohash(center: location, length: 8)

        XCTAssert(geohash.hash() == "qd66hrhk",
            "Encoding latitude -31.953 and longitude 115.857 " + "should result in \"qd66hrhk\"")
    }

    func testGeohashAtDirectionRight() {
        XCTAssert(Geohash("u1pb").neighborAtDirection(Direction.Right) == Geohash("u300"),
            "Geohash at the right of u1pb is u300")

        XCTAssert(Geohash("u1pb").rightNeighbor() == Geohash("u300"),
            "Geohash at the right of u1pb is u300")
    }

    func testGeohashAtDirectionLeft() {
        XCTAssert(Geohash("u1pb").neighborAtDirection(Direction.Left) == Geohash("u1p8"),
            "Geohash at the left of u1pb is u1p8")

        XCTAssert(Geohash("u1pb").leftNeighbor() == Geohash("u1p8"),
            "Geohash at the left of u1pb is u1p8")
    }

    func testGeohashAtDirectionTop() {
        XCTAssert(Geohash("u1pb").neighborAtDirection(Direction.Top) == Geohash("u1pc"),
            "Geohash at the top of u1pb is u1pc")

        XCTAssert(Geohash("u1pb").topNeighbor() == Geohash("u1pc"),
            "Geohash at the top of u1pb is u1pc")
    }

    func testGeohashAtDirectionBottom() {
        XCTAssert(Geohash("u1pb").neighborAtDirection(Direction.Bottom) == Geohash("u0zz"),
            "Geohash at the bottom of u1pb is u0zz")

        XCTAssert(Geohash("u1pb").bottomNeighbor() == Geohash("u0zz"),
            "Geohash at the bottom of u1pb is u0zz")
    }
}