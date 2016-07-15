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
    
    @IBOutlet weak var userId2TextField: UITextField!
    @IBOutlet weak var password2TextField: UITextField!
    
    @IBOutlet weak var userIdTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    
    
    @IBOutlet weak var testTextFiled: UITextField!
    
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
            RMUniversalAlert.showAlertInViewController(self, withTitle: "エラー", message: "ユーザーIDは半角英数字で入力してください", cancelButtonTitle: "OK", destructiveButtonTitle: nil, otherButtonTitles: nil, tapBlock: nil)
        }else if self.passwordTextField.text?.utf16.count < 6 {
            print("６文字以下")
            RMUniversalAlert.showAlertInViewController(self, withTitle: "エラー", message: "パスワードは6文字以上入力してください", cancelButtonTitle: "OK", destructiveButtonTitle: nil, otherButtonTitles: nil, tapBlock: nil)
        }else {
            newUser.signUpInBackgroundWithBlock({(error) in
                if error != nil  {
                    // SignUp失敗
                    print("SignUp失敗", error)
                    self.showErrorAlert(error)
                }else{
                    //SignUp成功
                    //画面遷移
                    print("SignUp成功", newUser)
                    //Log周りのシングルトンを初期化する
                    logManager.sharedSingleton.resetSharedSingleton()
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

