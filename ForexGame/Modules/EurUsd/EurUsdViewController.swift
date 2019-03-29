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

    let ratesService = RatesService.shared
    let coreDataService = CoreDataService.shared
    let deals = Deals.shared
    var prices: [Double] = []

    @IBOutlet weak var eurUsdLineChartView: LineChartView!
    @IBOutlet weak var buySellStackView: UIStackView!
    @IBOutlet weak var closeStackView: UIStackView!
    @IBOutlet weak var currentPriceLabel: UILabel!
    @IBOutlet weak var currentProfitLabel: UILabel!

    @IBAction func buyButton(_ sender: UIButton) {
        buySellStackView.isHidden = true
        closeStackView.isHidden = false
        let priceCurrent = coreDataService.lastPrice()
        deals.openDeals(currencyPair: "EurUsd", type: "Buy", timeOpen: NSDate(), priceOpen: priceCurrent)

    }

    @IBAction func sellButton(_ sender: UIButton) {
        buySellStackView.isHidden = true
        closeStackView.isHidden = false
        let priceCurrent = coreDataService.lastPrice()
        deals.openDeals(currencyPair: "EurUsd", type: "Sell", timeOpen: NSDate(), priceOpen: priceCurrent)
    }

    @IBAction func closeButton(_ sender: UIButton) {
        closeStackView.isHidden = true
        buySellStackView.isHidden = false
        let priceCurrent = coreDataService.lastPrice()
        deals.closeDeals(timeClose: NSDate(), priceClose: priceCurrent)
    }

    @IBAction func historyButton(_ sender: UIButton) {

    }

    override func viewDidLoad() {
        super.viewDidLoad()
        ratesService.onPricesUpdated = { [weak self] in
            guard let self = self else { return }
            self.prices = self.coreDataService.createArrayPointsEurusd()
            self.setChart(prices: self.prices, hasAnimate: false)

            if self.closeStackView.isHidden {
                self.currentPriceLabel.text = String(self.coreDataService.lastPrice())
            }
            if self.buySellStackView.isHidden {
                let currProfit = self.deals.currProfit()
                if currProfit > 0 {
                    self.currentProfitLabel.text = "+"+String(currProfit)+"$"
                } else {
                    self.currentProfitLabel.text = String(currProfit)+"$"
                }

            }
        }

        ratesService.downloadPointsToCoreData()
        prices = coreDataService.createArrayPointsEurusd()
        setChart(prices: prices, hasAnimate: true)
    }

    func setChart(prices: [Double], hasAnimate: Bool) {
        guard !prices.isEmpty else { return }
        var dataEntries: [ChartDataEntry] = []
        var dataEntriesCurr: [ChartDataEntry] = []
        var priceCurr = [Double] (repeating: prices.last!, count: prices.count)

        for i in 0..<prices.count {
            let dataEntry = ChartDataEntry(x: Double(i), y: prices[i])
            dataEntries.append(dataEntry)
        }
        for i in 0..<priceCurr.count {
            let dataEntryCurr = ChartDataEntry(x: Double(i), y: priceCurr[i])
            dataEntriesCurr.append(dataEntryCurr)
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

        let lineChartDataSetCurr = LineChartDataSet(values: dataEntriesCurr, label: "EUR/USD Curr")
        lineChartDataSetCurr.mode = .cubicBezier
        lineChartDataSetCurr.drawCirclesEnabled = false         // без кругов
        lineChartDataSetCurr.colors = [NSUIColor.white]
        lineChartDataSetCurr.lineWidth = 1.0
        lineChartDataSetCurr.drawValuesEnabled = false

        let lineChartData = LineChartData(dataSets: [lineChartDataSet, lineChartDataSetCurr])
        eurUsdLineChartView.data = lineChartData
        eurUsdLineChartView.setScaleEnabled(false)
        eurUsdLineChartView.drawGridBackgroundEnabled = false
        eurUsdLineChartView.xAxis.drawAxisLineEnabled = true
        eurUsdLineChartView.xAxis.drawGridLinesEnabled = true
        eurUsdLineChartView.xAxis.enabled = true
        eurUsdLineChartView.xAxis.drawLabelsEnabled = false
        eurUsdLineChartView.leftAxis.drawAxisLineEnabled = false
        eurUsdLineChartView.leftAxis.drawGridLinesEnabled = false
        eurUsdLineChartView.leftAxis.enabled = false
        eurUsdLineChartView.rightAxis.drawAxisLineEnabled = true
        eurUsdLineChartView.rightAxis.drawGridLinesEnabled = true
        eurUsdLineChartView.legend.enabled = false

        if hasAnimate {
            eurUsdLineChartView.animate(xAxisDuration: 1.5)
        }
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
