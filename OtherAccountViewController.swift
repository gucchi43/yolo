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
    
    @IBOutlet weak var userFollowButton: UIButton!
    @IBOutlet weak var userFollowerButton: UIButton!
    
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
        relationshipQuery.getFirstObjectInBackgroundWithBlock { (object, error) -> Void in
            if let error = error{
                print(error.localizedDescription)
            }else {
                if object != nil {
                    print("フォローしてる")
                    self.followingRelationshipObject = object as NCMBObject
                    self.isFollowing = true
                    self.otherAccountFollowButton.setTitle("フォロー中", forState: UIControlState.Normal)
                }else{
                    print("フォローしてない")
                    self.isFollowing = false
                    self.otherAccountFollowButton.setTitle("フォロー", forState: UIControlState.Normal)
                }
            }
            
        }
        
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
        
        getFllowerNumbar()
        getFllowNumber()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getFllowNumber() {
        let myFllowQuery: NCMBQuery = NCMBQuery(className: "Relationship")
        myFllowQuery.whereKey("followed", equalTo: self.user)
        myFllowQuery.countObjectsInBackgroundWithBlock { (count , error) -> Void in
            if let error = error{
                print("error", error)
            }else {
                print(self.user,"の, フォロー数: ", count)
                self.userFollowButton.setTitle(String(count) + "フォロワー", forState: .Normal)

            }
        }
    }
    
    func getFllowerNumbar() {
        let myFllowerQuery: NCMBQuery = NCMBQuery(className: "Relationship")
        myFllowerQuery.whereKey("follower", equalTo: self.user)
        myFllowerQuery.countObjectsInBackgroundWithBlock { (count , error) -> Void in
            if let error = error{
                print("error", error)
            }else {
                print(self.user,"の, フォロワー数: ", count)
                self.userFollowerButton.setTitle(String(count) + "フォロワー", forState: .Normal)
            }
        }
    }
    

    @IBAction func selectOtherAccountFollowButton(sender: AnyObject) {
        print("followButton押した。")
        if isFollowing == false {
            print("フォローする")
            let relationObject = NCMBObject(className: "Relationship")
            relationObject.setObject(NCMBUser.currentUser(), forKey: "followed")
            relationObject.setObject(user, forKey: "follower")
            relationObject.saveInBackgroundWithBlock({ (error) -> Void in
                if let error = error{
                    print("error", error.localizedDescription)
                }else {
                    self.isFollowing = true
                    print("フォローした", NCMBUser.currentUser().userName, "→", self.user.userName)
                    self.otherAccountFollowButton.setTitle("フォロー中", forState: UIControlState.Normal)
                    self.followingRelationshipObject.objectId = relationObject.objectId
                    self.followingRelationshipObject = relationObject as NCMBObject

                }
            })
        } else {
            print("フォローをやめる")
            print("followingRelationshipObject", followingRelationshipObject)
            followingRelationshipObject.fetchInBackgroundWithBlock({ (error) -> Void in
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
