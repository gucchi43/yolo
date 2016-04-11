//
//  AccountViewController.swift
//  masterch
//
//  Created by Fumiya Yamanaka on 2016/02/09.
//  Copyright © 2016年 Fumiya Yamanaka. All rights reserved.
//

import UIKit

class AccountViewController: UIViewController {
    
    @IBOutlet weak var userProfileImage: UIImageView!
    @IBOutlet weak var userProfileName: UILabel!

    @IBOutlet weak var segmentedController: UISegmentedControl!
    @IBOutlet weak var containerSnsView: UIView!
    @IBOutlet weak var containerProfileView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        print("AccountViewController")
        
////        userProfileImageの形を整える
//        self.userProfileImage.layer.cornerRadius = 30
//        self.userProfileImage.layer.masksToBounds = true
    }
    
    override func viewWillAppear(animated: Bool) {
        
        //ユーザーネームを表示
        self.userProfileName.text = NCMBUser.currentUser().userName
        
        //プロフィール写真の形を整える
        let userImageView = self.userProfileImage
        userImageView.layer.cornerRadius = userImageView.frame.width/2
        userImageView.layer.masksToBounds = true
        
        //プロフィール写真を表示
        let userImageName = (NCMBUser.currentUser().objectForKey("userProfileImage") as? String)!
        let userImageData = NCMBFile.fileWithName(userImageName, data: nil) as! NCMBFile
        
        userImageData.getDataInBackgroundWithBlock { (imageData: NSData?, error: NSError!) -> Void in
            if error != nil{
                print("写真の取得失敗: \(error)")
            } else {
                userImageView.image = UIImage(data: imageData!)
            }
        }
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    @IBAction func logautBtn(sender: AnyObject) {
//        print("ログイン前ユーザー情報:\(NCMBUser.currentUser())")
//        NCMBUser.logOut()
//        print("ログアウト後ユーザー情報:\(NCMBUser.currentUser())")
//    }
    
    
    
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
        print("ユーザー情報: \(NCMBUser.currentUser())")
    }
    
    @IBAction func unwindToTop(segue: UIStoryboardSegue) {
        print("back to AccountView")
    }
    
}