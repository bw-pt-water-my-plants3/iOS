//
//  PlantController.swift
//  NoPlantLeftBehind
//
//  Created by Kenneth Jones on 10/15/20.
//

import Foundation
import CoreData

enum NetworkError: Error {
    case noIdentifier, otherError, noData, noDecode, noEncode, noRep
}

let baseURL = URL(string: "https://plants-34ede.firebaseio.com/")!

class PlantController {
    typealias CompletionHandler = (Result<Bool, NetworkError>) -> Void

    init() {
        fetchPlantsFromServer()
    }

    // Fetch Plants from firebase
    func fetchPlantsFromServer(completion: @escaping CompletionHandler = { _ in }) {
        let requestURL = baseURL.appendingPathExtension("json")

        URLSession.shared.dataTask(with: requestURL) { (data, _, error) in
            if let error = error {
                print("Error fetching plants: \(error)")
                DispatchQueue.main.async {
                    completion(.failure(.otherError))
                }
                return
            }

            guard let data = data else {
                print("No data returned by data task")
                DispatchQueue.main.async {
                    completion(.failure(.noData))
                }
                return
            }

            do {
                let plantRepresentations = Array(try JSONDecoder().decode([String: PlantRepresentation].self,
                                                                          from: data).values)

                try self.updatePlants(with: plantRepresentations)
                DispatchQueue.main.async {
                    completion(.success(true))
                }
            } catch {
                print("Error decoding plant representations: \(error)")
                DispatchQueue.main.async {
                    completion(.failure(.noDecode))
                }
                return
            }
        }.resume()
    }

    func sendPlantToServer(plant: Plant, completion: @escaping CompletionHandler = { _ in }) {
        guard let uuid = plant.id else {
            completion(.failure(.noIdentifier))
            return
        }

        let requestURL = baseURL.appendingPathComponent(uuid.uuidString).appendingPathExtension("json")

        var request = URLRequest(url: requestURL)
        request.httpMethod = "PUT"

        do {
            guard let representation = plant.plantRepresentation else {
                completion(.failure(.noRep))
                return
            }

            request.httpBody = try JSONEncoder().encode(representation)
        } catch {
            print("Error encoding plant \(plant): \(error)")
            completion(.failure(.noEncode))
            return
        }

        URLSession.shared.dataTask(with: request) { (_, _, error) in
            if let error = error {
                print("Error PUTting plant to server: \(error)")
                DispatchQueue.main.async {
                    completion(.failure(.otherError))
                    return
                }
            }

            DispatchQueue.main.async {
                completion(.success(true))
            }
        }.resume()
    }

    // Update/Create Plants with Representations
    private func updatePlants(with representations: [PlantRepresentation]) throws {

        let context = CoreDataStack.shared.container.newBackgroundContext()

        // Array of UUIDs
        let identifiersToFetch = representations.compactMap({ UUID(uuidString: $0.id )})

        let representationsByID = Dictionary(uniqueKeysWithValues: zip(identifiersToFetch, representations))
        var plantsToCreate = representationsByID

        let fetchRequest: NSFetchRequest<Plant> = Plant.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "identifier IN %@", identifiersToFetch)
        context.perform {
            do {
                let existingPlants = try context.fetch(fetchRequest)

                // For already existing plants
                for plant in existingPlants {
                    guard let id = plant.id,
                        let representation = representationsByID[id] else { continue }
                    // Update plant
                    self.update(plant: plant, with: representation)
                    plantsToCreate.removeValue(forKey: id)
                }

                // For new plants
                for representation in plantsToCreate.values {
                    Plant(plantRepresentation: representation, context: context)
                }
            } catch {
                print("Error fetching plants for UUIDs: \(error)")
            }

            do {
                try CoreDataStack.shared.save(context: context)
            } catch {
                print("There's an error!")
            }
        }
    }

    private func update(plant: Plant, with representation: PlantRepresentation) {
        plant.nickname = representation.nickname
        plant.species = representation.species
        plant.h2oFrequency = representation.h2oFrequency
    }

    func deletePlantFromServer(_ plant: Plant, completion: @escaping CompletionHandler = { _ in }) {
        guard let uuid = plant.id else {
            completion(.failure(.noIdentifier))
            return
        }

        let requestURL = baseURL.appendingPathComponent(uuid.uuidString).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = "DELETE"

        URLSession.shared.dataTask(with: request) { (_, response, _) in
            print(response!)
            completion(.success(true))
        }.resume()
    }

    private func saveToPersistentStore() throws {
        let moc = CoreDataStack.shared.mainContext
        try moc.save()
    }
}
