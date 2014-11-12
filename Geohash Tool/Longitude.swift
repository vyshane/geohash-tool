//
//  Location.swift
//  Geohash Tool
//
//  Created by Vy-Shane Sin Fat on 7/11/2014.
//  Copyright (c) 2014 Vy-Shane Sin Fat. All rights reserved.
//

import CoreLocation

struct Longitude {

    static func to180(longitude: CLLocationDegrees) -> CLLocationDegrees {
        if longitude < 0 {
            return -to180(abs(longitude))
        } else {
            if longitude > 180 {
                return longitude - round(floor((longitude + 180) / 360.0)) * 360
            } else {
                return longitude
            }
        }
    }

    static func differenceBetween(first: CLLocationDegrees, and: CLLocationDegrees)
        -> CLLocationDegrees {
        return abs(Longitude.to180(Longitude.to180(first) - Longitude.to180(and)))
    }
}