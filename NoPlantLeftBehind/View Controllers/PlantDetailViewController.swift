//
//  PlantDetailViewController.swift
//  NoPlantLeftBehind
//
//  Created by Kenneth Jones on 10/21/20.
//

import UIKit

class PlantDetailViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var plantController: PlantController?
    var plant: Plant?
    var wasEdited = false

    @IBOutlet weak var nameLabel: UITextField!
    @IBOutlet weak var speciesLabel: UITextField!
    @IBOutlet weak var frequencyLabel: UITextField!
    @IBOutlet weak var lastWateredLabel: UITextField!
    @IBOutlet weak var plantImageView: UIImageView!
    @IBOutlet weak var editPhotoButton: UIButton!

    var formatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.dateFormat = "MMM dd, yyyy' at 'h:mm:ss a"
        return formatter
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = editButtonItem
        
        let imageView = UIImageView(frame: UIScreen.main.bounds)
        imageView.image = UIImage(named: "tropical")
        imageView.contentMode = .scaleToFill
        self.view.insertSubview(imageView, at: 0)
        navigationController?.navigationBar.backgroundColor = UIColor(white: 1, alpha: 0.75)
        
        updateViews()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if wasEdited {
            guard let name = nameLabel.text,
                !name.isEmpty,
                let frequency = frequencyLabel.text,
                !frequency.isEmpty,
                let freqNum = Int64(frequency),
                let plant = plant else {
                return
            }
            plant.nickname = name
            plant.h2oFrequency = freqNum
            plant.species = speciesLabel.text
            plant.imageData = plantImageView.image?.pngData()
            plantController?.sendPlantToServer(plant: plant)
            do {
                try CoreDataStack.shared.mainContext.save()
            } catch {
                NSLog("Error saving managed object context: \(error)")
            }
        }
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        if editing { wasEdited = true }
        nameLabel.isUserInteractionEnabled = editing
        speciesLabel.isUserInteractionEnabled = editing
        frequencyLabel.text = String(plant!.h2oFrequency)
        frequencyLabel.isUserInteractionEnabled = editing
        editPhotoButton.isHidden = !editing
        navigationItem.hidesBackButton = editing
    }

    @IBAction func editPhotoTapped(_ sender: Any) {
        self.view.endEditing(true)
        
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.allowsEditing = false
        pickerController.mediaTypes = ["public.image"]
        pickerController.sourceType = .photoLibrary

        present(pickerController, animated: true, completion: nil)
    }

    @IBAction func waterButtonTapped(_ sender: Any) {
        self.view.endEditing(true)
        
        guard let plant = plant else { return }

        plant.timesWatered += 1
        plant.lastWatered = Date()
        lastWateredLabel.text = "Last watered: \(formatter.string(from: plant.lastWatered!))"
        plantController?.sendPlantToServer(plant: plant)
        do {
            try CoreDataStack.shared.mainContext.save()
        } catch {
            NSLog("Error saving managed object context: \(error)")
        }
    }

    func updateViews() {
        guard let plant = plant else { return }

        nameLabel.text = plant.nickname
        nameLabel.isUserInteractionEnabled = isEditing

        speciesLabel.text = plant.species
        speciesLabel.isUserInteractionEnabled = isEditing

        frequencyLabel.text = "Water every \(plant.h2oFrequency) days"
        frequencyLabel.isUserInteractionEnabled = isEditing

        plantImageView.image = UIImage(data: (plant.imageData)!)
        editPhotoButton.isHidden = !isEditing

        if plant.timesWatered != 0 {
            lastWateredLabel.text = "Last watered: \(formatter.string(from: plant.lastWatered!))"
        } else {
            lastWateredLabel.text = "This plant has NEVER been watered!😱"
        }

        lastWateredLabel.isUserInteractionEnabled = false
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            plantImageView.image = pickedImage
        }

        dismiss(animated: true, completion: nil)
    }

}
