//
//  OtherAccountViewController.swift
//  masterch
//
//  Created by HIroki Taniguti on 2016/05/16.
//  Copyright © 2016年 Fumiya Yamanaka. All rights reserved.
//

import UIKit

class OtherAccountViewController: UIViewController {

    @IBOutlet weak var userNameLabel: UILabel!
    
    var userName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userNameLabel.text = userName

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
