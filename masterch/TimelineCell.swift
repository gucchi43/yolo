//
//  CustomTableViewCell.swift
//  masterch
//
//  Created by Fumiya Yamanaka on 2016/02/14.
//  Copyright © 2016年 Fumiya Yamanaka. All rights reserved.
//

import UIKit

class TimelineCell: UITableViewCell {
    
    @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet var userProfileImageView: UIImageView!
    @IBOutlet var userNameLabel: UILabel!
    
    @IBOutlet var postDateLabel: UILabel!
    @IBOutlet var postTextLabel: UILabel!
    @IBOutlet var postImageView: UIImageView!
    
    
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    
    
    @IBOutlet weak var likeNumberButton: UIButton!
    var likeCounts: Int?
    var isLikeToggle: Bool = false
    var likedUserIds = [String]()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
