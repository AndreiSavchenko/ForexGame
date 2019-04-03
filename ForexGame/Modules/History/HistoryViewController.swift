//
//  HistoryViewController.swift
//  ForexGame
//
//  Created by Alla on 3/30/19.
//  Copyright © 2019 AndreiSavchenko. All rights reserved.
//

import UIKit
import CoreData
import Charts

class HistoryViewController: UIViewController {

    @IBOutlet weak var historyTableView: UITableView!
    @IBOutlet weak var balanceLineChartView: LineChartView!

    private lazy var context = CoreDataStack.shared.persistentContainer.viewContext

    private lazy var fetchedResultsController: NSFetchedResultsController<Deal> = {
        let fetchRequest: NSFetchRequest<Deal> = Deal.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "timeClose", ascending: false)]
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

    func setChartBalance(profit: [Double], hasAnimate: Bool) {
        guard !profit.isEmpty else { return }
        var dataEntries: [ChartDataEntry] = []
        var dataEntriesStart: [ChartDataEntry] = []
        var profitStart = [Double] (repeating: 10000, count: profit.count)

        for i in 0..<profit.count {
            let dataEntry = ChartDataEntry(x: Double(i), y: profit[i])
            dataEntries.append(dataEntry)
        }
        for i in 0..<profitStart.count {
            let dataEntryStart = ChartDataEntry(x: Double(i), y: profitStart[i])
            dataEntriesStart.append(dataEntryStart)
        }

        let lineChartDataSet = LineChartDataSet(values: dataEntries, label: "Balance")
        lineChartDataSet.mode = .cubicBezier
        lineChartDataSet.drawCirclesEnabled = false         // без кругов
        lineChartDataSet.colors = [NSUIColor.init(named: "myWhite")] as! [NSUIColor]
        lineChartDataSet.lineWidth = 2.5
        lineChartDataSet.cubicIntensity = 0.2
        lineChartDataSet.drawValuesEnabled = false
//        let gradient = getGradientFilling()
//        lineChartDataSet.fill = Fill.fillWithLinearGradient(gradient, angle: 90.0)
        lineChartDataSet.drawFilledEnabled = true

        let lineChartDataSetStart = LineChartDataSet(values: dataEntriesStart, label: "Balance Start")
        lineChartDataSetStart.mode = .cubicBezier
        lineChartDataSetStart.drawCirclesEnabled = false         // без кругов
        lineChartDataSetStart.lineWidth = 1.5
        lineChartDataSetStart.drawValuesEnabled = false

        let lineChartData = LineChartData(dataSets: [lineChartDataSet, lineChartDataSetStart])
//        let lineChartData = LineChartData(dataSets: [lineChartDataSet])
        balanceLineChartView.data = lineChartData
        balanceLineChartView.setScaleEnabled(false)
        balanceLineChartView.drawGridBackgroundEnabled = false
        balanceLineChartView.xAxis.drawAxisLineEnabled = true
        balanceLineChartView.xAxis.drawGridLinesEnabled = true
        balanceLineChartView.xAxis.enabled = true
        balanceLineChartView.xAxis.drawLabelsEnabled = false
        balanceLineChartView.leftAxis.drawAxisLineEnabled = false
        balanceLineChartView.leftAxis.drawGridLinesEnabled = false
        balanceLineChartView.leftAxis.enabled = false
        balanceLineChartView.rightAxis.drawAxisLineEnabled = true
        balanceLineChartView.rightAxis.drawGridLinesEnabled = true
        balanceLineChartView.legend.enabled = false

        if hasAnimate {
            balanceLineChartView.animate(xAxisDuration: 1.5)
        }
    }

    func createArrayBalanceHistory() -> [Double] {
        var arrBalance: [Double] = []

        try? fetchedResultsController.performFetch()

        guard let count = fetchedResultsController.fetchedObjects?.count, count > 0 else { return [] }
            for i in 0..<count {
                arrBalance.append(Double((fetchedResultsController.fetchedObjects?[i].balanceFix)!))
            }
        arrBalance.reverse()
        arrBalance.insert(10000, at: 0)
        return arrBalance
    }

    func alert() {
        let alert = UIAlertController(title: "Oops !!!",
                                      message: "You have no orders yet ;)",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default) { (_) in
            let vc = UIStoryboard(name: "Main",
                                  bundle: nil).instantiateViewController(withIdentifier:
                                    "EurUsdViewController") as! EurUsdViewController
            self.present(vc, animated: true, completion: nil)
        })
        self.present(alert, animated: true, completion: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        if fetchedResultsController.fetchedObjects?.count == 0 {
            alert()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        setChartBalance(profit: createArrayBalanceHistory(), hasAnimate: true)

        let cellNib = UINib(nibName: "HistoryTableViewCell", bundle: nil)
        historyTableView.register(cellNib, forCellReuseIdentifier: HistoryTableViewCell.reuseIdentifier)

    }

}

extension HistoryViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.fetchedObjects?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = historyTableView.dequeueReusableCell(withIdentifier: HistoryTableViewCell.reuseIdentifier,
                                                        for: indexPath)
        var profitString: String
        guard let profitCell = fetchedResultsController.fetchedObjects?[indexPath.row].profit else { return cell }
        if profitCell > 0 {
            profitString = "+"+String(profitCell)+"$"
            (cell as? HistoryTableViewCell)?.cellRoundedView.backgroundColor = UIColor(named: "myGreen")
        } else if profitCell < 0 {
            profitString = String(profitCell)+"$"
            (cell as? HistoryTableViewCell)?.cellRoundedView.backgroundColor =
                UIColor(named: "myRed")
        } else {
            profitString = String(profitCell)+"$"
            (cell as? HistoryTableViewCell)?.cellRoundedView.backgroundColor =
                UIColor(named: "myOrange")
        }

//        let currencyPair = fetchedResultsController.fetchedObjects?[indexPath.row].currencyPair
//        let type = fetchedResultsController.fetchedObjects?[indexPath.row].type
//        guard let balanceCell = fetchedResultsController.fetchedObjects?[indexPath.row].balanceFix else { return cell }
//
//        (cell as? HistoryTableViewCell)?.profitLabel.text = profitString + " " + currencyPair + " " + type + " Balance:" + balanceCell
        (cell as? HistoryTableViewCell)?.profitLabel.text = profitString
        (cell as? HistoryTableViewCell)?.currencyPairLabel.text =
            fetchedResultsController.fetchedObjects?[indexPath.row].currencyPair
        (cell as? HistoryTableViewCell)?.typeLabel.text = fetchedResultsController.fetchedObjects?[indexPath.row].type

        guard let balanceCell = fetchedResultsController.fetchedObjects?[indexPath.row].balanceFix else { return cell }
        (cell as? HistoryTableViewCell)?.balanceLabel.text = String(balanceCell)

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
