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
    @IBOutlet weak var dealParamLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var winLossProgressView: UIProgressView!
    @IBOutlet weak var winLossProcLabel: UILabel!

    @IBAction func buyButton(_ sender: UIButton) {
        buySellStackView.isHidden = true
        closeStackView.isHidden = false
        let priceCurrent = coreDataService.lastPrice()
        deals.openDeals(currencyPair: "EurUsd", type: "Buy", timeOpen: NSDate(), priceOpen: priceCurrent)
//        dealParamLabel.text = deals.typeOpenDeal()+" at "+String(deals.priceOpenDeal())
        ratesService.savePointFromAPI()
    }

    @IBAction func sellButton(_ sender: UIButton) {
        buySellStackView.isHidden = true
        closeStackView.isHidden = false
        let priceCurrent = coreDataService.lastPrice()
        deals.openDeals(currencyPair: "EurUsd", type: "Sell", timeOpen: NSDate(), priceOpen: priceCurrent)
//        dealParamLabel.text = deals.typeOpenDeal()+" at "+String(deals.priceOpenDeal())
        ratesService.savePointFromAPI()
    }

    @IBAction func closeButton(_ sender: UIButton) {
        closeStackView.isHidden = true
        buySellStackView.isHidden = false
        let priceCurrent = coreDataService.lastPrice()
        deals.closeDeals(timeClose: NSDate(), priceClose: priceCurrent)
        updateBalance()
        ratesService.savePointFromAPI()
    }

    @IBAction func historyButton(_ sender: UIButton) {

    }

    override func viewDidLoad() {
        super.viewDidLoad()
//        deals.clearAllDeals()
        updateEurUsd()
        ratesService.savePointFromAPI()
        updateBalance()
        ratesService.downloadPointsToCoreData()
        prices = coreDataService.createArrayPointsEurusd()
        setChart(prices: prices, hasAnimate: true)

        if deals.isOpenDeal() {
            buySellStackView.isHidden = true
            closeStackView.isHidden = false
            setChartWithDeal(prices: prices, priceDeal: deals.priceOpenDeal(),
                             typeDeal: deals.typeOpenDeal(), hasAnimate: false)
        } else {
            buySellStackView.isHidden = false
            closeStackView.isHidden = true
        }
    }

    func updateBalance() {
        if deals.getBalance() > 0 {
            balanceLabel.text = String(deals.getBalance())
        } else {
            balanceLabel.text = "10000"
            //deal.balanceFix = 10000
        }
        balanceLabel.text = String(deals.getBalance())
        let dealsAllClose: [Deal] = deals.getAllCloseDeals()
        guard dealsAllClose != [] else { return }
        var winValue: Float = 0
        var lossValue: Float = 0
        var allDealsCount: Float = 0
        for deal in dealsAllClose {
            if deal.profit > 0 {
                winValue += 1
                allDealsCount += 1
            }
            if deal.profit < 0 {
                lossValue += 1
                allDealsCount += 1
            }
        }
        winLossProgressView.progress = winValue / allDealsCount
        winLossProcLabel.text = String(Int((winValue / allDealsCount)*100))+"%"
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

    func setChartWithDeal(prices: [Double], priceDeal: Double, typeDeal: String, hasAnimate: Bool) {
        guard !prices.isEmpty else { return }
        var dataEntries: [ChartDataEntry] = []
        var dataEntriesCurr: [ChartDataEntry] = []
        var dataEntriesDeal: [ChartDataEntry] = []
        var priceCurr = [Double] (repeating: prices.last!, count: prices.count)
        var priceDeal = [Double] (repeating: priceDeal, count: prices.count)

        for i in 0..<prices.count {
            let dataEntry = ChartDataEntry(x: Double(i), y: prices[i])
            dataEntries.append(dataEntry)
        }
        for i in 0..<priceCurr.count {
            let dataEntryCurr = ChartDataEntry(x: Double(i), y: priceCurr[i])
            dataEntriesCurr.append(dataEntryCurr)
        }
        for i in 0..<priceDeal.count {
            let dataEntryDeal = ChartDataEntry(x: Double(i), y: priceDeal[i])
            dataEntriesDeal.append(dataEntryDeal)
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

        let lineChartDataSetDeal = LineChartDataSet(values: dataEntriesDeal, label: "Price Deal")
        lineChartDataSetDeal.mode = .cubicBezier
        lineChartDataSetDeal.drawCirclesEnabled = false         // без кругов
        if typeDeal == "Buy" {
            lineChartDataSetDeal.colors = [NSUIColor.init(named: "1ColorGreen")] as! [NSUIColor]
        } else {
            lineChartDataSetDeal.colors = [NSUIColor.init(named: "AdditionalColor")] as! [NSUIColor]
        }

        lineChartDataSetDeal.lineWidth = 2.0
        lineChartDataSetDeal.drawValuesEnabled = false

        let lineChartData = LineChartData(dataSets: [lineChartDataSet, lineChartDataSetCurr, lineChartDataSetDeal])
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

    func updateEurUsd() {
        ratesService.onPricesUpdated = { [weak self] in
            guard let self = self else { return }
            self.prices = self.coreDataService.createArrayPointsEurusd()
            self.updateBalance()
            if self.deals.isOpenDeal() {
                self.setChartWithDeal(prices: self.prices, priceDeal: self.deals.priceOpenDeal(),
                                      typeDeal: self.deals.typeOpenDeal(), hasAnimate: false)
            } else {
                self.setChart(prices: self.prices, hasAnimate: false)
            }

            if self.closeStackView.isHidden {
                self.currentPriceLabel.text = String(self.coreDataService.lastPrice())
            }
            if self.buySellStackView.isHidden {
                let currProfit = self.deals.currProfit()
                self.dealParamLabel.text = self.deals.typeOpenDeal()+" at "+String(self.deals.priceOpenDeal())
                if currProfit > 0 {
                    self.currentProfitLabel.text = "+"+String(currProfit)+"$"
                } else {
                    self.currentProfitLabel.text = String(currProfit)+"$"
                }
            }
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
