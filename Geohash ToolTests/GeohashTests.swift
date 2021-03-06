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

    let accuracy = 0.00001

    // MARK: - Geohash Encoding and Decoding

    func testIsValidHash() {
        XCTAssertTrue(Geohash.isValidHash(""), "Zero-length hash covers the whole world.")
        XCTAssertTrue(Geohash.isValidHash("0123456789bcdefghjkmnpqrstuvwxyz"))
        XCTAssertFalse(Geohash.isValidHash("a"))
        XCTAssertFalse(Geohash.isValidHash("i"))
        XCTAssertFalse(Geohash.isValidHash("l"))
        XCTAssertFalse(Geohash.isValidHash("o"))
    }

    func testEncode() {
        let perthLocation = CLLocationCoordinate2D(latitude: -31.953, longitude: 115.857)
        if let perthGeohash = Geohash(location: perthLocation, length: 8) {
            XCTAssert(perthGeohash.hash() == "qd66hrhk")
        } else {
            XCTFail("Could not initialize geohash")
        }

        let whiteHouseLocation = CLLocationCoordinate2D(latitude: 38.89710201881826,
            longitude: -77.03669792041183)
        XCTAssert(Geohash.encodeLocation(whiteHouseLocation, hashLength: 12) == "dqcjqcp84c6e")
    }

    func testDecode() {
        let perthGeohash = Geohash("qd66hrhk")!
        XCTAssertEqual(String(format: "%.3f", perthGeohash.center().latitude) == "-31.953",
            String(format: "%.3f", perthGeohash.center().longitude) == "115.857")

        let whiteHouseLocation = CLLocationCoordinate2D(latitude: 38.89710201881826,
            longitude: -77.03669792041183)
        let decodedLocation = Geohash.decodeHash("dqcjqcp84c6e")
        XCTAssertEqual(whiteHouseLocation.latitude, decodedLocation.latitude)
        XCTAssertEqual(whiteHouseLocation.longitude, decodedLocation.longitude)
    }


    // MARK: - Finding Adjacent Geohashes

    func testGeohashAtDirectionRight() {
        XCTAssertEqual(Geohash("u1pb")!.neighborAtDirection(Direction.Right), Geohash("u300")!)
        XCTAssertEqual(Geohash("u1pb")!.rightNeighbor(), Geohash("u300")!)
    }

    func testGeohashAtDirectionLeft() {
        XCTAssertEqual(Geohash("u1pb")!.neighborAtDirection(Direction.Left), Geohash("u1p8")!)
        XCTAssertEqual(Geohash("u1pb")!.leftNeighbor(), Geohash("u1p8")!)
    }

    func testGeohashAtDirectionTop() {
        XCTAssertEqual(Geohash("u1pb")!.neighborAtDirection(Direction.Top), Geohash("u1pc")!)
        XCTAssertEqual(Geohash("u1pb")!.topNeighbor(), Geohash("u1pc")!)
    }

    func testGeohashAtDirectionBottom() {
        XCTAssertEqual(Geohash("u1pb")!.neighborAtDirection(Direction.Bottom), Geohash("u0zz")!)
        XCTAssertEqual(Geohash("u1pb")!.bottomNeighbor(), Geohash("u0zz")!)
    }

    func testNeighbors() {
        XCTAssertEqual(
            Geohash("e")!.neighbors(),
            [Geohash("f")!, Geohash("g")!, Geohash("u")!, Geohash("s")!,
                Geohash("k")!, Geohash("7")!, Geohash("6")!, Geohash("d")!]
        )
        XCTAssertEqual(
            Geohash("d3")!.neighbors(),
            [Geohash("d4")!, Geohash("d6")!, Geohash("dd")!, Geohash("d9")!,
                Geohash("d8")!, Geohash("d2")!, Geohash("d0")!, Geohash("d1")!]
        )
    }


    // MARK: - Bounding Box

    func testWidthForHashLength() {
        XCTAssertEqualWithAccuracy(Geohash.widthForHashLength(1), 45.0, accuracy)
        XCTAssertEqualWithAccuracy(Geohash.widthForHashLength(2), 11.25, accuracy)
        XCTAssertEqualWithAccuracy(Geohash.widthForHashLength(3), 1.40625, accuracy)
        XCTAssertEqualWithAccuracy(Geohash.widthForHashLength(4), 0.3515625, accuracy)
        XCTAssertEqualWithAccuracy(Geohash.widthForHashLength(5), 0.0439453125, accuracy)
        XCTAssertEqualWithAccuracy(Geohash.widthForHashLength(6), 0.010986328125, accuracy)
    }

    func testHeightForHashLength() {
        XCTAssertEqualWithAccuracy(Geohash.heightForHashLength(1), 45.0, accuracy)
        XCTAssertEqualWithAccuracy(Geohash.heightForHashLength(2), 11.25 / 2, accuracy)
        XCTAssertEqualWithAccuracy(Geohash.heightForHashLength(3), 1.40625, accuracy)
        XCTAssertEqualWithAccuracy(Geohash.heightForHashLength(4), 0.3515625 / 2, accuracy)
        XCTAssertEqualWithAccuracy(Geohash.heightForHashLength(5), 0.0439453125, accuracy)
        XCTAssertEqualWithAccuracy(Geohash.heightForHashLength(6), 0.010986328125 / 2, accuracy)
    }

    func testContainsLocation() {
        let geohash = Geohash("dre7")!
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
        if let geohash = Geohash(
                location: CLLocationCoordinate2D(latitude: -25, longitude: -179), length: 1) {

            XCTAssertFalse(geohash.containsLocation(
                CLLocationCoordinate2D(latitude: -25, longitude: 179)))

            XCTAssertTrue(geohash.containsLocation(
                CLLocationCoordinate2D(latitude: -25, longitude: -178)))
        } else {
            XCTFail("Could not initialize geohash")
        }
    }
}