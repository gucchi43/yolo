//
//  CustomTableViewCell.swift
//  masterch
//
//  Created by Fumiya Yamanaka on 2016/02/14.
//  Copyright © 2016年 Fumiya Yamanaka. All rights reserved.
//

import UIKit

class CustomTableViewCell: UITableViewCell {
    
    @IBOutlet var postTextLabel: UILabel!
    @IBOutlet var postImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
