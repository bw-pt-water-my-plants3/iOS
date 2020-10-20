//
//  PlantsTableViewController.swift
//  NoPlantLeftBehind
//
//  Created by Kenneth Jones on 10/17/20.
//

import UIKit
import CoreData

class PlantsTableViewController: UITableViewController {

    private let plantController = PlantController()

    lazy var fetchedResultsController: NSFetchedResultsController<Plant> = {
        let fetchRequest: NSFetchRequest<Plant> = Plant.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "lastWatered", ascending: false)
        ]
        
        let moc = CoreDataStack.shared.mainContext
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: moc, sectionNameKeyPath: "lastWatered", cacheName: nil)
        frc.delegate = self
        do {
            try frc.performFetch()
        } catch {
            NSLog("Error fetching Plant objects: \(error)")
        }
        return frc
    }()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        tableView.reloadData()
    }

    @IBAction func refresh(_ sender: Any) {
        plantController.fetchPlantsFromServer { _ in
            DispatchQueue.main.async {
                self.refreshControl?.endRefreshing()
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PlantTableViewCell.reuseIdentifier, for: indexPath) as? PlantTableViewCell else {
            fatalError("Can't dequeue cell of type \(PlantTableViewCell.reuseIdentifier)")
        }

        cell.delegate = self
        cell.plant = fetchedResultsController.object(at: indexPath)
        cell.backgroundView = UIImageView(image: UIImage(named: "cardframe"))

        return cell
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let plant = fetchedResultsController.object(at: indexPath)
            let moc = CoreDataStack.shared.mainContext
            moc.delete(plant)
            plantController.deletePlantFromServer(plant) { (result) in
                guard let _ = try? result.get() else { return }
                DispatchQueue.main.async {
                    do {
                        try moc.save()
                        tableView.reloadData()
                    } catch {
                        moc.reset()
                        NSLog("Error saving managed object context: \(error)")
                    }
                }
            }
        }
    }

//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "ShowPlantSegue" {
//            if let detailVC = segue.destination as? PlantDetailViewController,
//                let indexPath = tableView.indexPathForSelectedRow {
//                detailVC.plant = fetchedResultsController.object(at: indexPath)
//                detailVC.plantController = plantController
//            }
//        } else if segue.identifier == "CreatePlantSegue" {
//            if let navController = segue.destination as? UINavigationController,
//                let createPlantVC = navController.viewControllers.first as? CreatePlantViewController {
//                createPlantVC.plantController = self.plantController
//            }
//        }
//    }

}

extension PlantsTableViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange sectionInfo: NSFetchedResultsSectionInfo,
                    atSectionIndex sectionIndex: Int,
                    for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .automatic)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .automatic)
        default:
            break
        }
    }
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            guard let newIndexPath = newIndexPath else { return }
            tableView.insertRows(at: [newIndexPath], with: .automatic)
        case .update:
            guard let indexPath = indexPath else { return }
            tableView.reloadRows(at: [indexPath], with: .automatic)
        case .move:
            guard let oldIndexPath = indexPath,
                let newIndexPath = newIndexPath else { return }
            tableView.deleteRows(at: [oldIndexPath], with: .automatic)
            tableView.insertRows(at: [newIndexPath], with: .automatic)
        case .delete:
            guard let indexPath = indexPath else { return }
            tableView.deleteRows(at: [indexPath], with: .automatic)
        @unknown default:
            break
        }
    }
}

extension PlantsTableViewController: PlantTableViewCellDelegate {
    func didUpdatePlant(plant: Plant) {
        plantController.sendPlantToServer(plant: plant)
    }
}
