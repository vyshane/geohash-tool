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
        return hashMap
    }

    func isValidString(string: String) -> Bool {
        for character in string {
            if find(hashMap, character) == nil {
                return false
            }
        }
        return true
    }

    func valueForCharacter(character: Character) -> Int? {
        if let characterIndex = find(hashMap, character) {
            return distance(hashMap.startIndex, characterIndex)
        } else {
            return nil
        }
    }

    func characterForValue(value: Int) -> Character? {
        if value < 0 || value >= count(hashMap) {
            return nil
        } else {
            return hashMap[advance(hashMap.startIndex, value)]
        }
    }
}