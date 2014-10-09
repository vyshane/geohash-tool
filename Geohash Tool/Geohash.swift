//
//  Geohash
//
//  Created by Vy-Shane Sin Fat on 4/09/2014.
//  Copyright (c) 2014 Vy-Shane Sin Fat. All rights reserved.
//

import CoreLocation

public struct Geohash {
    public let stringValue: String;
    private let bits = [16, 8, 4, 2, 1]

    public init(fromString: String) {
        assert(GeohashEncoding.isValidString(fromString), "String contains invalid characters")
        stringValue = fromString
    }

    public init(fromLocation: CLLocationCoordinate2D, length: Int) {
        assert(length > 0, "length must be a positive integer")
        assert(fromLocation.latitude >= -90 && fromLocation.latitude <= 90,
            "latitude of location must be between -90 and 90 inclusive")

        let longitude = Geohash.longitudeTo180(fromLocation.longitude)
        let latitude = fromLocation.latitude
        var isEven = true
        var latitudeInterval = (-90.0, 90.0)
        var longitudeInterval = (-180.0, 180.0)
        var geohash = ""
        var bit = 0
        var characterIndex = 0

        while countElements(geohash) < length {
            if isEven {
                let mid = (longitudeInterval.0 + longitudeInterval.1) / 2
                if longitude >= mid {
                    characterIndex = characterIndex | bits[bit]
                    longitudeInterval.0 = mid
                } else {
                    longitudeInterval.1 = mid
                }
            } else {
                let mid = (latitudeInterval.0 + latitudeInterval.1) / 2
                if latitude >= mid {
                    characterIndex = characterIndex | bits[bit]
                    latitudeInterval.0 = mid
                } else {
                    latitudeInterval.1 = mid
                }
            }
            isEven = !isEven

            if bit < 4 {
                ++bit
            } else {
                switch GeohashEncoding.characterForValue(characterIndex) {
                case .Ok(let character):
                    geohash.append(character())
                case .Error(let error):
                    // This shouldn't happen.
                    NSException(name: "GeohashEncodingException",
                        reason: "Unable to encode non-base32 value", userInfo: nil).raise()
                }
                bit = 0
                characterIndex = 0
            }
        }

        stringValue = geohash
    }

    public func location() -> CLLocationCoordinate2D {

        func refineInterval(interval: (CLLocationDegrees, CLLocationDegrees),
            codeInDecimal: Int, mask: Int) -> (CLLocationDegrees, CLLocationDegrees) {

            let (firstEntry, secondEntry) = interval
            if (codeInDecimal & mask) != 0 {
                return ((firstEntry + secondEntry) / 2, secondEntry)
            } else {
                return (firstEntry, (firstEntry + secondEntry) / 2)
            }
        }

        var isEven = true
        var latitudeInterval = (-90.0, 90.0)
        var longitudeInterval = (-180.0, 180.0)

        for character in stringValue {
            switch GeohashEncoding.valueForCharacter(character) {
            case .Ok(let value):
                for mask in bits {
                    if isEven {
                        longitudeInterval = refineInterval(longitudeInterval, value(), mask)
                    } else {
                        latitudeInterval = refineInterval(latitudeInterval, value(), mask)
                    }
                    isEven = !isEven
                }
            case .Error:
                NSException(name: "GeohashDecodingException",
                    reason: "Invalid Geohash character", userInfo: nil).raise()
            }
        }

        return CLLocationCoordinate2D(
            latitude: (latitudeInterval.0 + latitudeInterval.1) / 2,
            longitude: (longitudeInterval.0 + longitudeInterval.1) / 2
        )
    }

    private static func longitudeTo180(longitude: CLLocationDegrees) -> CLLocationDegrees {
        if longitude < 0 {
            return -longitudeTo180(abs(longitude))
        } else {
            if longitude > 180 {
                return longitude - round(floor((longitude + 180) / 360.0)) * 360
            } else {
                return longitude
            }
        }
    }

    // Used in adjacent hash calculations.
    private func neighborForDirection(direction: Direction, parity: Parity) -> String {
        switch (direction, parity) {
        case (Direction.Right, Parity.Even):
            return "bc01fg45238967deuvhjyznpkmstqrwx"
        case (Direction.Left, Parity.Even):
            return "238967debc01fg45kmstqrwxuvhjyznp"
        case (Direction.Top, Parity.Even):
            return "p0r21436x8zb9dcf5h7kjnmqesgutwvy"
        case (Direction.Bottom, Parity.Even):
            return "14365h7k9dcfesgujnmqp0r2twvyx8zb"
        case (Direction.Right, Parity.Odd):
            return neighborForDirection(Direction.Top, parity: Parity.Even)
        case (Direction.Left, Parity.Odd):
            return neighborForDirection(Direction.Bottom, parity: Parity.Even)
        case (Direction.Top, Parity.Odd):
            return neighborForDirection(Direction.Right, parity: Parity.Even)
        case (Direction.Bottom, Parity.Odd):
            return neighborForDirection(Direction.Left, parity: Parity.Even)
        }
    }

    // Used in border hash calculations.
    private func borderForDirection(direction: Direction, parity: Parity) -> String {
        switch (direction, parity) {
        case (Direction.Right, Parity.Even):
            return "bcfguvyz"
        case (Direction.Left, Parity.Even):
            return "0145hjnp"
        case (Direction.Top, Parity.Even):
            return "prxz"
        case (Direction.Bottom, Parity.Even):
            return "028b"
        case (Direction.Right, Parity.Odd):
            return borderForDirection(Direction.Top, parity: Parity.Even)
        case (Direction.Left, Parity.Odd):
            return borderForDirection(Direction.Bottom, parity: Parity.Even)
        case (Direction.Top, Parity.Odd):
            return borderForDirection(Direction.Right, parity: Parity.Even)
        case (Direction.Bottom, Parity.Odd):
            return borderForDirection(Direction.Left, parity: Parity.Even)
        }
    }

}