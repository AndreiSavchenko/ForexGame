//
//  HistoryViewController.swift
//  ForexGame
//
//  Created by Alla on 3/30/19.
//  Copyright © 2019 AndreiSavchenko. All rights reserved.
//

import UIKit
import CoreData

class HistoryViewController: UIViewController {

    @IBOutlet weak var historyTableView: UITableView!
//    let dealsHist = Deals.shared
    let dealsClosed = Deals.shared.getAllCloseDeals()

    private lazy var context = CoreDataStack.shared.persistentContainer.viewContext

    private lazy var fetchedResultsController: NSFetchedResultsController<Deal> = {
        let fetchRequest: NSFetchRequest<Deal> = Deal.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "timeClose", ascending: true)]
        let controller = NSFetchedResultsController<Deal>(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        controller.delegate = self
        try? controller.performFetch()
        return controller
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        let cellNib = UINib(nibName: "HistoryTableViewCell", bundle: nil)
        historyTableView.register(cellNib, forCellReuseIdentifier: HistoryTableViewCell.reuseIdentifier)
    }

}

extension HistoryViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dealsClosed.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = historyTableView.dequeueReusableCell(withIdentifier: HistoryTableViewCell.reuseIdentifier,
                                                        for: indexPath)
        var profitString: String
        guard let profitCell = fetchedResultsController.fetchedObjects?[indexPath.row].profit else { return cell }
        if profitCell > 0 {
            profitString = "+"+String(profitCell)+"$"
            (cell as? HistoryTableViewCell)?.cellRoundedView.backgroundColor = UIColor(named: "1ColorGreen")
        } else if profitCell < 0 {
            profitString = String(profitCell)+"$"
            (cell as? HistoryTableViewCell)?.cellRoundedView.backgroundColor =
                UIColor(named: "AdditionalColor")
        } else {
            profitString = String(profitCell)+"$"
            (cell as? HistoryTableViewCell)?.cellRoundedView.backgroundColor =
                UIColor(named: "myOrange")
        }

        (cell as? HistoryTableViewCell)?.profitLabel.text = profitString
        (cell as? HistoryTableViewCell)?.currencyPairLabel.text =
            fetchedResultsController.fetchedObjects?[indexPath.row].currencyPair
        (cell as? HistoryTableViewCell)?.typeLabel.text = fetchedResultsController.fetchedObjects?[indexPath.row].type

        return cell
    }
}

extension HistoryViewController: NSFetchedResultsControllerDelegate {

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        historyTableView.beginUpdates()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange sectionInfo: NSFetchedResultsSectionInfo,
                    atSectionIndex sectionIndex: Int,
                    for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            historyTableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            historyTableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        case .move:
            break
        case .update:
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
            historyTableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            historyTableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            historyTableView.reloadRows(at: [indexPath!], with: .fade)
        case .move:
            historyTableView.moveRow(at: indexPath!, to: newIndexPath!)
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        historyTableView.endUpdates()
    }
}
