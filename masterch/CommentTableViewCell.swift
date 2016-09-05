//
//  CommentTableViewCell.swift
//  masterch
//
//  Created by Fumiya Yamanaka on 2016/05/29.
//  Copyright © 2016年 Fumiya Yamanaka. All rights reserved.
//

import UIKit
import NCMB

protocol CommentTableViewCellDelegate {
    func didSelectCommentProfileImageView(commentObject: NCMBObject!)
}

class CommentTableViewCell: UITableViewCell {

    @IBOutlet weak var userProfileImageView: UIImageView!
    @IBOutlet weak var userProfileNameLabel: UILabel!
    @IBOutlet weak var commentDateLabel: UILabel!
    @IBOutlet weak var commentTextLabel: UILabel!
    
    var commentObject: NCMBObject!
    
    var delegate: CommentTableViewCellDelegate!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        userProfileImageView.layer.cornerRadius = userProfileImageView.layer.bounds.width/2
        let gesture = UITapGestureRecognizer(target: self, action: #selector(CommentTableViewCell.tapImageView(_:)))
        userProfileImageView.addGestureRecognizer(gesture)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

        print("commentTableView")
    }
    
    func setCommentCell() {
        commentTextLabel.text = commentObject.objectForKey("text") as? String
        
        let date = commentObject.createDate
        let commentDateFormatter: NSDateFormatter = NSDateFormatter()
        commentDateFormatter.dateFormat = "yyyy MM/dd HH:mm"
        commentDateLabel.text = commentDateFormatter.stringFromDate(date)
        
        let author = commentObject.objectForKey("user") as? NCMBUser
        if let author = author {
            userProfileNameLabel.text = author.objectForKey("userFaceName") as? String
            
            let profileImageData = NCMBFile.fileWithName(author.objectForKey("userProfileImage") as? String, data: nil) as! NCMBFile
            profileImageData.getDataInBackgroundWithBlock({ (imageData: NSData?, error: NSError!) -> Void in
                if let error = error {
                    print("プロフィール画像の取得失敗： ", error)
                    self.userProfileImageView.image = UIImage(named: "noprofile")
                } else {
                    self.userProfileImageView.image = UIImage(data: imageData!)
                    
                }
            })
        } else {
            userProfileNameLabel.text = "username"
            userProfileImageView.image = UIImage(named: "noprofile")
        }
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

//ユーザーの写真を押して遷移
extension CommentTableViewCell {
    func tapImageView (recoginizer: UITapGestureRecognizer){
        print("写真押された")
        print("これはどうなななんあんんんんんんんｎ",commentObject)
        delegate.didSelectCommentProfileImageView(commentObject)
    }
}
