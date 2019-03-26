//
//  EurUsdViewController.swift
//  ForexGame
//
//  Created by Alla on 3/3/19.
//  Copyright © 2019 AndreiSavchenko. All rights reserved.
//

import UIKit
import Charts
import Moya

class EurUsdViewController: UIViewController {

    @IBOutlet weak var eurUsdLineChartView: LineChartView!

    let ratesService = RatesService.shared
    let coreDataService = CoreDataService.shared
    var prices: [Double] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        ratesService.downloadPointsToCoreData()
        prices = coreDataService.createArrayPointsEurusd() // Спросить за флаги с других//Где нужно запускать эту функцию

//        coreDataService.updateCartEurusd()
//        if ratesService.isWorking == true {
//            prices = coreDataService.createArrayPointsEurusd()
////            ratesService.isUpdateChart = false
//        }

//        let prices = [1.23000, 1.23010, 1.23020, 1.23050, 1.23040,
//                      1.23030, 1.23020, 1.23050, 1.23080, 1.23130,
//                      1.23120, 1.23090, 1.23060, 1.23100, 1.23140,
//                      1.23190, 1.23220, 1.23200, 1.23190, 1.23200]
        setChart(prices: prices)

    }

    func setChart(prices: [Double]) {

        var dataEntries: [ChartDataEntry] = []

        for i in 0..<prices.count {
            let dataEntry = ChartDataEntry(x: Double(i), y: prices[i])
            dataEntries.append(dataEntry)
        }

        let lineChartDataSet = LineChartDataSet(values: dataEntries, label: "EUR/USD")
        lineChartDataSet.mode = .cubicBezier
        lineChartDataSet.drawCirclesEnabled = false         // без кругов
        lineChartDataSet.colors = [NSUIColor.white]
        lineChartDataSet.lineWidth = 2.5
        lineChartDataSet.cubicIntensity = 0.2
        lineChartDataSet.drawValuesEnabled = false

        let gradient = getGradientFilling()
        lineChartDataSet.fill = Fill.fillWithLinearGradient(gradient, angle: 90.0)
        lineChartDataSet.drawFilledEnabled = true

        let lineChartData = LineChartData(dataSet: lineChartDataSet)
        eurUsdLineChartView.data = lineChartData
        eurUsdLineChartView.setScaleEnabled(false)
        eurUsdLineChartView.animate(xAxisDuration: 1.5)
        eurUsdLineChartView.drawGridBackgroundEnabled = false
        eurUsdLineChartView.xAxis.drawAxisLineEnabled = true
        eurUsdLineChartView.xAxis.drawGridLinesEnabled = false
        eurUsdLineChartView.leftAxis.drawAxisLineEnabled = false
        eurUsdLineChartView.leftAxis.drawGridLinesEnabled = false
        eurUsdLineChartView.rightAxis.drawAxisLineEnabled = false
        eurUsdLineChartView.rightAxis.drawGridLinesEnabled = false
        eurUsdLineChartView.legend.enabled = false
        eurUsdLineChartView.xAxis.enabled = false
        eurUsdLineChartView.leftAxis.enabled = false
        eurUsdLineChartView.xAxis.drawLabelsEnabled = false
    }

}

private func getGradientFilling() -> CGGradient {
//    let colorTop = UIColor(red: 141/255, green: 133/255, blue: 220/255, alpha: 1).cgColor
    let colorTop = UIColor(named: "ColorTextWhite")!.cgColor
    let colorBotton = UIColor(named: "1ColorAquaDark")!.cgColor
    let colorsGradient = [colorTop, colorBotton] as CFArray
    let colorLocations: [CGFloat] = [0.7, 0.0]

    return CGGradient.init(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                           colors: colorsGradient,
                           locations: colorLocations)!
}
