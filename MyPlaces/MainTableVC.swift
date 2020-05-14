//
//  MainTableVC.swift
//  MyPlaces
//
//  Created by Roman Oliinyk on 08.05.2020.
//  Copyright © 2020 Roman Oliinyk. All rights reserved.
//

import UIKit
import RealmSwift

class MainTableVC: UITableViewController {
    
    var places: Results<Place>!
    var ascendingSorting = true
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var sortBarButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "My Places"
        
        places = realm.objects(Place.self)
        
    }
    
    @IBAction func reversedSorting(_ sender: UIBarButtonItem) {
        ascendingSorting.toggle()
        sorting()
    }
    
    
    @IBAction func selectSorting(_ sender: UISegmentedControl) {
        sorting()
    }
    
    private func sorting() {
        if segmentedControl.selectedSegmentIndex == 0 {
            places = places.sorted(byKeyPath: "date", ascending: ascendingSorting)
              } else {
                  places = places.sorted(byKeyPath: "name", ascending: ascendingSorting)
              }
        tableView.reloadData()
    }
    

//     MARK: - Table view data source
//     The filling of the table

    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.isEmpty ? 0 : places.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomTableViewCell

        let place = places[indexPath.row]

        cell.nameLabel.text = place.name
        cell.locationLabel.text = place.location
        cell.typeLabel.text = place.type
        
        cell.imageOfPlace.image = UIImage(data: place.imageData!)

        cell.imageOfPlace.layer.cornerRadius = cell.imageOfPlace.frame.size.width / 2
        cell.imageOfPlace.clipsToBounds = true


        return cell

    }

// MARK: - Table view delegate
// The appearence of the cell

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }
    
    
    
//    deleting rows
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
          if editingStyle == .delete {
            let place = places[indexPath.row]
            StorageManager.deleteObject(place)
            tableView.deleteRows(at: [indexPath], with: .fade)
          }
    }
          
      
    
// MARK: - Segues
// saving new elemnt 
    
    @IBAction func unwindSegue(_ segue: UIStoryboardSegue) {
        guard let newPlaceVC = segue.source as? NewPlaceTableVC else { return }
        newPlaceVC.savePlace()
        tableView.reloadData()
    }

    @IBAction func cancelAction(_ segue: UIStoryboardSegue) {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "showDetail" else { return }
        guard let indexPath = tableView.indexPathForSelectedRow else { return }
        let place = places[indexPath.row]
        let newPlaceVC = segue.destination as! NewPlaceTableVC
        newPlaceVC.currentPlace = place
    }
    
}
 
 
