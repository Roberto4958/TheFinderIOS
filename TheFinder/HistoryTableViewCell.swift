//
//  HistoryTableViewCell.swift
//  TheFinder
//
//  Created by roberto on 1/18/17.
//  Copyright © 2017 TheFinder. All rights reserved.
//

import UIKit

class HistoryTableViewCell: UITableViewCell {
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var loadBar: UIActivityIndicatorView!
    
    var location: Location?{
        didSet{
            update()
        }
    }
    
    func update(){
        label.text! = location!.place!
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
