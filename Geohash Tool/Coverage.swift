//
//  Coverage.swift
//  Geohash Tool
//
//  Created by Vy-Shane Sin Fat on 29/10/2014.
//  Copyright (c) 2014 Vy-Shane Sin Fat. All rights reserved.
//

import MapKit

public struct Coverage {

    public let ratio: Double
    public let geohashes: [Geohash]  // FIXME: This should be a set, possibly an ordered set.
    private static let maxHashLength = 12


    // MARK: - Initializers

    public init?(desiredTopLeft: CLLocationCoordinate2D,
        desiredBottomRight: CLLocationCoordinate2D, hashLength: Int)
    {
        if !CLLocationCoordinate2DIsValid(desiredTopLeft) ||
            !CLLocationCoordinate2DIsValid(desiredBottomRight) || hashLength < 1 {
            return nil
        }

        let widthForHashLength = Geohash.widthForHashLength(hashLength)
        let heightForHashLength = Geohash.heightForHashLength(hashLength)
        let longitudeDifference = Longitude.differenceBetween(desiredBottomRight.longitude,
            and: desiredTopLeft.longitude)
        let maxLongitude = desiredTopLeft.longitude + longitudeDifference

        var geohashes: [Geohash] = []

        func addGeohash(var geohashes: [Geohash], latitude: CLLocationDegrees,
            longitude: CLLocationDegrees, hashLength: Int) -> [Geohash]
        {
            let location = CLLocationCoordinate2DMake(latitude, longitude)
            if let geohash = Geohash(location: location, length: hashLength) {
                if !contains(geohashes, geohash) {
                    geohashes.append(geohash)
                }
            }
            return geohashes
        }

        for var latitude = desiredBottomRight.latitude; latitude <= desiredTopLeft.latitude;
            latitude += heightForHashLength
        {
            for var longitude = desiredTopLeft.longitude; longitude <= maxLongitude;
                longitude += widthForHashLength
            {
                geohashes = addGeohash(geohashes, latitude, longitude, hashLength)
            }
        }

        // Include the borders.
        for var latitude = desiredBottomRight.latitude; latitude <= desiredTopLeft.latitude;
            latitude += heightForHashLength
        {
            geohashes = addGeohash(geohashes, latitude, maxLongitude, hashLength)
        }

        for var longitude = desiredTopLeft.longitude; longitude <= maxLongitude;
            longitude += widthForHashLength
        {
            geohashes = addGeohash(geohashes, desiredTopLeft.latitude, longitude, hashLength)
        }

        // Include the top right corner.
        geohashes = addGeohash(geohashes, desiredTopLeft.latitude, maxLongitude, hashLength)

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
            !CLLocationCoordinate2DIsValid(desiredBottomRight) || maxGeohashes < 1 {
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

    public init?(desiredRegion: MKCoordinateRegion, maxGeohashes: Int) {
        let topLeft = Coverage.topLeftLocationForRegion(desiredRegion)
        let bottomRight = Coverage.bottomRightLocationForRegion(desiredRegion)

        if let coverage = Coverage(desiredTopLeft: topLeft, desiredBottomRight: bottomRight,
            maxGeohashes: maxGeohashes)
        {
            self = coverage
        } else {
            return nil
        }
    }

    public init?(desiredRegion: MKCoordinateRegion, hashLength: Int) {
        let topLeft = Coverage.topLeftLocationForRegion(desiredRegion)
        let bottomRight = Coverage.bottomRightLocationForRegion(desiredRegion)

        if let coverage = Coverage(desiredTopLeft: topLeft, desiredBottomRight: bottomRight,
            hashLength: hashLength)
        {
            self = coverage
        } else {
            return nil
        }
    }


    // MARK: - Utility methods

    private static func topLeftLocationForRegion(region: MKCoordinateRegion)
        -> CLLocationCoordinate2D
    {
        let topLeftLatitude = region.center.latitude + (region.span.latitudeDelta / 2)
        let topLeftLongitude = Longitude.to180(region.center.longitude -
            (region.span.longitudeDelta / 2))
        return CLLocationCoordinate2DMake(topLeftLatitude, topLeftLongitude)
    }

    private static func bottomRightLocationForRegion(region: MKCoordinateRegion)
        -> CLLocationCoordinate2D
    {
        let bottomRightLatitude = region.center.latitude - (region.span.latitudeDelta / 2)
        let bottomRightLongitude = Longitude.to180(region.center.longitude +
            (region.span.longitudeDelta / 2))
        return CLLocationCoordinate2DMake(bottomRightLatitude, bottomRightLongitude)
    }

    private static func hashLengthToCoverBoundingBoxWithTopLeft(topLeft: CLLocationCoordinate2D,
        bottomRight: CLLocationCoordinate2D) -> Int?
    {
        for var length = Coverage.maxHashLength; length > 0; --length {
            if let geohash = Geohash(location: topLeft, length: length) {
                if geohash.containsLocation(bottomRight) {
                    return length
                }
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
