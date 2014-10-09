//
//  GeoHashEncoding.swift
//  Geohash Tool
//
//  Created by Vy-Shane Sin Fat on 30/09/2014.
//  Copyright (c) 2014 Vy-Shane Sin Fat. All rights reserved.
//

struct GeohashEncoding {

    private static let base32Encoding = "0123456789bcdefghjkmnpqrstuvwxyz"

    static func isValidString(string: String) -> Bool {
        return true
    }

    static func valueForCharacter(character: Character) -> Result<Int> {
        if let characterIndex = find(base32Encoding, character) {
            return .Ok(distance(base32Encoding.startIndex, characterIndex))
        } else {
            return .Error(GeohashError.GeohashEncodingInvalidCharacter.error())
        }
    }

    static func characterForValue(value: Int) -> Result<Character> {
        if value < 0 || value >= countElements(base32Encoding) {
            return .Error(GeohashError.GeohashEncodingNonBase32Value.error())
        } else {
            return .Ok(base32Encoding[advance(base32Encoding.startIndex, value)])
        }
    }
}