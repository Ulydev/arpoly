//
//  ViewController.swift
//  PolyAR
//
//  Created by Ulysse on 11/11/2017.
//  Copyright © 2017 Ulysse. All rights reserved.
//

import UIKit
import ARCL
import ARKit
import CoreLocation
import SwiftyJSON

class ViewController: UIViewController, UISearchBarDelegate, SceneLocationViewDelegate {

    let validResults = ["batiments_epfl", "batiments_zones", "locaux", "auditoires"]
    let adjustNorth = true
    
    var currentNode: LocationNode?
    let network = Network()
    let ARView = SceneLocationView()
    let loadingOverlay = LoadingOverlay()
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Init AR
        ARView.orientToTrueNorth = true
        ARView.run()
        view.addSubview(ARView)
        view.sendSubview(toBack: ARView)
        
        // Setup search bar
        clearSearchBarBackgroundColor()
        searchBar.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        ARView.frame = view.bounds
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Search Bar
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        loadingOverlay.show(view: view)
        network.search(query: searchBar.text! as NSString, callback: onSearchResult)
    }
    
    func onSearchResult(_ json: JSON) {
        loadingOverlay.hide()
        if json == JSON.null {
            let alertController = UIAlertController(title: "Error", message:
                "An error has occurred", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,handler: nil))
            self.present(alertController, animated: true, completion: nil)
        } else {
            //Parse JSON, remove everything that is not a building/place, check if empty, if not place new marker
            let features = json["features"]
            let element = features[0]
            let layer_name = element["properties"]["layer_name"].stringValue
            if (element == JSON.null) || (!validResults.contains(layer_name)) {
                let alertController = UIAlertController(title: "Not found", message:
                    "No results matched your query", preferredStyle: UIAlertControllerStyle.alert)
                alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,handler: nil))
                self.present(alertController, animated: true, completion: nil)
            } else {
                setCurrentResult(element)
                searchBar.text = nil
            }
        }
    }
    
    func setCurrentResult(_ result: JSON) {
        if (currentNode != nil) {
            ARView.removeLocationNode(locationNode: currentNode!)
        }
        
        let title = result["properties"]["label"].stringValue as NSString
        let center = getCenter(result["geometry"])
        let location = CLLocation(coordinate: center, altitude: 420)
        currentNode = PopoverLocationNode(location: location, title: title)
        ARView.addLocationNodeWithConfirmedLocation(locationNode: currentNode!)
        print("latitude: \(center.latitude)")
        print("longitude: \(center.longitude)")
    }
    
    func getCenter(_ geometry: JSON) -> CLLocationCoordinate2D {
        var a = 0.0
        var b = 0.0
        if geometry["type"].stringValue == "MultiPolygon" {
            let coordinates = geometry["coordinates"][0][0]
            print(coordinates)
            for (_, point):(String, JSON) in coordinates {
                a += point[0].doubleValue
                b += point[1].doubleValue
                print(point[0].doubleValue)
                print(point[1].doubleValue)
            }
            a /= Double(coordinates.count)
            b /= Double(coordinates.count)
            print(a)
            print(b)
        } else {
            a = geometry["coordinates"][0].doubleValue
            b = geometry["coordinates"][1].doubleValue
        }
        let gpsCoords = CoordinatesConverter.CHtoWGS(y: a, x: b)
        return CLLocationCoordinate2D(latitude: gpsCoords[1], longitude: gpsCoords[0])
    }
    
    private func clearSearchBarBackgroundColor() {
        for subView in searchBar.subviews {
            for view in subView.subviews {
                if view.isKind(of: NSClassFromString("UISearchBarBackground")!) {
                    let imageView = view as! UIImageView
                    imageView.removeFromSuperview()
                }
            }
        }
    }
    
    // MARK: Adjust North
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        if let touch = touches.first {
            if touch.view != nil {
                if (searchBar == touch.view! ||
                    searchBar.subviews.contains(touch.view!)) {
                } else {
                    
                    let location = touch.location(in: self.view)
                    
                    if location.x <= 40 && adjustNorth {
                        print("left side of the screen")
                        ARView.moveSceneHeadingAntiClockwise()
                    } else if location.x >= view.frame.size.width - 40 && adjustNorth {
                        print("right side of the screen")
                        ARView.moveSceneHeadingClockwise()
                    }
                }
            }
        }
    }
    
    //MARK: SceneLocationViewDelegate
    
    func sceneLocationViewDidAddSceneLocationEstimate(sceneLocationView: SceneLocationView, position: SCNVector3, location: CLLocation) {
        
    }
    
    func sceneLocationViewDidRemoveSceneLocationEstimate(sceneLocationView: SceneLocationView, position: SCNVector3, location: CLLocation) {
        
    }
    
    func sceneLocationViewDidConfirmLocationOfNode(sceneLocationView: SceneLocationView, node: LocationNode) {
    }
    
    func sceneLocationViewDidSetupSceneNode(sceneLocationView: SceneLocationView, sceneNode: SCNNode) {
        
    }
    
    func sceneLocationViewDidUpdateLocationAndScaleOfLocationNode(sceneLocationView: SceneLocationView, locationNode: LocationNode) {
        
    }

}
