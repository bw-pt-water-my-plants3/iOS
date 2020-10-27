//
//  PlantTableViewCell.swift
//  NoPlantLeftBehind
//
//  Created by Kenneth Jones on 10/17/20.
//

import UIKit

class PlantTableViewCell: UITableViewCell {

    @IBOutlet weak var plantImageView: UIImageView!
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var frequencyLabel: UILabel!
    @IBOutlet weak var wateredLabel: UILabel!

    static let reuseIdentifier = "PlantCell"

    var plant: Plant? {
        didSet {
            updateViews()
        }
    }

    var formatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.dateFormat = "MM-dd-yy' at 'h:mm a"
        return formatter
    }

    private func updateViews() {
        guard let plant = plant else { return }

        nicknameLabel.text = plant.nickname
        if plant.h2oFrequency == 1 {
            frequencyLabel.text = "Water every day"
        } else {
            frequencyLabel.text = "Water every \(plant.h2oFrequency) days"
        }

        if plant.timesWatered == 0 {
            wateredLabel.text = "Never!"
        } else {
            if let watered = plant.lastWatered {
                wateredLabel.text = formatter.string(from: watered)
            }
        }

        plantImageView.image = UIImage(data: (plant.imageData ?? UIImage(named: "blackplant")!.pngData())!)
    }

}
