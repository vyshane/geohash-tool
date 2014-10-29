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

    // MARK: - Geohash Encoding and Decoding

    func testEncode() {
        let location = CLLocationCoordinate2D(latitude: -31.953, longitude: 115.857)
        let geohash = Geohash(center: location, length: 8)

        XCTAssert(geohash.hash() == "qd66hrhk",
            "Encoding latitude -31.953 and longitude 115.857 " + "should result in \"qd66hrhk\"")
    }

    func testDecode() {
        let geohash = Geohash("qd66hrhk")
        let center = geohash.center()

        XCTAssert(String(format: "%.3f", center.latitude) == "-31.953"
            && String(format: "%.3f", center.longitude) == "115.857",
            "Decoding \"qd66hrhk\" should result in lat -31.953 and lon 115.857")
    }


    // MARK: - Finding Adjacent Geohashes

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


    // MARK: - Bounding Box

    func testWidthForHashLength() {
        XCTAssertEqualWithAccuracy(Geohash.widthForHashLength(1), 45.0, 0.00001)
        XCTAssertEqualWithAccuracy(Geohash.widthForHashLength(2), 11.25, 0.00001)
        XCTAssertEqualWithAccuracy(Geohash.widthForHashLength(3), 1.40625, 0.00001)
        XCTAssertEqualWithAccuracy(Geohash.widthForHashLength(4), 0.3515625, 0.00001)
        XCTAssertEqualWithAccuracy(Geohash.widthForHashLength(5), 0.0439453125, 0.00001)
        XCTAssertEqualWithAccuracy(Geohash.widthForHashLength(6), 0.010986328125, 0.00001)
    }

    func testHeightForHashLength() {
        XCTAssertEqualWithAccuracy(Geohash.heightForHashLength(1), 45.0, 0.00001)
        XCTAssertEqualWithAccuracy(Geohash.heightForHashLength(2), 11.25 / 2, 0.00001)
        XCTAssertEqualWithAccuracy(Geohash.heightForHashLength(3), 1.40625, 0.00001)
        XCTAssertEqualWithAccuracy(Geohash.heightForHashLength(4), 0.3515625 / 2, 0.00001)
        XCTAssertEqualWithAccuracy(Geohash.heightForHashLength(5), 0.0439453125, 0.00001)
        XCTAssertEqualWithAccuracy(Geohash.heightForHashLength(6), 0.010986328125 / 2, 0.00001)
    }

    func testContainsLocation() {
        let geohash = Geohash("dre7")
        let center = geohash.center()
        XCTAssertTrue(geohash.containsLocation(center), "Geohash contains own center")

        let location2 = CLLocationCoordinate2D(latitude: center.latitude + 20,
            longitude: center.longitude)
        XCTAssertFalse(geohash.containsLocation(location2))

        let location3 = CLLocationCoordinate2D(latitude: center.latitude,
            longitude: center.longitude + 20)
        XCTAssertFalse(geohash.containsLocation(location3))
    }

    func testContainsNearLongitudeBoundary() {
        let geohash = Geohash(
            center: CLLocationCoordinate2D(latitude: -25, longitude: -179), length: 1)

        XCTAssertFalse(geohash.containsLocation(
            CLLocationCoordinate2D(latitude: -25, longitude: -179)))

        XCTAssertTrue(geohash.containsLocation(
            CLLocationCoordinate2D(latitude: -25, longitude: -178)))
    }
}