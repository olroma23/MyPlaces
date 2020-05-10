//
//  NewPlaceTableVC.swift
//  MyPlaces
//
//  Created by Roman Oliinyk on 09.05.2020.
//  Copyright © 2020 Roman Oliinyk. All rights reserved.
//

import UIKit

class NewPlaceTableVC: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        
        if indexPath.row == 0 {
            let actionSheet = UIAlertController(title: nil,
                                                message: nil,
                                                preferredStyle: .actionSheet)
            
            let camera = UIAlertAction(title: "Camera", style: .default) { _ in
                self.chooseImagePicker(source: .camera)
            }
            let photo = UIAlertAction(title: "Photo", style: .default) { _ in
                self.chooseImagePicker(source: .photoLibrary)
            }
            let cancel = UIAlertAction(title: "Cancel", style: .cancel)
            
            actionSheet.addAction(camera)
            actionSheet.addAction(photo)
            actionSheet.addAction(cancel)
            
            present(actionSheet, animated: true)
            
        } else {
            view.endEditing(true)
        }
    }
    
    
}


// MARK: Text field delegate


extension NewPlaceTableVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}


// MARK: Setting the image

extension NewPlaceTableVC {
    func chooseImagePicker(source: UIImagePickerController.SourceType) {
        guard UIImagePickerController.isSourceTypeAvailable(source) else { return }
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.sourceType = source
        present(imagePicker, animated: true, completion: nil)
    }
}

