//
//  WinterViewController.swift
//  SevereWxApp
//
//  Created by michael on 26/12/2017.
//  Copyright © 2017 chase2be. All rights reserved.
//

import UIKit
import CoreLocation

class WinterViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ExpandableHeaderViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var locationManager:CLLocationManager!
    var userLocation:CLLocation!
    var currentIndexPath: IndexPath!
    
    var sections = [
        Section(obsType: "❄️ Snowfall",
                obsTypeGradations: ["0-5cm", "5-15cm", "20cm+", "Thundersnow"],
                expanded: true),
        Section(obsType: "⛸️ Ice",
                obsTypeGradations: ["Refreezing snow", "Ice Pellets"],
                expanded: true),
        Section(obsType: "🌧️ Heavy Rain",
                obsTypeGradations: ["Limited visibility", "Flooding"],
                expanded: true)
    ]
    
    // Haal huidige locatie op voor doorgeven observatie
    func determineMyCurrentLocation() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // Hier komt de manipulatie van de coordinaatData
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocation = locations[0] as CLLocation
        
        // Geocoding voor coords naar plaatsnaam
        let geoCoder = CLGeocoder()
        let location = CLLocation(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
            
            var placeMark: CLPlacemark!
            placeMark = placemarks?[0]
            
            // Plaatsnaam uit dictionnary halen
            if let city = placeMark.addressDictionary!["City"] as? String {
                print("Observation for: \(city)")
                
                // Nieuwe observatie aanmaken
                let newObservation = Observation()
                
                // Attributen invullen
                newObservation.obsType = self.sections[self.currentIndexPath.section].obsType
                newObservation.gradation = self.sections[self.currentIndexPath.section].obsTypeGradations[self.currentIndexPath.row]
                newObservation.lat = self.userLocation.coordinate.latitude
                newObservation.lon = self.userLocation.coordinate.longitude
                newObservation.siteName = city
                newObservation.time = NSDate()
                
                // Observatie opslaan
                let repo = ObservationRepo()
                repo.addObservation(newObservation: newObservation)
                
            }
            
        })
        
    }
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        print("Error \(error)")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // aantal secties
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    // aantal rijen
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].obsTypeGradations.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (sections[indexPath.section].expanded){
            return 45
        }
            // indien niet uitgeklapt is de hoogte 0
        else {
            return 0
        }
    }
    
    // spacing tussen de secties
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 2
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header=ExpandableHeaderView()
        header.customInit(title: sections[section].obsType, section: section, delegate: self)
        
        return header
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell=tableView.dequeueReusableCell(withIdentifier: "labelCellWinter")!
        cell.textLabel?.text=sections[indexPath.section].obsTypeGradations[indexPath.row]
        
        return cell
    }
    
    func toggleSection(header: ExpandableHeaderView, section: Int) {
        sections[section].expanded = !sections[section].expanded
        
        tableView.beginUpdates()
        for i in 0 ..< sections[section].obsTypeGradations.count{
            tableView.reloadRows(at: [IndexPath(row: i, section: section)], with: .automatic)
        }
        tableView.endUpdates()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Actie bij het aanklikken van een rij
        // Set currentIndexPath
        currentIndexPath = indexPath
        
        // Bepaal mijn locatie maak observatie aan en sla deze op
        determineMyCurrentLocation()
        
        // Toon melding
        let alert = UIAlertController(title: "Info", message: "Observation added successfully!", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
