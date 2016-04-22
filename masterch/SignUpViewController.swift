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
    

    @IBOutlet weak var errorMessage: UILabel!
    @IBOutlet weak var userIdTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    //NCMBUserのインスタンスを作成
    let newUser = NCMBUser()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userIdTextField?.delegate = self
        passwordTextField?.delegate = self
        
        //エラーメッセージは最初表示しない
        self.errorMessage.text = ""
        
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
            userSignUp()
//             キーボードを閉じる
            textField.resignFirstResponder()
        }
        return true
    }
    
    
    @IBAction func signUpBtn(sender: AnyObject) {
        print("signUpBtn 押した")
        userSignUp()
    }
    
    func userSignUp() {
        newUser.userName = userIdTextField.text
        newUser.password = passwordTextField.text
        
        let userImage = UIImage(named: "noprofile.png")
        let userimageData = UIImagePNGRepresentation(userImage!)! as NSData
        let userimageFile: NCMBFile = NCMBFile.fileWithData(userimageData) as! NCMBFile
        newUser.setObject(userimageFile.name, forKey: "userProfileImage")
        newUser.setObject("No Name", forKey: "userFaceName")
        
        if self.passwordTextField.text?.utf16.count <= 6 {
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
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
