//
//  Geohash
//
//  Created by Vy-Shane Sin Fat on 4/09/2014.
//  Copyright (c) 2014 Vy-Shane Sin Fat. All rights reserved.
//

import CoreLocation

public struct Geohash {

    public let stringValue: String;
    static let encoding = HashEncoding("0123456789bcdefghjkmnpqrstuvwxyz")
    private let bits = [16, 8, 4, 2, 1]
    private let precision: Double = 0.000000000001

    public init(_ value: String) {
        assert(!value.isEmpty, "String cannot be empty")
        assert(Geohash.encoding.isDecodableString(value), "String contains invalid characters")
        stringValue = value.lowercaseString
    }

    public init(location: CLLocationCoordinate2D, length: Int) {
        assert(length > 0, "length must be a positive integer")
        assert(location.latitude >= -90 && location.latitude <= 90,
            "latitude of location must be between -90 and 90 inclusive")

        let longitude = Geohash.longitudeTo180(location.longitude)
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

            if bit < bits.count - 1 {
                ++bit
            } else {
                switch Geohash.encoding.characterForValue(characterIndex) {
                case .Ok(let character):
                    geohash.append(character())
                case .Error(_):
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
            switch Geohash.encoding.valueForCharacter(character) {
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

    public func right() -> Geohash {
        return geohashAtDirection(Direction.Right)
    }

    public func left() -> Geohash {
        return geohashAtDirection(Direction.Left)
    }

    public func top() -> Geohash {
        return geohashAtDirection(Direction.Top)
    }

    public func bottom() -> Geohash {
        return geohashAtDirection(Direction.Bottom)
    }

    public func geohashAtDirection(direction: Direction) -> Geohash {
        let source = self.location()
        let hashLength = countElements(stringValue)

        if isLocation(source, atBorderInDirection: direction, forHashLength: hashLength) {
            switch direction {
            case .Right:
                let adjacent = CLLocationCoordinate2D(latitude: source.latitude, longitude: -180)
                return Geohash(location:adjacent, length: hashLength)
            case .Left:
                let adjacent = CLLocationCoordinate2D(latitude: source.latitude, longitude: 180)
                return Geohash(location:adjacent, length: hashLength)
            case _:
                // Top or bottom.
                let adjacent = CLLocationCoordinate2D(latitude: source.latitude,
                    longitude: source.longitude + 180)
                return Geohash(location:adjacent, length: hashLength)
            }
        } else {
            let lastCharacter = Character(stringValue.substringFromIndex(stringValue.endIndex))
            let parity = Parity(forLength: hashLength)
            var base = Geohash(stringValue.substringToIndex(stringValue.endIndex.predecessor()))
            let borderEncoding = borderEncodingForDirection(direction, parity: parity)

            if borderEncoding.isDecodableString(String(lastCharacter)) {
                base = base.geohashAtDirection(direction)
            }

            switch neighborEncodingForDirection(direction, parity: parity)
                .valueForCharacter(lastCharacter) {

            case .Ok(let neighborValue):
                switch Geohash.encoding.characterForValue(neighborValue()) {
                case .Ok(let base32Character):
                    base = Geohash(base.stringValue + String(base32Character()))
                case .Error(let error):
                    // This shouldn't happen.
                    NSException(name: "GeohashEncodingException",
                        reason: "Unable to encode Geohash from non-base32 value",
                        userInfo: nil).raise()
                }

            case .Error(_):
                // This shouldn't happen.
                NSException(name: "GeohashEncodingException",
                    reason: "Unable to decode neighbor value", userInfo: nil).raise()
            }
            return base
        }
    }

    private func isLocation(location: CLLocationCoordinate2D, atBorderInDirection: Direction,
            forHashLength: Int) -> Bool {

        let width = widthForHashLength(forHashLength)

        switch (atBorderInDirection) {
        case .Right:
            return abs(location.longitude + width / 2 - 180.0) < precision
        case .Left:
            return abs(location.longitude - width / 2 + 180) < precision
        case .Top:
            return abs(location.latitude + width / 2 - 90) < precision
        case .Bottom:
            return abs(location.latitude - width / 2 + 90) < precision
        }
    }

    private func widthForHashLength(hashLength: Int) -> CLLocationDegrees {
        // TODO: Cache results of following calculation?
        let a = (hashLength % 2 == 0 ? -1 : -0.5)
        return pow(2, 2.5 * Double(hashLength) + a)
    }

    private func neighborEncodingForDirection(direction: Direction, parity: Parity)
            -> HashEncoding {
        switch (direction, parity) {
        case (Direction.Right, Parity.Even):
            return HashEncoding("bc01fg45238967deuvhjyznpkmstqrwx")
        case (Direction.Left, Parity.Even):
            return HashEncoding("238967debc01fg45kmstqrwxuvhjyznp")
        case (Direction.Top, Parity.Even):
            return HashEncoding("p0r21436x8zb9dcf5h7kjnmqesgutwvy")
        case (Direction.Bottom, Parity.Even):
            return HashEncoding("14365h7k9dcfesgujnmqp0r2twvyx8zb")
        case (Direction.Right, Parity.Odd):
            return neighborEncodingForDirection(Direction.Top, parity: Parity.Even)
        case (Direction.Left, Parity.Odd):
            return neighborEncodingForDirection(Direction.Bottom, parity: Parity.Even)
        case (Direction.Top, Parity.Odd):
            return neighborEncodingForDirection(Direction.Right, parity: Parity.Even)
        case (Direction.Bottom, Parity.Odd):
            return neighborEncodingForDirection(Direction.Left, parity: Parity.Even)
        }
    }

    private func borderEncodingForDirection(direction: Direction, parity: Parity)
            -> HashEncoding {
        switch (direction, parity) {
        case (Direction.Right, Parity.Even):
            return HashEncoding("bcfguvyz")
        case (Direction.Left, Parity.Even):
            return HashEncoding("0145hjnp")
        case (Direction.Top, Parity.Even):
            return HashEncoding("prxz")
        case (Direction.Bottom, Parity.Even):
            return HashEncoding("028b")
        case (Direction.Right, Parity.Odd):
            return borderEncodingForDirection(Direction.Top, parity: Parity.Even)
        case (Direction.Left, Parity.Odd):
            return borderEncodingForDirection(Direction.Bottom, parity: Parity.Even)
        case (Direction.Top, Parity.Odd):
            return borderEncodingForDirection(Direction.Right, parity: Parity.Even)
        case (Direction.Bottom, Parity.Odd):
            return borderEncodingForDirection(Direction.Left, parity: Parity.Even)
        }
    }
}