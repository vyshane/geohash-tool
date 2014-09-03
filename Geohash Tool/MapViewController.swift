//
//  ViewController.swift
//  Geohash Tool
//
//  Created by Vy-Shane Sin Fat on 3/09/2014.
//  Copyright (c) 2014 Vy-Shane Sin Fat. All rights reserved.
//

import Cocoa
import MapKit

class MapViewController: NSViewController {

    @IBOutlet weak var mapView: MKMapView!
                            
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
                                    
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }
}