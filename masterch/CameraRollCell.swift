//
//  CameraRollCell.swift
//  masterch
//
//  Created by HIroki Taniguti on 2016/10/28.
//  Copyright © 2016年 Fumiya Yamanaka. All rights reserved.
//

import UIKit

class CameraRollCell: UITableViewCell {


    @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var userProfileImageView: UIImageView!
    @IBOutlet weak var cameraRollLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var postDateLabel: UILabel!
    @IBOutlet weak var cameraRollCount: UILabel!
    
    @IBOutlet weak var camaraRollImageView: UIImageView!
    @IBOutlet weak var shareButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
