//
//  UserListTableViewCell.swift
//  masterch
//
//  Created by Fumiya Yamanaka on 2016/06/07.
//  Copyright © 2016年 Fumiya Yamanaka. All rights reserved.
//

import UIKit

class UserListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userFaceNameLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        userImageView.layer.cornerRadius = userImageView.frame.width/2

    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
