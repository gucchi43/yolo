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
    var userArray = [NCMBUser]()
    var userQuery = NCMBUser.query()
    var isFollowing: Bool = false
    var followingRelationshipObject = NCMBObject()

    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        checkFollowing()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func getFllowNumber() {
        let myFllowQuery: NCMBQuery = NCMBQuery(className: "Relationship")
        myFllowQuery.whereKey("followed", equalTo: self.user)
        myFllowQuery.countObjectsInBackgroundWithBlock { (count , error) -> Void in
            guard error == nil else { return }
            print(self.user,"の, フォロー数: ", count)
            self.userFollowButton.setTitle(String(count) + "フォロー", forState: .Normal)
            if count == 0 {
                self.userFollowButton.enabled = false
            } else {
                self.userFollowButton.enabled = true
            }
        }
    }
    
    func getFllowerNumbar() {
        let myFllowerQuery: NCMBQuery = NCMBQuery(className: "Relationship")
        myFllowerQuery.whereKey("follower", equalTo: self.user)
        myFllowerQuery.countObjectsInBackgroundWithBlock { (count , error) -> Void in
            guard error == nil else { return }
            print(self.user,"の, フォロワー数: ", count)
            self.userFollowerButton.setTitle(String(count) + "フォロワー", forState: .Normal)
            if count == 0 {
                self.userFollowerButton.enabled = false
            } else {
                self.userFollowerButton.enabled = true
            }
        }
    }

    func checkFollowing() {
        //        フォロー/フォロワーが合致してたらフォローしてるってことでRelationshipクラスのインスタンスを検索
        let relationshipQuery: NCMBQuery = NCMBQuery(className: "Relationship")
        relationshipQuery.whereKey("followed", equalTo: NCMBUser.currentUser())
        relationshipQuery.whereKey("follower", equalTo: user)
        relationshipQuery.getFirstObjectInBackgroundWithBlock { (object, error) -> Void in
            guard error == nil else { return }
            if object == nil {
                print("フォローしてない")
                self.isFollowing = false
                self.otherAccountFollowButton.setTitle("フォロー", forState: UIControlState.Normal)
            }else{
                print("フォローしてる")
                self.followingRelationshipObject = object as NCMBObject
                self.isFollowing = true
                self.otherAccountFollowButton.setTitle("フォロー中", forState: UIControlState.Normal)
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
                guard error == nil else { return }

                self.isFollowing = true
                print("フォローした", NCMBUser.currentUser().userName, "→", self.user.userName)
                self.otherAccountFollowButton.setTitle("フォロー中", forState: UIControlState.Normal)
                self.followingRelationshipObject.objectId = relationObject.objectId
                self.followingRelationshipObject = relationObject as NCMBObject
            })
        } else {
            print("フォローをやめる")
            print("followingRelationshipObject", followingRelationshipObject)
            followingRelationshipObject.fetchInBackgroundWithBlock({ (error) -> Void in
                guard error == nil else { return }

                self.followingRelationshipObject.deleteInBackgroundWithBlock({(error) in
                    guard error == nil else { return }

                    print("フォローをやめました")
                    self.otherAccountFollowButton.setTitle("フォロー", forState: UIControlState.Normal)
                    self.isFollowing = false
                    self.followingRelationshipObject.objectId = "dummy"
                })
            })
        }
        self.getFllowerNumbar()
    }
    
    @IBAction func pushUserFollowButton(sender: UIButton) {
        print("フォローボタンタップ")
        performSegueWithIdentifier("toUserList", sender: "follow")
    }
    
    @IBAction func pushUserFollowerButton(sender: UIButton) {
        print("フォロワ～ボタンタップ")
        performSegueWithIdentifier("toUserList", sender: "follower")
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toUserList" {
            
            let relationshipQuery = NCMBQuery(className: "Relationship")
            let userListVC = segue.destinationViewController as! UserListViewController
            
            guard let sender = sender as? String else { return }
            if sender == "follow" {
                relationshipQuery.whereKey("followed", equalTo: self.user)
                relationshipQuery.includeKey("follower")
                relationshipQuery.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
                    if error == nil {
                        guard let relationships = objects as? [NCMBObject] else { return }
                        for relationship in relationships {
                            userListVC.userArray.append(relationship.objectForKey("follower") as! NCMBUser)
                        }
                        userListVC.userListTableView.reloadData()
                    }
                }
            } else if sender == "follower" {
                relationshipQuery.whereKey("follower", equalTo: self.user)
                relationshipQuery.includeKey("followed")
                relationshipQuery.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
                    if error == nil {
                        guard let relationships = objects as? [NCMBObject] else { return }
                        for relationship in relationships {
                            userListVC.userArray.append(relationship.objectForKey("followed") as! NCMBUser)
                        }
                        userListVC.userListTableView.reloadData()
                    }
                }
            }
        }
    }

}
