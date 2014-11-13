//
//  Coverage.swift
//  Geohash Tool
//
//  Created by Vy-Shane Sin Fat on 29/10/2014.
//  Copyright (c) 2014 Vy-Shane Sin Fat. All rights reserved.
//

import CoreLocation

public struct Coverage {

    public let ratio: Double
    public let geohashes: [Geohash]  // FIXME: This should be a set, possibly an ordered set.
    private static let maxHashLength = 12


    // MARK: - Initializers

    public init?(desiredTopLeft: CLLocationCoordinate2D,
        desiredBottomRight: CLLocationCoordinate2D, hashLength: Int)
    {
        if !CLLocationCoordinate2DIsValid(desiredTopLeft) ||
            !CLLocationCoordinate2DIsValid(desiredBottomRight) || hashLength <= 1 {
            return nil
        }

        let widthForHashLength = Geohash.widthForHashLength(hashLength)
        let heightForHashLength = Geohash.heightForHashLength(hashLength)
        let longitudeDifference = Longitude.differenceBetween(desiredBottomRight.longitude,
            and: desiredTopLeft.longitude)
        let maxLongitude = desiredTopLeft.longitude + longitudeDifference

        // FIXME: Clean this up.
        var geohashes: [Geohash] = []
        func addGeohash(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
            let location = CLLocationCoordinate2DMake(latitude, longitude)
            if let geohash = Geohash(location: location, length: hashLength) {
                if !contains(geohashes, geohash) {
                    geohashes.append(geohash)
                }
            }
        }

        for var latitude = desiredBottomRight.latitude; latitude <= desiredTopLeft.latitude;
            latitude += heightForHashLength
        {
            for var longitude = desiredTopLeft.longitude; longitude <= maxLongitude;
                longitude += widthForHashLength
            {
                addGeohash(latitude, longitude)
            }
        }

        // Include the borders.
        for var latitude = desiredBottomRight.latitude; latitude <= desiredTopLeft.latitude;
            latitude += heightForHashLength
        {
            addGeohash(latitude, maxLongitude)
        }

        for var longitude = desiredTopLeft.longitude; longitude <= maxLongitude;
            longitude += widthForHashLength
        {
            addGeohash(desiredTopLeft.latitude, longitude)
        }

        // Include the top right corner.
        addGeohash(desiredTopLeft.latitude, maxLongitude)

        self.geohashes = geohashes.sorted { $0.hash() < $1.hash() }

        // Calculate the coverage ratio.
        let desiredArea = longitudeDifference *
            (desiredTopLeft.latitude - desiredBottomRight.latitude)
        let coverageArea = Double(geohashes.count) * widthForHashLength * heightForHashLength

        ratio = coverageArea / desiredArea
    }

    public init?(desiredTopLeft: CLLocationCoordinate2D, desiredBottomRight: CLLocationCoordinate2D,
        maxGeohashes: Int)
    {
        if !CLLocationCoordinate2DIsValid(desiredTopLeft) ||
            !CLLocationCoordinate2DIsValid(desiredBottomRight) || maxGeohashes <= 1 {
            return nil
        }

        var startHashLength = Coverage.hashLengthToCoverBoundingBoxWithTopLeft(desiredTopLeft,
            bottomRight: desiredBottomRight)

        if startHashLength == nil {
            startHashLength = 1
        }

        var coverage: Coverage?

        for length in startHashLength!...Coverage.maxHashLength {
            if let attemptCoverage = Coverage(desiredTopLeft: desiredTopLeft,
                desiredBottomRight: desiredBottomRight, hashLength: length)
            {
                if attemptCoverage.geohashes.count <= maxGeohashes {
                    coverage = attemptCoverage
                } else {
                    break
                }
            }
        }

        if coverage == nil {
            return nil
        } else {
            self = coverage!
        }
    }


    // MARK: - Utility methods

    private static func hashLengthToCoverBoundingBoxWithTopLeft(topLeft: CLLocationCoordinate2D,
        bottomRight: CLLocationCoordinate2D) -> Int?
    {
        for length in Coverage.maxHashLength...1 {
            if let _ = Geohash(location: topLeft, length: length)?.containsLocation(bottomRight) {
                return length
            }
        }
        return nil
    }
}


// MARK: - Equatable

public func ==(lhs: Coverage, rhs: Coverage) -> Bool {
    if lhs.geohashes.count != rhs.geohashes.count {
        return false
    }
    for i in 0..<lhs.geohashes.count {
        if lhs.geohashes[i] != rhs.geohashes[i] {
            return false
        }
    }
    return true
}
