//
//  Geohash
//
//  Created by Vy-Shane Sin Fat on 4/09/2014.
//  Copyright (c) 2014 Vy-Shane Sin Fat. All rights reserved.
//

import CoreLocation

public struct Geohash: Equatable {

    public let hash: () -> String
    public let length: () -> Int
    public let center: () -> CLLocationCoordinate2D

    static let encoding = HashEncoding("0123456789bcdefghjkmnpqrstuvwxyz")
    private static let bits = [16, 8, 4, 2, 1]
    private static let precision: Double = 0.000000000001


    // MARK: - Initializers

    public init(_ hash: String) {
        assert(!hash.isEmpty, "Hash cannot be an empty string")
        assert(Geohash.encoding.isDecodableString(hash), "Hash contains invalid characters")

        self.hash = { () -> String in return hash.lowercaseString }
        self.length = { () -> Int in return countElements(hash) }
        self.center = { () -> CLLocationCoordinate2D in return Geohash.decodeHash(hash) }
    }

    public init(center: CLLocationCoordinate2D, length: Int) {
        assert(length > 0, "length must be a positive integer")
        assert(center.latitude >= -90 && center.latitude <= 90,
            "latitude of location must be between -90 and 90 inclusive")

        self.center = { () -> CLLocationCoordinate2D in return center }
        self.length = { () -> Int in return length }
        self.hash = { () -> String in return Geohash.encodeLocation(center, hashLength: length) }
    }


    // MARK: - Geohash Encoding and Decoding

    public static func encodeLocation(center: CLLocationCoordinate2D, hashLength: Int) -> String {
        let longitude = Geohash.longitudeTo180(center.longitude)
        let latitude = center.latitude
        var isEven = true
        var latitudeInterval = (-90.0, 90.0)
        var longitudeInterval = (-180.0, 180.0)
        var hash = ""
        var bit = 0
        var characterIndex = 0

        while countElements(hash) < hashLength {
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
                    hash.append(character())
                case .Error(_):
                    // This shouldn't happen.
                    NSException(name: "GeohashEncodingException",
                        reason: "Unable to encode non-base32 value", userInfo: nil).raise()
                }
                bit = 0
                characterIndex = 0
            }
        }
        return hash
    }

    public static func decodeHash(hash: String) -> CLLocationCoordinate2D {

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

        for character in hash {
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


    // MARK: - Finding Adjacent Geohashes

    public func neighborAtDirection(direction: Direction) -> Geohash {
        let hash = self.hash()
        let hashLength = self.length()
        let center = self.center()

        if isLocation(center, atBorderInDirection: direction, forHashLength: hashLength) {
            switch direction {
            case .Right:
                let adjacent = CLLocationCoordinate2D(latitude: center.latitude, longitude: -180)
                return Geohash(center:adjacent, length: hashLength)
            case .Left:
                let adjacent = CLLocationCoordinate2D(latitude: center.latitude, longitude: 180)
                return Geohash(center:adjacent, length: hashLength)
            case _:
                // Top or bottom.
                let adjacent = CLLocationCoordinate2D(latitude: center.latitude,
                    longitude: center.longitude + 180)
                return Geohash(center:adjacent, length: hashLength)
            }
        } else {
            let parity = Parity(forLength: hashLength)
            let lastCharacter = Character(hash.substringFromIndex(
                hash.endIndex.predecessor()))
            var base = Geohash(hash.substringToIndex(hash.endIndex.predecessor()))

            let borderEncoding = borderEncodingForDirection(direction, parity: parity)
            if borderEncoding.isDecodableString(String(lastCharacter)) {
                base = base.neighborAtDirection(direction)
            }

            switch neighborEncodingForDirection(direction, parity: parity)
                .valueForCharacter(lastCharacter) {

            case .Ok(let neighborValue):
                switch Geohash.encoding.characterForValue(neighborValue()) {
                case .Ok(let base32Character):
                    base = Geohash(base.hash() + String(base32Character()))
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

    public func rightNeighbor() -> Geohash {
        return neighborAtDirection(Direction.Right)
    }

    public func leftNeighbor() -> Geohash {
        return neighborAtDirection(Direction.Left)
    }

    public func topNeighbor() -> Geohash {
        return neighborAtDirection(Direction.Top)
    }

    public func bottomNeighbor() -> Geohash {
        return neighborAtDirection(Direction.Bottom)
    }


    // MARK: - Box Size

    public func width() -> CLLocationDegrees {
        return Geohash.widthForHashLength(self.length())
    }

    public static func widthForHashLength(hashLength: Int) -> CLLocationDegrees {
        let a = (hashLength % 2 == 0 ? -1 : -0.5)
        return 180 / pow(2, 2.5 * Double(hashLength) + a)
    }

    public func height() -> CLLocationDegrees {
        return Geohash.heightForHashLength(self.length())
    }

    public static func heightForHashLength(hashLength: Int) -> CLLocationDegrees {
        let a = (hashLength % 2 == 0 ? 0 : -0.5)
        return 180 / pow(2, 2.5 * Double(hashLength) + a)
    }


    // MARK: - Utility Methods

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

    private func isLocation(location: CLLocationCoordinate2D, atBorderInDirection: Direction,
            forHashLength: Int) -> Bool {

        let width = Geohash.widthForHashLength(forHashLength)

        switch (atBorderInDirection) {
        case .Right:
            return abs(location.longitude + width / 2 - 180.0) < Geohash.precision
        case .Left:
            return abs(location.longitude - width / 2 + 180) < Geohash.precision
        case .Top:
            return abs(location.latitude + width / 2 - 90) < Geohash.precision
        case .Bottom:
            return abs(location.latitude - width / 2 + 90) < Geohash.precision
        }
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


// MARK: - Equatable

public func ==(lhs: Geohash, rhs: Geohash) -> Bool {
    return lhs.hash() == rhs.hash()
}
