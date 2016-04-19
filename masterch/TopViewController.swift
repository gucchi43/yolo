//
//  TopViewController.swift
//  masterch
//
//  Created by HIroki Taniguti on 2016/04/19.
//  Copyright © 2016年 Fumiya Yamanaka. All rights reserved.
//

import UIKit

class TopViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    
    //「戻る」用segue先
    @IBAction func unwindToTopView(segue: UIStoryboardSegue) {
        print("back to TopViewController")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
