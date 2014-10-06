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
        switch Geohash.decode("qd66hrhk") {
        case Result.Ok(let location):
            XCTAssert(String(format: "%.3f", location().latitude) == "-31.953"
                && String(format: "%.3f", location().longitude) == "115.857",
                "Decoding \"qd66hrhk\" should result in lat -31.953 and lon 115.857")
        case Result.Error:
            XCTAssert(false, "Decoding \"qd66hrhk\" should not generate an error")
        }
    }

    func testEncode() {
        let location = CLLocationCoordinate2D(latitude: -31.953, longitude: 115.857)
        switch Geohash.encode(location, length: 8) {
        case Result.Ok(let hash):
            XCTAssert(hash() == "qd66hrhk", "Encoding latitude -31.953 and longitude 115.857 " +
                "should result in \"qd66hrhk\"")
        case Result.Error:
            XCTAssert(false, "Encoding latitude -31.953 and longitude 115.85 should not generate " +
                "an error")
        }
    }
}