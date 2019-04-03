//
//  HistoryTableViewCell.swift
//  ForexGame
//
//  Created by Alla on 3/31/19.
//  Copyright © 2019 AndreiSavchenko. All rights reserved.
//

import UIKit

class HistoryTableViewCell: UITableViewCell {

    static let reuseIdentifier: String = "HistoryCell"

    @IBOutlet weak var cellRoundedView: RoundedView!
    @IBOutlet weak var profitLabel: UILabel!
    @IBOutlet weak var currencyPairLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        cellRoundedView.border(width: 1)
    }

}
