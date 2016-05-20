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
        
        userProfileImageView.layer.cornerRadius = userProfileImageView.frame.width/2
        let userProfileImageName = (user.objectForKey("userProfileImage") as? String)!
        let userProfileImageData = NCMBFile.fileWithName(userProfileImageName, data: nil) as! NCMBFile
        userProfileImageData.getDataInBackgroundWithBlock { (imageData: NSData?, error: NSError!) -> Void in
            if error != nil{
                print("写真の取得失敗: \(error)")
            } else {
                self.userProfileImageView.image = UIImage(data: imageData!)
            }
        }
        
        let userHomeImageName = (user.objectForKey("userHomeImage") as? String)!
        let userHomeImageData = NCMBFile.fileWithName(userHomeImageName, data: nil) as! NCMBFile
        userHomeImageData.getDataInBackgroundWithBlock { (imageData: NSData?, error: NSError!) -> Void in
            if error != nil{
                print("写真の取得失敗: \(error)")
            } else {
                self.userHomeImageView.image = UIImage(data: imageData!)
            }
        }
        
        userSelfIntroductionLabel.text = user.objectForKey("userSelfIntroduction") as? String
        userSelfIntroductionLabel.sizeToFit()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
