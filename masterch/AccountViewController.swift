//
//  AccountViewController.swift
//  masterch
//
//  Created by Fumiya Yamanaka on 2016/02/09.
//  Copyright © 2016年 Fumiya Yamanaka. All rights reserved.
//

import UIKit

class AccountViewController: UIViewController {
    
    @IBOutlet weak var segmentedController: UISegmentedControl!
    
    @IBOutlet weak var containerSnsView: UIView!

    @IBOutlet weak var containerProfileView: UIView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        print("AccountViewController")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func didValueChanged(sender: AnyObject) {
        
        switch sender.selectedSegmentIndex{
        case 0:
            //valueChanged: 0の時の実装（containerProfileView表示）
            print("case = 0")
            UIView.animateWithDuration(0.1, animations: {
                self.containerSnsView.alpha = 0
                self.containerProfileView.alpha = 1
            })
        case 1:
            //valueChanged: 1の時の実装（containerSnsView表示）
            print("case = 1")
            UIView.animateWithDuration(0.1, animations: {
                self.containerSnsView.alpha = 1
                self.containerProfileView.alpha = 0
            })
        default:
            print("segmentedControllerd: 原因不明のエラー")
        }
    }
    
    @IBAction func unwindToTop(segue: UIStoryboardSegue) {
        print("back to AccountView")
    }
    
}