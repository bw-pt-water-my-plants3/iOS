//
//  Plant+Convenience.swift
//  NoPlantLeftBehind
//
//  Created by Kenneth Jones on 10/15/20.
//

import Foundation
import CoreData

extension Plant {
    var plantRepresentation: PlantRepresentation? {
        guard let nickname = nickname else { return nil }
        
        return PlantRepresentation(id: id?.uuidString ?? "", nickname: nickname, species: species ?? "Unknown", h2oFrequency: h2oFrequency)
    }
    @discardableResult convenience init(id: UUID = UUID(),
                                        nickname: String,
                                        species: String? = "Unknown",
                                        h2oFrequency: Int16,
                                        context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: context)
        self.id = id
        self.nickname = nickname
        self.species = species
        self.h2oFrequency = h2oFrequency
    }
    
    @discardableResult convenience init?(plantRepresentation: PlantRepresentation, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        guard let id = UUID(uuidString: plantRepresentation.id) else {
                return nil }
        
        self.init(id: id,
                  nickname: plantRepresentation.nickname,
                  species: plantRepresentation.species,
                  h2oFrequency: plantRepresentation.h2oFrequency,
                  context: context)
    }
}