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

    func validCharacters() -> String {
        return self.hashMap
    }

    func isValidString(string: String) -> Bool {
        for character in string {
            if find(self.hashMap, character) == nil {
                return false
            }
        }
        return true
    }

    func valueForCharacter(character: Character) -> Result<Int> {
        if let characterIndex = find(self.hashMap, character) {
            return .Ok(distance(self.hashMap.startIndex, characterIndex))
        } else {
            return .Error(GeohashError.GeohashEncodingInvalidCharacter.error())
        }
    }

    func characterForValue(value: Int) -> Result<Character> {
        if value < 0 || value >= countElements(self.hashMap) {
            return .Error(GeohashError.GeohashEncodingNonBase32Value.error())
        } else {
            return .Ok(self.hashMap[advance(self.hashMap.startIndex, value)])
        }
    }
}