//
//  Result.swift
//  Geohash Tool
//
//  Created by Vy-Shane Sin Fat on 30/09/2014.
//  Copyright (c) 2014 Vy-Shane Sin Fat. All rights reserved.
//

import Foundation

public enum Result<T> {
    case Ok(@autoclosure () -> T)
    case Error(NSError)
}
