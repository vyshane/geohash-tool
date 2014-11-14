//
//  CoverageTests.swift
//  Geohash Tool
//
//  Created by Vy-Shane Sin Fat on 12/11/2014.
//  Copyright (c) 2014 Vy-Shane Sin Fat. All rights reserved.
//

import MapKit
import XCTest

class CoverageTests: XCTestCase {

    let accuracy = 0.000000001
    let hartford = CLLocationCoordinate2DMake(41.842967, -72.727175)
    let schenectady = CLLocationCoordinate2DMake(42.819581, -73.950691)

    func testCoverageWithHashLength1AroundBoston() {
        let coverage = Coverage(desiredTopLeft: schenectady, desiredBottomRight: hartford,
            hashLength: 1)

        XCTAssertEqual(coverage!.geohashes, [Geohash("d")!])
        XCTAssertEqualWithAccuracy(coverage!.ratio, 1694.6984366342194, accuracy)
    }

    func testCoverageWithHashLength4AroundBoston() {
        var expectedGeohashes: [Geohash] = []
        expectedGeohashes.append(Geohash("dre7")!)
        expectedGeohashes.append(Geohash("dree")!)
        expectedGeohashes.append(Geohash("dreg")!)
        expectedGeohashes.append(Geohash("drs5")!)
        expectedGeohashes.append(Geohash("drs7")!)
        expectedGeohashes.append(Geohash("dre6")!)
        expectedGeohashes.append(Geohash("dred")!)
        expectedGeohashes.append(Geohash("dref")!)
        expectedGeohashes.append(Geohash("drs4")!)
        expectedGeohashes.append(Geohash("drs6")!)
        expectedGeohashes.append(Geohash("dre3")!)
        expectedGeohashes.append(Geohash("dre9")!)
        expectedGeohashes.append(Geohash("drec")!)
        expectedGeohashes.append(Geohash("drs1")!)
        expectedGeohashes.append(Geohash("drs3")!)
        expectedGeohashes.append(Geohash("dre2")!)
        expectedGeohashes.append(Geohash("dre8")!)
        expectedGeohashes.append(Geohash("dreb")!)
        expectedGeohashes.append(Geohash("drs0")!)
        expectedGeohashes.append(Geohash("drs2")!)
        expectedGeohashes.append(Geohash("dr7r")!)
        expectedGeohashes.append(Geohash("dr7x")!)
        expectedGeohashes.append(Geohash("dr7z")!)
        expectedGeohashes.append(Geohash("drkp")!)
        expectedGeohashes.append(Geohash("drkr")!)
        expectedGeohashes.append(Geohash("dr7q")!)
        expectedGeohashes.append(Geohash("dr7w")!)
        expectedGeohashes.append(Geohash("dr7y")!)
        expectedGeohashes.append(Geohash("drkn")!)
        expectedGeohashes.append(Geohash("drkq")!)
        expectedGeohashes.sort { $0.hash() < $1.hash() }

        let coverage = Coverage(desiredTopLeft: schenectady, desiredBottomRight: hartford,
            hashLength: 4)

        XCTAssertEqual(coverage!.geohashes, expectedGeohashes)
    }

    func testCoverageWithOptimalHashLengthAroundBoston() {
        let coverage = Coverage(desiredTopLeft: schenectady, desiredBottomRight: hartford,
            maxGeohashes: 10)

        XCTAssertEqual(coverage!.geohashes.count, 4)
        XCTAssertEqual(coverage!.geohashes[0].length(), 3)
    }

    func testCoverageWithMaxHashes1AroundBoston() {
        let coverage = Coverage(desiredTopLeft: schenectady, desiredBottomRight: hartford,
            maxGeohashes: 1)

        XCTAssertEqual(coverage!.geohashes.count, 1)
        XCTAssertEqual(coverage!.geohashes[0].length(), 2)
    }
}