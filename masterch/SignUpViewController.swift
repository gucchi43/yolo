//
//  SignUpViewController.swift
//  masterch
//
//  Created by HIroki Taniguti on 2016/03/08.
//  Copyright © 2016年 Fumiya Yamanaka. All rights reserved.
//

import UIKit
import TwitterKit

class SignUpViewController: UIViewController {
    
    @IBAction func fbSignUpBtn(sender: AnyObject) {
        print("facebookボタン押した")
        NCMBFacebookUtils.logInWithReadPermission(["wakannai"], block: { (user: NCMBUser!, error: NSError!) -> Void in
            if error == nil {
                print("会員登録後の処理")
                let acl = NCMBACL(user: NCMBUser.currentUser())
                user.ACL = acl
                user.saveInBackgroundWithBlock({ (error: NSError!) -> Void in
                    if error == nil {
                        print("ACLの保存成功")
                    }else {
                        print("ACL設定の保存失敗: \(error)")
                    }
                    print("Facebook会員登録成功")
                    self.performSegueWithIdentifier("signUpedSegue", sender: self)
                })
            }else {
                if error.code == NCMBErrorFacebookLoginCancelled {
                    print("Facebookのログインをキャンセルしました \(error)")
                } else {
                    print("キャンセル以外のエラー: \(error)")
                }
            }
        })
    }
    
//     NCMBFacebookUtils.logInWithReadPermission(["email"]) {(user, error) -> Void in
//            if (error != nil){
//                if (error.code == NCMBErrorFacebookLoginCancelled){
//                    // Facebookのログインがキャンセルされた場合
//                }else{
//                    // その他のエラーが発生した場合
//                    print("FBエラー")
//                }
//            }else{
//                // 会員登録後の処理
//                print("FBサクセス")
//                self.performSegueWithIdentifier("signUpedSegue", sender: self)
//            }
//        }
    
    
    @IBAction func twSignUpBtn(sender: AnyObject) {
        print("Twitterログインボタン押した")
        NCMBTwitterUtils.logInWithBlock { (user: NCMBUser!, error: NSError!) -> Void in
            if let user = user {
                
                //初めてのログインかの分岐
                if user.createDate == user.updateDate{
                    //初めてのユーザー（Twitterでユーザー登録）
                    print("初めてユーザー")
                    //ユーザー名を設定
                    let name = NCMBTwitterUtils.twitter().screenName
                    print("name: \(name)")
                    user.userName = name
                    
                    // ACLを本人のみに設定
                    let acl = NCMBACL(user: NCMBUser.currentUser())
                    user.ACL = acl
                    
                    //プロフィール写真を設定
                    //ひとまずnoprofile.pngを設定
                    //!!! SNSのプロフィール写真を設定したい, 谷口
                    let userImage = UIImage(named: "noprofile.png")
                    let userimageData = UIImagePNGRepresentation(userImage!)! as NSData
                    let userimageFile: NCMBFile = NCMBFile.fileWithData(userimageData) as! NCMBFile
                    user.setObject(userimageFile.name, forKey: "userProfileImage")
                    
                    //バックグラウンドで保存処理
                    user.saveInBackgroundWithBlock({ (error: NSError!) -> Void in
                        if error == nil {
                            print("saveInBackgroundWithBlock通った")
                            print("Twitter初回user登録時情報", user)
                            self.performSegueWithIdentifier("setUpedSegue", sender: self)
                        } else {
                            print("saveInBackgroundWithBlockエラー: \(error)")
                        }
                    })
                } else {
                    //二度目以降（ログイン）
                    print("出戻りユーザー")
                    print("user状態１\(user)")
                    //userクラスのデータを取ってくる
                    user.fetchInBackgroundWithBlock({ (error) -> Void in
                        if error == nil {
                            print("fetchInBackgroundWithBlock成功のuser : \(user)")
                            print("Twitterログイン成功")
                            self.performSegueWithIdentifier("signUpedSegue", sender: self)
                        } else {
                            print("error")
                        }
                    })
                }
            }else {
                print("Error: \(error)")
                if error == nil {
                    print("Twitterログインがキャンセルされた")
                } else {
                    print("エラー: \(error)")
                }
            }
        }
    }
    


    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
