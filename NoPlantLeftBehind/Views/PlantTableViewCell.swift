//
//  PlantTableViewCell.swift
//  NoPlantLeftBehind
//
//  Created by Kenneth Jones on 10/17/20.
//

import UIKit

protocol PlantTableViewCellDelegate: class {
    func didUpdatePlant(plant: Plant)
}

class PlantTableViewCell: UITableViewCell {

    @IBOutlet weak var plantImageView: UIImageView!
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var frequencyLabel: UILabel!
    @IBOutlet weak var wateredLabel: UILabel!

    weak var delegate: PlantTableViewCellDelegate?
    static let reuseIdentifier = "PlantCell"

    var plant: Plant? {
        didSet {
            updateViews()
        }
    }

    var formatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.dateFormat = "MMM dd, yyyy' at 'h:mm:ss a"
        return formatter
    }

    private func updateViews() {
        guard let plant = plant else { return }

        nicknameLabel.text = plant.nickname
        frequencyLabel.text = "Water every \(plant.h2oFrequency) days"

        if let watered = plant.lastWatered {
            wateredLabel.text = formatter.string(from: watered)
        } else {
            wateredLabel.text = "Never!"
        }

        plantImageView.image = UIImage(systemName: "leaf.arrow.circlepath")
        // MARK: - TODO: Add image to imageview
    }

}
