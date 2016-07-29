//
//  ConnectMailTableViewController.swift
//  masterch
//
//  Created by HIroki Taniguti on 2016/07/28.
//  Copyright © 2016年 Fumiya Yamanaka. All rights reserved.
//

import UIKit
import SVProgressHUD



class ConnectMailTableViewController: UITableViewController {

    var mailAdless: String?

    @IBOutlet weak var nowMailLabel: UILabel!
    @IBOutlet weak var newMailTextField: UITextField!
    @IBOutlet weak var ConfirmNewMailTextField: UITextField!
    @IBOutlet weak var changeConnectMailButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
//        changeConnectMailButton.layer.cornerRadius = 2.0
//        changeConnectMailButton.layer.borderColor = ColorManager.sharedSingleton.mainColor().CGColor
//        changeConnectMailButton.layer.borderWidth = 1.0
        loadConnctMailStatus()
    }

    func loadConnctMailStatus() {
        print(NCMBUser.currentUser().objectForKey("mailAddress"))
        if let mail = NCMBUser.currentUser().objectForKey("mailAddress") as? String {
            nowMailLabel.text = mail
        }else {
            nowMailLabel.text = "未連携"
        }
    }

    //textfieldのreturnkey押した時の動作
    func textFieldShouldReturn(textField: UITextField) -> Bool{
        if (textField == newMailTextField) {
            ConfirmNewMailTextField?.becomeFirstResponder()
        } else {
            saveConnectMail()
            //キーボードを閉じる
            textField.resignFirstResponder()
        }
        return true
    }

    @IBAction func tapchangeConnectMailButton(sender: AnyObject) {
        if newMailTextField.text != ConfirmNewMailTextField.text{
            //確認用メールアドレスと一致していません
            print("確認用メールアドレスと一致していません")
            RMUniversalAlert.showAlertInViewController(self, withTitle: "エラー", message: "確認用メールアドレスと一致していません", cancelButtonTitle: "OK", destructiveButtonTitle: nil, otherButtonTitles: nil, tapBlock: nil)

        } else if newMailTextField.text == nowMailLabel.text{
            //前回のアドレスと同じ
            print("現在のメールアドレスと同じです")
            RMUniversalAlert.showAlertInViewController(self, withTitle: "エラー", message: "現在のメールアドレスと同じです", cancelButtonTitle: "OK", destructiveButtonTitle: nil, otherButtonTitles: nil, tapBlock: nil)
        } else if isValidEmail(newMailTextField.text!) == false {
            //正しいメールアドレスじゃない
            print("正しいメールアドレスではありません")
            RMUniversalAlert.showAlertInViewController(self, withTitle: "エラー", message: "正しいメールアドレスではありません", cancelButtonTitle: "OK", destructiveButtonTitle: nil, otherButtonTitles: nil, tapBlock: nil)
        }
        else {
            saveConnectMail()
        }
    }

    //メールアドレスの形が確認メソッド
    func isValidEmail(string: String) -> Bool {
        print("validate calendar: \(string)")
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        let result = emailTest.evaluateWithObject(string)
        return result
    }

    func saveConnectMail() {
        //該当するエラーがない場合、mailAddressにセットする
        NCMBUser.currentUser().setObject(newMailTextField.text, forKey: "mailAddress")

        SVProgressHUD.show()
        NCMBUser.currentUser().saveEventually({ (error) in
            if let error = error {
                print(error.localizedDescription)
                SVProgressHUD.showErrorWithStatus("通信状況が悪いため変更に失敗しました")
            }else {
                SVProgressHUD.showWithStatus("保存しました")
                self.loadConnctMailStatus()
                SVProgressHUD.dismiss()
            }
        })

    }
}

