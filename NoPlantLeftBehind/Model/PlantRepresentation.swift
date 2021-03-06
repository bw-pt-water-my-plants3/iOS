//
//  PlantRepresentation.swift
//  NoPlantLeftBehind
//
//  Created by Kenneth Jones on 10/15/20.
//

import Foundation

struct PlantRepresentation: Codable {
    var id: String
    var nickname: String
    var species: String?
    var h2oFrequency: Int64
    var lastWatered: Date
    var timesWatered: Int64
//    var imageData: Data?
}
