//
//  AddPlantViewController.swift
//  NoPlantLeftBehind
//
//  Created by Kenneth Jones on 10/21/20.
//

import UIKit

class AddPlantViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var plantController: PlantController?

    @IBOutlet weak var nameLabel: UITextField!
    @IBOutlet weak var speciesLabel: UITextField!
    @IBOutlet weak var frequencyLabel: UITextField!
    @IBOutlet weak var plantImageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        let imageView = UIImageView(frame: UIScreen.main.bounds)
        imageView.image = UIImage(named: "tropical")
        imageView.contentMode = .scaleToFill
        self.view.insertSubview(imageView, at: 0)
        navigationController?.navigationBar.backgroundColor = UIColor(white: 1, alpha: 0.75)
        nameLabel.becomeFirstResponder()
    }

    @IBAction func addPhotoTapped(_ sender: Any) {
        self.view.endEditing(true)
        
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.allowsEditing = false
        pickerController.mediaTypes = ["public.image"]
        pickerController.sourceType = .photoLibrary

        present(pickerController, animated: true, completion: nil)
    }

    @IBAction func cancelTapped(_ sender: UIBarButtonItem) {
        navigationController?.dismiss(animated: true, completion: nil)
    }

    @IBAction func saveTapped(_ sender: UIBarButtonItem) {
        guard let name = nameLabel.text,
            !name.isEmpty,
            let frequency = frequencyLabel.text,
            !frequency.isEmpty,
            let freqNum = Int64(frequency) else {
            return
        }

        let species = speciesLabel.text
        let imageData = plantImageView.image?.pngData()

        let plant = Plant(nickname: name, species: species, h2oFrequency: freqNum, lastWatered: Date(timeIntervalSince1970: 2), timesWatered: 0, imageData: imageData)
        plantController?.sendPlantToServer(plant: plant)

        do {
            try CoreDataStack.shared.mainContext.save()
            navigationController?.dismiss(animated: true, completion: nil)
        } catch {
            NSLog("Error saving managed object context: \(error)")
        }
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            plantImageView.image = pickedImage
        }

        dismiss(animated: true, completion: nil)
    }

}
