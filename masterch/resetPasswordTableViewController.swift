//
//  ResetPasswordTableViewController.swift
//  masterch
//
//  Created by HIroki Taniguti on 2016/07/29.
//  Copyright © 2016年 Fumiya Yamanaka. All rights reserved.
//

import UIKit
import SVProgressHUD

class ResetPasswordTableViewController: UITableViewController {

    @IBOutlet weak var mailTextField: UITextField!
    @IBOutlet weak var reserPasswordButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool{
        if textField == mailTextField {
            textField.resignFirstResponder()
        }
        return  true
    }

    @IBAction func selectBackToButton(sender: AnyObject) {
        print("パスワードリセットから戻る")
        dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func tapReserPasswordButton(sender: AnyObject) {
        if isValidEmail(mailTextField.text!) == false {print("正しいメールアドレスではありません")
        RMUniversalAlert.showAlertInViewController(self, withTitle: "エラー", message: "正しいメールアドレスではありません", cancelButtonTitle: "OK", destructiveButtonTitle: nil, otherButtonTitles: nil, tapBlock: nil)
        }else {
            sendResetPasswordRequest()
        }
    }

    //メールアドレスの形か確認メソッド
    func isValidEmail(string: String) -> Bool {
        print("validate calendar: \(string)")
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        let result = emailTest.evaluateWithObject(string)
        return result
    }

    //パスワードリセットメール送信
    func sendResetPasswordRequest(){
        SVProgressHUD.show()
        NCMBUser.requestPasswordResetForEmailInBackground(mailTextField.text) { (error) in
            if let error = error{
                print(error.localizedDescription)
                SVProgressHUD.showErrorWithStatus("メールが送信出来ませんでした")
            }else {
                SVProgressHUD.showWithStatus("入力されたメールアドレスにパスワードリセットのメールを送信しました")
                SVProgressHUD.dismissWithDelay(2.0)
            }
        }
    }
}

