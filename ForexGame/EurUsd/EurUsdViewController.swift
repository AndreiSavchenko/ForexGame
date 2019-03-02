//
//  EurUsdViewController.swift
//  ForexGame
//
//  Created by Alla on 3/3/19.
//  Copyright © 2019 AndreiSavchenko. All rights reserved.
//

import UIKit
import Charts

class EurUsdViewController: UIViewController {

    @IBOutlet weak var eurUsdLineChartView: LineChartView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setChartValues()

    }

    func setChartValues(_ count: Int = 20) {
        let values = (0..<count).map { (i) -> ChartDataEntry in
            let val = Double(arc4random_uniform(UInt32(count))+3)
            return ChartDataEntry(x: Double(i), y: val)
        }
        let set = LineChartDataSet(values: values, label: "Set")
        let data = LineChartData(dataSet: set)

        self.eurUsdLineChartView.data = data
    }

}
