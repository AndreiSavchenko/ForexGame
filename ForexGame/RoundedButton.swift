//
//  RoundedButton.swift
//  ForexGame
//
//  Created by Alla on 2/21/19.
//  Copyright © 2019 AndreiSavchenko. All rights reserved.
//

import UIKit

class RoundedButton: UIButton {

    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 5.0
    }

}
