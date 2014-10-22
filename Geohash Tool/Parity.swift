//
//  Parity.swift
//  Geohash Tool
//
//  Created by Vy-Shane Sin Fat on 18/09/2014.
//  Copyright (c) 2014 Vy-Shane Sin Fat. All rights reserved.
//

enum Parity {
    case Odd, Even

    init(forLength: Int) {
        if forLength % 2 == 0 {
            self = .Even
        } else {
            self = .Odd
        }
    }
}