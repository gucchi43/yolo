//
//  SignUpViewController.swift
//  masterch
//
//  Created by HIroki Taniguti on 2016/03/08.
//  Copyright © 2016年 Fumiya Yamanaka. All rights reserved.
//

import UIKit
import NCMB
import TwitterKit
import SVProgressHUD

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var userIdTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //userIdTextField入力画面を呼び出し
        userIdTextField.becomeFirstResponder()
        userIdTextField.addUnderline(1.0, color: UIColor.lightGrayColor())
        passwordTextField.addUnderline(1.0, color: UIColor.lightGrayColor())
        
        //戻るボタンを隠す（効いていない）
//        self.navigationItem.hidesBackButton = true
    }
    
    //textfieldのreturnkey押した時の動作
    func textFieldShouldReturn(textField: UITextField) -> Bool{
        if (textField == userIdTextField) {
            passwordTextField?.becomeFirstResponder()
        } else {
            signUp()
//             キーボードを閉じる
            textField.resignFirstResponder()
        }
        return true
    }
    
    @IBAction func selectSignUpButton(sender: AnyObject) {
        print("signUpButton 押した")
        signUp()
    }
    
    func signUp() {

        let newUser = NCMBUser()
        newUser.userName = userIdTextField.text
        newUser.password = passwordTextField.text

        if ((self.userIdTextField.text?.dataUsingEncoding(NSASCIIStringEncoding, allowLossyConversion: false)) == nil) {
            print("ユーザーIDは半角英数字じゃないと")
            let alert: UIAlertController = UIAlertController(title: "エラー",
                                                             message: "ユーザーIDは半角英数字で入力してください",
                                                             preferredStyle:  UIAlertControllerStyle.Alert)
            let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler:{
                // ボタンが押された時の処理を書く（クロージャ実装）
                (action: UIAlertAction!) -> Void in
                print("OK")
            })
            alert.addAction(defaultAction)
            presentViewController(alert, animated: true, completion: nil)
        }else if self.passwordTextField.text?.utf16.count < 6 {
            print("６文字以下")
            let alert: UIAlertController = UIAlertController(title: "エラー",
                                                             message: "パスワードは6文字以上入力してください",
                                                             preferredStyle:  UIAlertControllerStyle.Alert)
            let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler:{
                // ボタンが押された時の処理を書く（クロージャ実装）
                (action: UIAlertAction!) -> Void in
                print("OK")
            })
            alert.addAction(defaultAction)
            presentViewController(alert, animated: true, completion: nil)
        }else {
            SVProgressHUD.show()
            newUser.signUpInBackgroundWithBlock({(error) in
                if error != nil  {
                    // SignUp失敗
                    print("SignUp失敗", error)
                    self.signUpErrorAlert(error)
                    SVProgressHUD.dismiss()
                }else{
                    //SignUp成功
                    //画面遷移
                    print("SignUp成功", newUser)
                    //Log周りのシングルトンを初期化する
                    logManager.sharedSingleton.resetSharedSingleton()
                    SVProgressHUD.dismiss()
                    self.performSegueWithIdentifier("toSetProfileViewSegue", sender: self)
                }
                
            })
        }
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

