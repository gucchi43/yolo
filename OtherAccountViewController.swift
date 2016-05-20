//
//  OtherAccountViewController.swift
//  masterch
//
//  Created by HIroki Taniguti on 2016/05/16.
//  Copyright © 2016年 Fumiya Yamanaka. All rights reserved.
//

import UIKit

class OtherAccountViewController: UIViewController {
    
    
    @IBOutlet weak var userProfileImageView: UIImageView!
    @IBOutlet weak var userProfileNameLabel: UILabel!
    @IBOutlet weak var userIdLabel: UILabel!
    @IBOutlet weak var userHomeImageView: UIImageView!
    @IBOutlet weak var userSelfIntroductionLabel: UILabel!
    
    @IBOutlet var otherAccountFollowButton: UIButton!
    
    var user: NCMBUser!
    var isFollowing: Bool = false
    var followingRelationshipObject: NCMBObject = NCMBObject()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //        フォロー/フォロワーが合致してたらフォローしてるってことでRelationshipクラスのインスタンスを検索
        let relationshipQuery: NCMBQuery = NCMBQuery(className: "Relationship")
        relationshipQuery.whereKey("followed", equalTo: NCMBUser.currentUser())
        relationshipQuery.whereKey("follower", equalTo: user)
        relationshipQuery.findObjectsInBackgroundWithBlock({(NSArray objects, NSError error) in
            if (error != nil) {
                print(error.localizedDescription)
            } else {
                if objects != nil {
                    if objects as NSObject != [] {
                        //                        フォロー/フォロワー関係の時
                        print("フォローしてる")
                        self.followingRelationshipObject = objects[0] as! NCMBObject
                        self.isFollowing = true
                        self.otherAccountFollowButton.setTitle("フォロー中", forState: UIControlState.Normal)
                    } else {
                        print("フォローしてない")
                        self.isFollowing = false
                        self.otherAccountFollowButton.setTitle("フォロー", forState: UIControlState.Normal)
                    }
                } else {
                    print("フォローしてない")
                    self.isFollowing = false
                    self.otherAccountFollowButton.setTitle("フォロー", forState: UIControlState.Normal)
                }
            }
        })
        
        print(user)
        userIdLabel.text = "@" + user.userName
        userProfileNameLabel.text = user.objectForKey("userFaceName") as? String
        
        userProfileImageView.layer.cornerRadius = userProfileImageView.frame.width/2
        let userProfileImageName = (user.objectForKey("userProfileImage") as? String)!
        let userProfileImageData = NCMBFile.fileWithName(userProfileImageName, data: nil) as! NCMBFile
        userProfileImageData.getDataInBackgroundWithBlock { (imageData: NSData?, error: NSError!) -> Void in
            if error != nil{
                print("写真の取得失敗: \(error)")
            } else {
                self.userProfileImageView.image = UIImage(data: imageData!)
            }
        }
        
        let userHomeImageName = (user.objectForKey("userHomeImage") as? String)!
        let userHomeImageData = NCMBFile.fileWithName(userHomeImageName, data: nil) as! NCMBFile
        userHomeImageData.getDataInBackgroundWithBlock { (imageData: NSData?, error: NSError!) -> Void in
            if error != nil{
                print("写真の取得失敗: \(error)")
            } else {
                self.userHomeImageView.image = UIImage(data: imageData!)
            }
        }
        
        userSelfIntroductionLabel.text = user.objectForKey("userSelfIntroduction") as? String
        userSelfIntroductionLabel.sizeToFit()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func selectOtherAccountFollowButton(sender: AnyObject) {
        print("followButton押した。")
        
        
        if isFollowing == false {
            print("フォローする")
            let relationObject = NCMBObject(className: "Relationship")
            relationObject.setObject(NCMBUser.currentUser(), forKey: "followed")
            relationObject.setObject(user, forKey: "follower")
            followingRelationshipObject.objectId = relationObject.objectId
            relationObject.save(nil)
            self.isFollowing = true
            print("フォローした")
            otherAccountFollowButton.setTitle("フォロー中", forState: UIControlState.Normal)
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
                            self.otherAccountFollowButton.setTitle("フォロー", forState: UIControlState.Normal)
                            self.isFollowing = false
                            self.followingRelationshipObject.objectId = "dummy"
                        }
                    })
                }
            })
        }
        
        
    }

}
