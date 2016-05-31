//
//  CommentTableViewCell.swift
//  masterch
//
//  Created by Fumiya Yamanaka on 2016/05/29.
//  Copyright © 2016年 Fumiya Yamanaka. All rights reserved.
//

import UIKit

class CommentTableViewCell: UITableViewCell {

    @IBOutlet weak var userProfileImageView: UIImageView!
    @IBOutlet weak var userProfileNameLabel: UILabel!
    @IBOutlet weak var commentDateLabel: UILabel!
    @IBOutlet weak var commentTextLabel: UILabel!
    
    let commentObject: NCMBObject? = nil

    override func layoutSubviews() {
        super.layoutSubviews()
        userProfileImageView.layer.cornerRadius = userProfileImageView.layer.bounds.width/2
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

        print("commentTableView")
    }
    
    func setCommentCell() {
        
        userProfileImageView.image = UIImage(named: "noprofile")
        userProfileNameLabel.text = "ユーザネーム"
        commentDateLabel.text = "2016年 6月10日 12:00"
        commentTextLabel.text = "こめんとおおおおおおおお"
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
