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
    
    //NCMBUserのインスタンスを作成
    let newUser = NCMBUser()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.errorMessage.text = ""
    }
    
    
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
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
