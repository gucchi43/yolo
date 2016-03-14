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
            if let u = user {
                if u.isNew {
                    print("Twitterで登録成功")
                    print("会員登録後の処理")
                    // ACLを本人のみに設定
                    let acl = NCMBACL(user: NCMBUser.currentUser())
                    user.ACL = acl
                    user.saveInBackgroundWithBlock({ (error: NSError!) -> Void in
                        if error == nil {
                            print("ACLの保存成功")
                        } else {
                            print("ACL設定の保存失敗: \(error)")
                        }
                        self.performSegueWithIdentifier("signUpedSegue", sender: self)
//                        self.performSegueWithIdentifier("unwindFromLogin", sender: self)
                    })
                } else {
                    print("Twitterでログイン成功: \(u)")
                    self.performSegueWithIdentifier("signUpedSegue", sender: self)
//                    self.performSegueWithIdentifier("unwindFromLogin", sender: self)
                }
            } else {
                print("Error: \(error)")
                if error == nil {
                    print("Twitterログインがキャンセルされた")
                } else {
                    print("エラー: \(error)")
                }
            }
        }
    }
    
    
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if (segue.identifier == "signUpedSegue"){
//            let viewController = segue.destinationViewController as! LogViewController
//        }
//        
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
