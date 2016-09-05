//
//  ConnectMailTableViewController.swift
//  masterch
//
//  Created by HIroki Taniguti on 2016/07/28.
//  Copyright © 2016年 Fumiya Yamanaka. All rights reserved.
//

import UIKit
import SVProgressHUD
import NCMB

class ConnectMailTableViewController: UITableViewController, UITextFieldDelegate{

    var mailAdless: String?

    @IBOutlet weak var nowMailLabel: UILabel!
    @IBOutlet weak var newMailTextField: UITextField!
    @IBOutlet weak var confirmNewMailTextField: UITextField!
    @IBOutlet weak var changeConnectMailButton: UIButton!
    @IBOutlet weak var cancelConnectMailButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        loadConnctMailStatus()
        newMailTextField.delegate = self
        confirmNewMailTextField.delegate = self
    }

    func loadConnctMailStatus() {
        print(NCMBUser.currentUser().objectForKey("mailAddress") as? String)
        if let mail = NCMBUser.currentUser().objectForKey("mailAddress") as? String {
            nowMailLabel.text = mail
        }else {
            nowMailLabel.text = "未連携"
        }
    }

    //textfieldのreturnkey押した時の動作
    func textFieldShouldReturn(textField: UITextField) -> Bool{
        if (textField == newMailTextField) {
            confirmNewMailTextField?.becomeFirstResponder()
        } else {
//            saveConnectMail()
            //キーボードを閉じる
            textField.resignFirstResponder()
        }
        return true
    }

    @IBAction func tapCancelConnectMailButton(sender: AnyObject) {
        print("mailAddress", NCMBUser.currentUser().objectForKey("mailAddress"))
        SVProgressHUD.show()
        if let mail = NCMBUser.currentUser().objectForKey("mailAddress") as? String{
//        if let mail = NCMBUser.currentUser().objectForKey("mailAddress") as? String {
            //連携済み
            NCMBUser.currentUser().removeObjectForKey("mailAddress")
            NCMBUser.currentUser().saveInBackgroundWithBlock({ (error) in
                if let error = error {
                    print(error.localizedDescription)
                    SVProgressHUD.showErrorWithStatus("メールアドレスの解除ができませんでした")
                }else {
                    print("メールアドレス連携解除後: ", NCMBUser.currentUser().objectForKey("mailAddress") as? String)
                    SVProgressHUD.showWithStatus("解除しました")
                    self.loadConnctMailStatus()
                    SVProgressHUD.dismissWithDelay(2.0)
                }
            })
        }else {
            //未連携
            SVProgressHUD.showWithStatus("メールアドレスは連携されていません")
            SVProgressHUD.dismissWithDelay(2.0)
        }
    }


    @IBAction func tapchangeConnectMailButton(sender: AnyObject) {
        confirmNewMailTextField.resignFirstResponder()
        if newMailTextField.text != confirmNewMailTextField.text{
            //確認用メールアドレスと一致していません
            print("確認用メールアドレスと一致していません")
            let alert: UIAlertController = UIAlertController(title: "エラー",
                                                             message: "確認用メールアドレスと一致していません",
                                                             preferredStyle:  UIAlertControllerStyle.Alert)
            let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler:{
                // ボタンが押された時の処理を書く（クロージャ実装）
                (action: UIAlertAction!) -> Void in
                print("OK")
            })
            alert.addAction(defaultAction)
            presentViewController(alert, animated: true, completion: nil)
        } else if newMailTextField.text == nowMailLabel.text{
            //前回のアドレスと同じ
            print("現在のメールアドレスと同じです")
            let alert: UIAlertController = UIAlertController(title: "エラー",
                                                             message: "現在のメールアドレスと同じです",
                                                             preferredStyle:  UIAlertControllerStyle.Alert)
            let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler:{
                // ボタンが押された時の処理を書く（クロージャ実装）
                (action: UIAlertAction!) -> Void in
                print("OK")
            })
            alert.addAction(defaultAction)
            presentViewController(alert, animated: true, completion: nil)
        } else if isValidEmail(newMailTextField.text!) == false {
            //正しいメールアドレスじゃない
            print("正しいメールアドレスではありません")
            let alert: UIAlertController = UIAlertController(title: "エラー",
                                                             message: "正しいメールアドレスではありません",
                                                             preferredStyle:  UIAlertControllerStyle.Alert)
            let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler:{
                // ボタンが押された時の処理を書く（クロージャ実装）
                (action: UIAlertAction!) -> Void in
                print("OK")
            })
            alert.addAction(defaultAction)
            presentViewController(alert, animated: true, completion: nil)
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
                self.newMailTextField.text = ""
                self.confirmNewMailTextField.text = ""
                SVProgressHUD.dismissWithDelay(1.5)
            }
        })

    }
}

