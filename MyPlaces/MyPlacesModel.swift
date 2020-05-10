//
//  MyPlacesModel.swift
//  MyPlaces
//
//  Created by Roman Oliinyk on 09.05.2020.
//  Copyright © 2020 Roman Oliinyk. All rights reserved.
//

import Foundation

struct Place {
    var name: String
    var location: String
    var type: String
    var image: String
    
    static let restaurantNames = ["The Burger", "Sho", "Mister Cat",
                           "Пузата Хата", "Dominos", "23 Hookah",
                           "Papa Johns", "Viva Oliva", "Sparks"]
    
    static func getPlaces() -> [Place] {
        
        var places = [Place]()
        for place in restaurantNames {
            places.append(Place(name: place, location: "Киев", type: "Ресторан", image: place))
        }
        
        return places
    }
}


