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
        mapView.showsUserLocation = true;
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func zoomToCurrentLocation(sender: NSButton) {
        let span = MKCoordinateSpan(latitudeDelta: 0.00725, longitudeDelta: 0.00725)
        let region = MKCoordinateRegion(center: mapView.userLocation.coordinate, span: span)
        mapView.setRegion(region, animated: true)
    }
}