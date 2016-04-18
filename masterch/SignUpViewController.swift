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
    
    @IBOutlet weak var userId: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var errorMessage: UILabel!
    
    let user = NCMBUser.currentUser()
    
    //NCMBUserのインスタンスを作成
    let newUser = NCMBUser()
    
    
    
    @IBAction func signUpBtn(sender: AnyObject) {
        newUser.userName = userId.text
        newUser.password = password.text
        
        let userImage = UIImage(named: "noprofile.png")
        let userimageData = UIImagePNGRepresentation(userImage!)! as NSData
        let userimageFile: NCMBFile = NCMBFile.fileWithData(userimageData) as! NCMBFile
        newUser.setObject(userimageFile.name, forKey: "userProfileImage")
        newUser.setObject("No Name", forKey: "userFaceName")
        
        if self.password.text?.utf16.count <= 6 {
            print("６文字以下")
            self.errorMessage.text = "パスワードは６文字以上入力してください"
        }else {
            newUser.signUpInBackgroundWithBlock({(NSError error) in
                if error != nil  {
                    // Signup失敗
                    print("Signup失敗", error)
                    self.errorMessage.text = error.localizedDescription
                }else{
                    //Signup成功
                    //画面遷移
                    print("Signup成功", self.newUser)
                    self.performSegueWithIdentifier("setUpedSegue", sender: self)
                }
            })
        }
    }
    
    
    @IBAction func logInBtn(sender: AnyObject) {
        NCMBUser.logInWithUsernameInBackground(userId.text, password: password.text) { (user, error) -> Void in
            if error != nil {
                //Login失敗
                print("Login失敗", error)
                self.errorMessage.text = error.localizedDescription
                
            }else {
                //Login成功
                print("Login成功", user)
                self.performSegueWithIdentifier("signUpedSegue", sender: self)
            }
        }

    }
    
    
    
//    @IBOutlet weak var logInBtn: UIButton!{
    
    
    
    
    //Facebookログイン&サインアップ
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
    
    //Twitterログイン&サインアップ
    @IBAction func twSignUpBtn(sender: AnyObject) {
        print("Twitterログインボタン押した")
        NCMBTwitterUtils.logInWithBlock { (user: NCMBUser!, error: NSError!) -> Void in
            if let user = user {
                let name = NCMBTwitterUtils.twitter().screenName
                print("name: \(name)")
                
                //初めてのログインかの分岐
                if user.createDate == user.updateDate{
                    //初めてのユーザー（Twitterでユーザー登録）
                    print("初めてユーザー")
                    //ユーザー名を設定
                    user.setObject(name, forKey: "userFaceName")
//                    user.userName = name
                    
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
                    user.setObject(name, forKey: "twitterName")
                    
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
                            user.setObject(name, forKey: "twitterName")
                            user.saveInBackgroundWithBlock({ (error) -> Void in
                                if error == nil {
                                    print("fetchInBackgroundWithBlock成功のuser : \(user)")
                                    print("Twitterログイン成功")
                                    self.performSegueWithIdentifier("signUpedSegue", sender: self)
                                }else {
                                    print("error")
                                }
                            })
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
        self.errorMessage.text = ""
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
