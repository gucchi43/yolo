//
//  OtherAccountViewController.swift
//  masterch
//
//  Created by HIroki Taniguti on 2016/05/16.
//  Copyright © 2016年 Fumiya Yamanaka. All rights reserved.
//

import UIKit

class OtherAccountViewController: UIViewController {
    
    
    @IBOutlet weak var userProfileImageView: UIImageView!
    @IBOutlet weak var userProfileNameLabel: UILabel!
    @IBOutlet weak var userIdLabel: UILabel!
    @IBOutlet weak var userHomeImageView: UIImageView!
    @IBOutlet weak var userSelfIntroductionLabel: UILabel!
    
    var user: NCMBUser!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(user)
        userIdLabel.text = "@" + user.userName
        userProfileNameLabel.text = user.objectForKey("userFaceName") as? String
        userProfileImageView.image = user.objectForKey("userProfileImage") as? UIImage
        userHomeImageView.image = user.objectForKey("userHomeImage") as? UIImage
        userSelfIntroductionLabel.text = user.objectForKey("userSelfIntroduction") as? String

        userProfileImageView.layer.cornerRadius = userProfileImageView.frame.width/2

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
