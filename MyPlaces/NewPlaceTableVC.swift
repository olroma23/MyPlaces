//
//  NewPlaceTableVC.swift
//  MyPlaces
//
//  Created by Roman Oliinyk on 09.05.2020.
//  Copyright © 2020 Roman Oliinyk. All rights reserved.
//

import UIKit

class NewPlaceTableVC: UITableViewController {
    
    @IBOutlet weak var imageOfPlace: UIImageView!
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var locationTF: UITextField!
    @IBOutlet weak var typeTF: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    var currentPlace: Place?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        saveButton.isEnabled = false
        setupEditScreen()
        nameTF.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
    }
    
    
    //    showing the menu, when the image is tapped
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
    
    
    //       adding a new row to the table
    func savePlace() {
        
        let imageData = imageOfPlace.image?.pngData()
        
        let newPlace = Place(name: nameTF.text!, location: locationTF.text, type: typeTF.text, imageData: imageData)
        
        if currentPlace != nil {
            try! realm.write {
                currentPlace?.name = newPlace.name
                currentPlace?.location = newPlace.location
                currentPlace?.type = newPlace.type
                currentPlace?.imageData = newPlace.imageData
            }
        } else {
            StorageManager.saveObject(newPlace)
        }
    }
    
    
    private func setupEditScreen() {
        guard currentPlace != nil else { return }
        guard let data = currentPlace?.imageData, let image = UIImage(data: data) else { return }
        imageOfPlace.image = image
        imageOfPlace.contentMode = .scaleAspectFill
        nameTF.text = currentPlace?.name
        locationTF.text = currentPlace?.location
        typeTF.text = currentPlace?.type
        setupNavigationBar()
    }
    
    private func setupNavigationBar() {
        navigationItem.leftBarButtonItem = nil
        title = nameTF.text
        saveButton.isEnabled = true
        navigationController?.navigationBar.prefersLargeTitles = true
    }
}


// MARK: Text field delegate

extension NewPlaceTableVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc func textFieldChanged() {
        if nameTF.text?.isEmpty == false {
            saveButton.isEnabled = true
        } else {
            saveButton.isEnabled = false
        }
    }
}


// MARK: Setting the image

// Setting the new image view
extension NewPlaceTableVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func chooseImagePicker(source: UIImagePickerController.SourceType) {
        guard UIImagePickerController.isSourceTypeAvailable(source) else { return }
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = source
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageOfPlace.image = info[.editedImage] as? UIImage
        imageOfPlace.contentMode = .scaleAspectFill
        imageOfPlace.clipsToBounds = true
        dismiss(animated: true, completion: nil)
    }
}
