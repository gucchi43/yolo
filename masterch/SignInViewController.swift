//
//  SignInViewController.swift
//  masterch
//
//  Created by Fumiya Yamanaka on 2016/05/19.
//  Copyright © 2016年 Fumiya Yamanaka. All rights reserved.
//

import UIKit
import TwitterKit
import SVProgressHUD

class SignInViewController: UIViewController {
    @IBOutlet weak var userIdTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    let user = NCMBUser.currentUser()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //userIdTextField入力画面を呼び出し
        userIdTextField.becomeFirstResponder()
        userIdTextField.addUnderline(1.0, color: UIColor.lightGrayColor())
        passwordTextField.addUnderline(1.0, color: UIColor.lightGrayColor())
        
    }
    
    //textfieldのreturnkey押した時の動作
    func textFieldShouldReturn(textField: UITextField) -> Bool{
        if (textField == userIdTextField) {
            passwordTextField?.becomeFirstResponder()
        } else {
            signIn()
            //キーボードを閉じる
            textField.resignFirstResponder()
        }
        return true
    }
    
    @IBAction func SignInBtn(sender: AnyObject) {
        print("SignInBtn 押した")
        signIn()
    }
    
    func signIn() {
//        SVProgressHUD.showWithStatus("読み込み中")
        SVProgressHUD.show()
        NCMBUser.logInWithUsernameInBackground(userIdTextField.text, password: passwordTextField.text) { (user, error) -> Void in
            if error != nil {
                //Login失敗
                print("Login失敗", error)
                SVProgressHUD.dismiss()
                self.showErrorAlert(error)
            }else {
                //Login成功
                print("Login成功", user)
                SVProgressHUD.dismiss()
                self.performSegueWithIdentifier("signUpedSegue", sender: self)
            }
        }
    }
}

extension SignInViewController {
    //Facebookログイン&サインアップ
    @IBAction func fbSignUpButton(sender: AnyObject) {
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
}

extension SignInViewController {
    //Twitterログイン&サインアップ
    @IBAction func twSignUpButton(sender: AnyObject) {
        print("Twitterログインボタン押した")
        NCMBTwitterUtils.logInWithBlock { (user: NCMBUser!, error: NSError!) -> Void in
            if let user = user {
                let name = NCMBTwitterUtils.twitter().screenName
                let userID = NCMBTwitterUtils.twitter().userId
                let authToken = NCMBTwitterUtils.twitter().authToken
                let authTokenSecret = NCMBTwitterUtils.twitter().authTokenSecret
                print("name: \(name)")
                //初めてのログインかの分岐
                if user.createDate == user.updateDate{
                    //初めてのユーザー（Twitterでユーザー登録）
                    print("初めてユーザー")
                    //ユーザーIDを設定
                    user.userName = userID
                    //ユーザー名を設定
                    user.setObject(name, forKey: "userFaceName")
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
                    //Twitter接続判断系データ
                    user.setObject(name, forKey: "twitterName")
                    user.setObject(userID, forKey: "twitterID")
                    let store = Twitter.sharedInstance().sessionStore
                    
                    print(store)
                    store.saveSessionWithAuthToken(authToken, authTokenSecret: authTokenSecret, completion: { (session, error) -> Void in
                        if error == nil {
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
                        }else {
                            print("error: authTokenなどが取得できなかった")
                        }
                    })
                } else {
                    //二度目以降（ログイン）
                    print("出戻りユーザー")
                    print("user状態１\(user)")
                    //userクラスのデータを取ってくる
                    user.fetchInBackgroundWithBlock({ (error) -> Void in
                        if error == nil {
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
}