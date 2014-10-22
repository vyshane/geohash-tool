//
//  HashEncoding.swift
//  Geohash Tool
//
//  Created by Vy-Shane Sin Fat on 30/09/2014.
//  Copyright (c) 2014 Vy-Shane Sin Fat. All rights reserved.
//

struct HashEncoding {
    private let hashMap: String

    init(_ hashMap: String) {
        self.hashMap = hashMap
    }

    func isDecodableString(string: String) -> Bool {
        if string.isEmpty {
            return false
        }
        for character in string {
            if find(hashMap, character) == nil {
                return false
            }
        }
        return true
    }

    func valueForCharacter(character: Character) -> Result<Int> {
        if let characterIndex = find(hashMap, character) {
            return .Ok(distance(hashMap.startIndex, characterIndex))
        } else {
            return .Error(GeohashError.GeohashEncodingInvalidCharacter.error())
        }
    }

    func characterForValue(value: Int) -> Result<Character> {
        if value < 0 || value >= countElements(hashMap) {
            return .Error(GeohashError.GeohashEncodingNonBase32Value.error())
        } else {
            return .Ok(hashMap[advance(hashMap.startIndex, value)])
        }
    }
}