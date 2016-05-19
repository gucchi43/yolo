//
//  SignUpViewController.swift
//  masterch
//
//  Created by HIroki Taniguti on 2016/03/08.
//  Copyright © 2016年 Fumiya Yamanaka. All rights reserved.
//

import UIKit
import TwitterKit

class SignUpViewController: UIViewController, UITextFieldDelegate {
    

    @IBOutlet weak var userIdTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    //NCMBUserのインスタンスを作成
    let newUser = NCMBUser()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //userIdTextField入力画面を呼び出し
        userIdTextField.becomeFirstResponder()
        
        //戻るボタンを隠す（効いていない）
        self.navigationItem.hidesBackButton = true
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
    
    @IBAction func signUpButton(sender: AnyObject) {
        print("signUpButton 押した")
        signUp()
    }
    
    func signUp() {
        newUser.userName = userIdTextField.text
        newUser.password = passwordTextField.text
        
        let userImage = UIImage(named: "noprofile.png")
        let userimageData = UIImagePNGRepresentation(userImage!)! as NSData
        let userimageFile: NCMBFile = NCMBFile.fileWithData(userimageData) as! NCMBFile
        newUser.setObject(userimageFile.name, forKey: "userProfileImage")
        newUser.setObject("No Name", forKey: "userFaceName")
        
        newUser.ACL.setPublicWriteAccess(true)
        newUser.ACL.setPublicReadAccess(true)
        
        
        if ((self.userIdTextField.text?.dataUsingEncoding(NSASCIIStringEncoding, allowLossyConversion: false)) == nil) {
            RMUniversalAlert.showAlertInViewController(self, withTitle: "エラー", message: "ユーザーIDは半角英数字で入力してください", cancelButtonTitle: "OK", destructiveButtonTitle: nil, otherButtonTitles: nil, tapBlock: nil)
        }else if self.passwordTextField.text?.utf16.count <= 6 {
            print("６文字以下")
            RMUniversalAlert.showAlertInViewController(self, withTitle: "エラー", message: "パスワードは6文字以上入力してください", cancelButtonTitle: "OK", destructiveButtonTitle: nil, otherButtonTitles: nil, tapBlock: nil)
        }else {
            self.newUser.signUpInBackgroundWithBlock({(NSError error) in
                if error != nil  {
                    // Signup失敗
                    print("Signup失敗", error)
                    self.showErrorAlert(error)
                }else{
                    //Signup成功
                    //画面遷移
                    print("Signup成功", self.newUser)
                    self.performSegueWithIdentifier("setUpedSegue", sender: self)
                }
            })
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

