//
//  RoundedView.swift
//  ForexGame
//
//  Created by Alla on 2/21/19.
//  Copyright © 2019 AndreiSavchenko. All rights reserved.
//

import UIKit

class RoundedView: UIView {

    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 10.0
    }

    func border(width: CGFloat) {
        layer.borderWidth = width
        layer.borderColor = UIColor.white.cgColor
    }

}
