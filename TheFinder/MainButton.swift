//
//  MainButton.swift
//  TheFinder
//
//  Created by roberto on 10/5/16.
//  Copyright © 2016 TheFinder. All rights reserved.
//

import UIKit

class MainButton: UIButton {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        layer.borderWidth = 1.0
        layer.borderColor = UIColor(red: 58/255, green: 168/255, blue:193/255, alpha: 1.0 ).cgColor   //CGColor;
        layer.cornerRadius = 10.0
        clipsToBounds = true
        contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    }

}
