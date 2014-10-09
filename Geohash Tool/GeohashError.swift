//
//  GeohashError.swift
//  Geohash Tool
//
//  Created by Vy-Shane Sin Fat on 30/09/2014.
//  Copyright (c) 2014 Vy-Shane Sin Fat. All rights reserved.
//

import Foundation

enum GeohashError: Int {
    case GeohashEncodingInvalidCharacter = 100
    case GeohashEncodingNonBase32Value

    func error() -> NSError {
        return NSError(domain: "GeohashErrorDomain", code: self.rawValue, userInfo: nil);
    }
}