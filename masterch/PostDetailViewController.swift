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
    var isFollowing: Bool = false
    var isLikeed: Bool = false
    var likeCount: Int?
    var followingRelationshipObject: NCMBObject = NCMBObject()
    
    override func viewDidLoad(){
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        // Do any additional setup after loading the view, typically from a nib.
        
        if let author = postObject.objectForKey("user") as? NCMBUser {
            
            userProfileNameLabel.text = author.objectForKey("userFaceName") as? String
            userNameLabel.text = author.userName
            
            //プロフィール写真の形を円形にする
            userProfileImageView.layer.cornerRadius = userProfileImageView.frame.width/2
            
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
        
        // postDateLabelには(key: "postDate")の値を、NSDateからstringに変換して入れる
        let date = postObject.objectForKey("postDate") as? NSDate
        let postDateFormatter: NSDateFormatter = NSDateFormatter()
        postDateFormatter.dateFormat = "yyyy MM/dd HH:mm"
        postDateLabel.text = postDateFormatter.stringFromDate(date!)
        
        // 画像データの取得
        if let postImageName = postObject.objectForKey("image1") as? String {
            self.postImageViewHeightConstraint.constant = 300
            
            let postImageData = NCMBFile.fileWithName(postImageName, data: nil) as! NCMBFile
            postImageData.getDataInBackgroundWithBlock({ (imageData: NSData?, error: NSError!) -> Void in
                if let error = error {
                    print("写真の取得失敗： ", error)
                    self.postImageView.image = nil
                    self.postImageViewHeightConstraint.constant = 0.0
                } else {
                    print(UIImage(data: imageData!))
                    let imageHeight = UIImage(data: imageData!)!.size.height
                    self.postImageViewHeightConstraint.constant = 300
                    self.postImageView.image = UIImage(data: imageData!)
                }
            })
        } else {
            self.postImageView.image = nil
            self.postImageViewHeightConstraint.constant = 0.0
            print(self.postImageViewHeightConstraint.constant)
        }
    }
}


//  拡張: Commentボタン用
extension PostDetailViewController {
    
    
    
}

//  拡張: Likeボタン用
extension PostDetailViewController {
    
    @IBAction func pushLikeButton(sender: AnyObject) {
        print("Likeボタン押してやったぜ")
    }
    
}

//  拡張: フォローボタン用
extension PostDetailViewController {
    @IBAction func selectFollow(sender: UIButton) {
        print("フォローボタン押した")
        
        self.checkFollowing()
        if isFollowing == false {
            print("フォローする")
            let relationObject = NCMBObject(className: "Relationship")
            relationObject.setObject(NCMBUser.currentUser(), forKey: "followed")
            relationObject.setObject(postObject.objectForKey("user"), forKey: "follower")
            followingRelationshipObject.objectId = relationObject.objectId
            relationObject.save(nil)
            self.isFollowing = true
            print("フォローした")
            followButton.setTitle("フォロー中", forState: UIControlState.Normal)
            followButton.titleLabel?.font = UIFont.systemFontOfSize(12)
        } else {
            print("フォローをやめる")
            followingRelationshipObject.fetchInBackgroundWithBlock({(NSError error) in
                if (error != nil) {
                    print(error)
                } else {
                    self.followingRelationshipObject.deleteInBackgroundWithBlock({(NSError error) in
                        if (error != nil) {
                            print(error)
                        } else {
                            print("フォローをやめました")
                            self.followButton.setTitle("フォロー", forState: UIControlState.Normal)
                            self.followButton.titleLabel?.font = UIFont.systemFontOfSize(14)
                            self.isFollowing = false
                            self.followingRelationshipObject.objectId = "dummy"
                        }
                    })
                }
            })
        }
    }
    
    //    フォローしてるかどうかの判定メソッド
    func checkFollowing() {
        //        フォロー/フォロワーが合致してたらフォローしてるってことでRelationshipクラスのインスタンスを検索
        let relationshipQuery: NCMBQuery = NCMBQuery(className: "Relationship")
        relationshipQuery.whereKey("followed", equalTo: NCMBUser.currentUser())
        relationshipQuery.whereKey("follower", equalTo: postObject.objectForKey("user"))
        
        relationshipQuery.findObjectsInBackgroundWithBlock({(NSArray objects, NSError error) in
            if (error != nil) {
                print(error.localizedDescription)
            } else {
                if objects != nil {
                    if objects as NSObject != [] {
                        //                        フォロー/フォロワー関係の時
                        self.followingRelationshipObject = objects[0] as! NCMBObject
                        print("フォローしてる")
                        self.isFollowing = true
                        self.followButton.setTitle("フォロー中", forState: UIControlState.Normal)
                        self.followButton.titleLabel?.font = UIFont.systemFontOfSize(12)
                    } else {
                        print("フォローしてない")
                        self.isFollowing = false
                        self.followButton.setTitle("フォロー", forState: UIControlState.Normal)
                        self.followButton.titleLabel?.font = UIFont.systemFontOfSize(14)
                    }
                } else {
                    print("フォローしてない")
                    self.isFollowing = false
                    self.followButton.setTitle("フォロー", forState: UIControlState.Normal)
                    self.followButton.titleLabel?.font = UIFont.systemFontOfSize(14)
                }
            }
        })
    }
}


//  拡張: その他ボタン用
extension PostDetailViewController {
    
}





