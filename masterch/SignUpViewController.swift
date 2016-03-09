//
//  SignUpViewController.swift
//  masterch
//
//  Created by HIroki Taniguti on 2016/03/08.
//  Copyright © 2016年 Fumiya Yamanaka. All rights reserved.
//

import UIKit 

class SignUpViewController: UIViewController {
    
    @IBAction func fbSignUpBtn(sender: AnyObject) {
        NCMBFacebookUtils.logInWithReadPermission(["email"]) {(user, error) -> Void in
            if (error != nil){
                if (error.code == NCMBErrorFacebookLoginCancelled){
                    // Facebookのログインがキャンセルされた場合
                }else{
                    // その他のエラーが発生した場合
                    print("FBエラー")
                }
            }else{
                // 会員登録後の処理
                print("FBサクセス")
                self.performSegueWithIdentifier("signUpedSegue", sender: self)
            }
        }
    }
    
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if (segue.identifier == "signUpedSegue"){
//            let viewController = segue.destinationViewController as! LogViewController
//        }
//        
//    }
    
    override func viewDidAppear(animated: Bool) {
        if (FBSDKAccessToken.currentAccessToken() != nil){
            self.performSegueWithIdentifier("signUpedSegue", sender: self)
            print("サインアップ済み \(FBSDKAccessToken.currentAccessToken)")
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
