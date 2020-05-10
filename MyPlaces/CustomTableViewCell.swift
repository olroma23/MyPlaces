//
//  CustomTableViewCell.swift
//  MyPlaces
//
//  Created by Roman Oliinyk on 08.05.2020.
//  Copyright © 2020 Roman Oliinyk. All rights reserved.
//

import UIKit

class CustomTableViewCell: UITableViewCell {

    @IBOutlet weak var imageOfPlace: UIImageView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
  

        // Configure the view for the selected state
    }

}
