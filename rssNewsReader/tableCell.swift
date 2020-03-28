//
//  tableCell.swift
//  rssNewsReader
//
//  Created by nuri Lee on 27/03/2020.
//  Copyright © 2020 nuri Lee. All rights reserved.
//

import UIKit



class tableCell : UITableViewCell{

    @IBOutlet weak var thumbnail: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var bodyLabel: UILabel!
    
    @IBOutlet var keyWordLabelList: [DesignableLabel]!
    
}
