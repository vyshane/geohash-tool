//
//  Coverage.swift
//  Geohash Tool
//
//  Created by Vy-Shane Sin Fat on 29/10/2014.
//  Copyright (c) 2014 Vy-Shane Sin Fat. All rights reserved.
//

import CoreLocation

public struct Coverage {

//    public let ratio: () -> Double
//    public let geohashes: () -> [Geohash]
    private static let maxHashLength = 12


    // MARK: - Initializers

    public init?(desiredTopLeft: CLLocationCoordinate2D,
        desiredBottomRight: CLLocationCoordinate2D, hashLength: Int) {

        if !CLLocationCoordinate2DIsValid(desiredTopLeft) ||
            !CLLocationCoordinate2DIsValid(desiredBottomRight) || hashLength <= 1 {
            return nil
        }

        let widthForHashLength = Geohash.widthForHashLength(hashLength)
        let heightForHashLength = Geohash.heightForHashLength(hashLength)

        // TODO.
    }

    public init?(desiredTopLeft: CLLocationCoordinate2D, desiredBottomRight: CLLocationCoordinate2D,
        maxGeohashes: Int) {

        if !CLLocationCoordinate2DIsValid(desiredTopLeft) ||
            !CLLocationCoordinate2DIsValid(desiredBottomRight) || maxGeohashes <= 1 {
            return nil
        }

        var startHashLength = Coverage.hashLengthToCoverBoundingBoxWithTopLeft(desiredTopLeft,
            bottomRight: desiredBottomRight)

        if startHashLength == nil {
            startHashLength = 1
        }

        // TODO.
    }


    // MARK: - Utility methods

    private static func hashLengthToCoverBoundingBoxWithTopLeft(topLeft: CLLocationCoordinate2D,
        bottomRight: CLLocationCoordinate2D) -> Int? {

        for length in Coverage.maxHashLength...1 {
            if let _ = Geohash(location: topLeft, length: length)?.containsLocation(bottomRight) {
                return length
            }
        }
        return nil
    }
}