//
//  NotificationCommentTableViewCell.swift
//  masterch
//
//  Created by HIroki Taniguti on 2016/06/14.
//  Copyright © 2016年 Fumiya Yamanaka. All rights reserved.
//

import UIKit

class NotificationCommentTableViewCell: UITableViewCell {
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userButton: UIButton!
    @IBOutlet weak var agoTimeLabel: UILabel!
    @IBOutlet weak var commentMessageLabel: UILabel!
    @IBOutlet weak var postLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
