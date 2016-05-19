//
//  ViewController.swift
//  masterch
//
//  Created by Fumiya Yamanaka on 2016/01/31.
//  Copyright © 2016年 Fumiya Yamanaka. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

extension UIViewController {
//    SignUP,SignInのエラー表示メソッド
    func showErrorAlert(error:NSError){
        var title:String!
        var message:String?
        var buttonTitle:String!
        if error.localizedFailureReason == nil{
            message = error.localizedDescription
        }else{
            message = error.localizedFailureReason
        }
        if let suggestion = error.localizedRecoverySuggestion {
            title = suggestion
        }else{
            title = "エラー"
        }
        if let titles = error.localizedRecoveryOptions {
            buttonTitle = titles[0]
        }else{
            buttonTitle = "OK"
        }
        
        RMUniversalAlert.showAlertInViewController(self, withTitle: title, message: message, cancelButtonTitle: buttonTitle, destructiveButtonTitle: nil, otherButtonTitles: nil, tapBlock: nil)
    }

}

