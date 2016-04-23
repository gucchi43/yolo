//
//  PostDetail.swift
//  masterch
//
//  Created by Fumiya Yamanaka on 2016/02/19.
//  Copyright © 2016年 Fumiya Yamanaka. All rights reserved.
//

import UIKit

class PostDetailViewController: UIViewController {
    
    @IBOutlet var userProfileNameLabel: UILabel!
    @IBOutlet var userNameLabel: UILabel!
    @IBOutlet var userProfileImageView: UIImageView!
    @IBOutlet var postDateLabel: UILabel!
    @IBOutlet var postTextLabel: UILabel!
    @IBOutlet var postImageView: UIImageView!
    @IBOutlet var postImageViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var followButton: UIButton!
    
    var postObject: NCMBObject!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let author = postObject.objectForKey("user") as? NCMBUser
        if let author = author {
            userProfileNameLabel.text = author.objectForKey("userFaceName") as? String
            userNameLabel.text = author.userName
            let userImageData = NCMBFile.fileWithName(author.objectForKey("userProfileImage") as? String, data: nil) as! NCMBFile
            userImageData.getDataInBackgroundWithBlock({ (imageData: NSData?, error: NSError!) -> Void in
                if let error = error {
                    print("プロフィール画像の取得失敗： ", error)
                    self.userProfileImageView.image = UIImage(named: "noprofile")
                } else {
                    self.userProfileImageView.image = UIImage(data: imageData!)
                }
            })
        } else {
            userNameLabel.text = "username"
            userProfileImageView.image = UIImage(named: "noprofile")
        }
        
        postTextLabel.text = postObject.objectForKey("text") as? String
        postDateLabel.text = postObject.objectForKey("postDate") as? String
        
        // 画像データの取得
        if let postImageName = postObject.objectForKey("image1") as? String {
            let postImageData = NCMBFile.fileWithName(postImageName, data: nil) as! NCMBFile
            postImageData.getDataInBackgroundWithBlock({ (imageData: NSData?, error: NSError!) -> Void in
                if let error = error {
                    print("写真の取得失敗： ", error)
                    self.postImageView.image = nil
                } else {
                    self.postImageView.image = UIImage(data: imageData!)
                }
            })
        } else {
            self.postImageView.image = nil
        }
        
        // 画像の有無で場合分け
        if (postImageView.image == nil) {
            postImageViewHeightConstraint.constant = 0.0
        } else {
            postImageViewHeightConstraint.constant = 400
        }
    }
    
    @IBAction func selectFollow(sender: UIButton) {
        print("フォローボタン押した")
        
        let relationObject = NCMBObject(className: "Relationship")
        relationObject.setObject(NCMBUser.currentUser(), forKey: "followed")
        relationObject.setObject(postObject.objectForKey("user"), forKey: "follower")
        relationObject.save(nil)
        
        followButton.setTitle("フォローした", forState: UIControlState.Normal)
        followButton.titleLabel?.font = UIFont.systemFontOfSize(10)
    
    }
    
}
