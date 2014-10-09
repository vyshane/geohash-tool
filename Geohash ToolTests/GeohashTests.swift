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
        let geohash = Geohash(fromString: "qd66hrhk")
        let location = geohash.location()

        XCTAssert(String(format: "%.3f", location.latitude) == "-31.953"
            && String(format: "%.3f", location.longitude) == "115.857",
            "Decoding \"qd66hrhk\" should result in lat -31.953 and lon 115.857")
    }

    func testEncode() {
        let location = CLLocationCoordinate2D(latitude: -31.953, longitude: 115.857)
        let geohash = Geohash(fromLocation: location, length: 8)

        XCTAssert(geohash.stringValue == "qd66hrhk",
            "Encoding latitude -31.953 and longitude 115.857 " + "should result in \"qd66hrhk\"")
    }
}