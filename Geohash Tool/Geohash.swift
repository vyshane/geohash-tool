//
//  Geohash
//
//  Created by Vy-Shane Sin Fat on 4/09/2014.
//  Copyright (c) 2014 Vy-Shane Sin Fat. All rights reserved.
//

import CoreLocation

public struct Geohash {
    private static let bits = [16, 8, 4, 2, 1]

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

    public static func decode(geohash: String) -> Result<CLLocationCoordinate2D> {

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

        for character in geohash {
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
                return .Error(GeohashError.GeohashInvalid.error())
            }
        }

        return .Ok(CLLocationCoordinate2D(
            latitude: (latitudeInterval.0 + latitudeInterval.1) / 2,
            longitude: (longitudeInterval.0 + longitudeInterval.1) / 2
        ))
    }

    public static func encode(location: CLLocationCoordinate2D, length: Int) -> Result<String> {
        if length <= 0 {
            return .Error(GeohashError.GeohashInvalidLocation.error())
        }
        if location.latitude < -90 || location.latitude > 90 {
            return .Error(GeohashError.GeohashInvalidLocation.error())
        }

        let longitude = longitudeTo180(location.longitude)
        let latitude = location.latitude
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
                    return .Error(error)
                }
                bit = 0
                characterIndex = 0
            }
        }

        return Result.Ok(geohash)
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
}