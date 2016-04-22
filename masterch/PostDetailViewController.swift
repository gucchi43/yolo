//
//  PostDetail.swift
//  masterch
//
//  Created by Fumiya Yamanaka on 2016/02/19.
//  Copyright © 2016年 Fumiya Yamanaka. All rights reserved.
//

import UIKit

class PostDetailViewController: UIViewController {
    
    @IBOutlet var userNameLabel: UILabel!
    @IBOutlet var userProfileImageView: UIImageView!
    @IBOutlet var postDateLabel: UILabel!
    @IBOutlet var postTextLabel: UILabel!
    @IBOutlet var postImageView: UIImageView!
    @IBOutlet var postImageViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet var commentButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    
    var userName: String!
    var userProfileImage: UIImage!
    var postDateText: String!
    var postText: String!
    var postImage: UIImage! 
    
    @IBAction func tapCancelButton(sender: UIBarButtonItem) {
        print("timelineに戻る")
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        postTextLabel.text = postText

        
        
        // 画像の有無で場合分け
        if (postImage != nil) {
            postImageView.image = postImage
            postImageViewHeightConstraint.constant = 300
            
        } else {
            postImageView.image = nil
            postImageViewHeightConstraint.constant = 0.0
        }
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    

    
}
