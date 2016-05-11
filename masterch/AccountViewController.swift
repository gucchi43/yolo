//
//  AccountViewController.swift
//  masterch
//
//  Created by Fumiya Yamanaka on 2016/02/09.
//  Copyright © 2016年 Fumiya Yamanaka. All rights reserved.
//

import UIKit

class AccountViewController: UIViewController {
    
    @IBOutlet weak var userProfileImageView: UIImageView!
    @IBOutlet weak var userProfileNameLabel: UILabel!
    @IBOutlet weak var userIdLabel: UILabel!
    @IBOutlet weak var userHomeImageView: UIImageView!
    
    //フォロー数、フォロワー数
    @IBOutlet weak var followNumberButton: UIButton!
    @IBOutlet weak var followerNumberButton: UIButton!
    
    @IBOutlet weak var segmentedController: UISegmentedControl!
    @IBOutlet weak var containerSnsView: UIView!
    @IBOutlet weak var containerProfileView: UIView!
    
    
    var currentUser: NCMBUser!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        print("AccountViewController")

    }
    
    override func viewWillAppear(animated: Bool) {
        
        currentUser = NCMBUser.currentUser()
        
        
        //ユーザーネームを表示
        self.userProfileNameLabel.text = (currentUser.objectForKey("userFaceName") as? String)!
        self.userIdLabel.text = "@" + currentUser.userName
        
        //プロフィール写真の形を円形にする
        userProfileImageView.layer.cornerRadius = userProfileImageView.frame.width/2
        
        //プロフィール写真を表示
        let userProfileImageName = (currentUser.objectForKey("userProfileImage") as? String)!
        let userProfileImageData = NCMBFile.fileWithName(userProfileImageName, data: nil) as! NCMBFile
        
        userProfileImageData.getDataInBackgroundWithBlock { (imageData: NSData?, error: NSError!) -> Void in
            if error != nil{
                print("写真の取得失敗: \(error)")
            } else {
                self.userProfileImageView.image = UIImage(data: imageData!)
            }
        }
        
        //ホーム写真を表示
        let userHomeImageName = (currentUser.objectForKey("userHomeImage") as? String)!
        let userHomeImageData = NCMBFile.fileWithName(userHomeImageName, data: nil) as! NCMBFile
        
        userHomeImageData.getDataInBackgroundWithBlock { (imageData: NSData?, error: NSError!) -> Void in
            if error != nil{
                print("写真の取得失敗: \(error)")
            } else {
                self.userHomeImageView.image = UIImage(data: imageData!)
            }
        }
        
    }
    
    @IBAction func selectEditProfileButton(sender: AnyObject) {
        performSegueWithIdentifier("toEditProfile", sender: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var destination = segue.destinationViewController as UIViewController
        if let naviC = destination as? UINavigationController {
            destination = naviC.visibleViewController!
        } // storyboard上でnavigaitonControllerを使ってる時の変数の渡し方
        if let editProfileVC = destination as? EditProfileTableViewController {
            if segue.identifier == "toEditProfile" {
                editProfileVC.userProfileName = userProfileNameLabel.text
                editProfileVC.userSelfIntroduction = NCMBUser.currentUser().objectForKey("userSelfIntroduction") as! String
                editProfileVC.profileImage = userProfileImageView.image
                editProfileVC.homeImage = userHomeImageView.image
            }
        }
        
    
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func didValueChanged(sender: AnyObject) {
        
        switch sender.selectedSegmentIndex{
        case 0:
            //valueChanged: 0の時の実装（containerProfileView表示）
            print("case = 0(プロフィール)")
            UIView.animateWithDuration(0.1, animations: {
                self.containerSnsView.alpha = 0
                self.containerProfileView.alpha = 1
            })
        case 1:
            //valueChanged: 1の時の実装（containerSnsView表示）
            print("case = 1(連携SNS)")
            UIView.animateWithDuration(0.1, animations: {
                self.containerSnsView.alpha = 1
                self.containerProfileView.alpha = 0
            })
        default:
            print("segmentedControllerd: 原因不明のエラー")
        }
    }
    
    @IBAction func logOutBtn(sender: AnyObject) {
        print("ログイン画面に戻る")
        print("ログアウト前: \(NCMBUser.currentUser())")
        NCMBUser.logOut()
        print("ログアウト後: \(NCMBUser.currentUser())")
    }
    
    @IBAction func userInfoBtn(sender: AnyObject) {
        print("ユーザー情報: \(currentUser)")
    }
    
}



