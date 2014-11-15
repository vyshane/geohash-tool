//
//  ViewController.swift
//  Geohash Tool
//
//  Created by Vy-Shane Sin Fat on 3/09/2014.
//  Copyright (c) 2014 Vy-Shane Sin Fat. All rights reserved.
//

import Cocoa
import MapKit

class MapViewController: NSViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var currentLocationButton: NSButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.showsUserLocation = true
        mapView.delegate = self
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    func zoomToCurrentLocation() {
        let span = MKCoordinateSpan(latitudeDelta: 0.00725, longitudeDelta: 0.00725)
        let region = MKCoordinateRegion(center: mapView.userLocation.coordinate, span: span)
        mapView.setRegion(region, animated: true)
    }

    @IBAction func zoomToCurrentLocation(sender: NSButton) {
        zoomToCurrentLocation()
    }


    // MARK - MKMapViewDelegate

    func mapView(mapView: MKMapView!, regionDidChangeAnimated animated: Bool) {
        self.mapView.removeOverlays(mapView.overlays)

        if let coverage = Coverage(desiredRegion: mapView.region, maxGeohashes: 8) {
            // Plot geohashes on the map.
            for geohash in coverage.geohashes {
                self.mapView.addOverlay(geohash.polygon())
            }
        }
    }

    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!)
        -> MKOverlayRenderer!
    {
        if overlay.isKindOfClass(MKPolygon) {
            let renderer = MKPolygonRenderer(overlay: overlay)
            renderer.strokeColor = NSColor.grayColor()
            renderer.lineWidth = 1.5
            renderer.alpha = 0.5
            return renderer
        }
        return nil
    }
}