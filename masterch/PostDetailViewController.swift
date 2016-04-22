//
//  PostDetail.swift
//  masterch
//
//  Created by Fumiya Yamanaka on 2016/02/19.
//  Copyright © 2016年 Fumiya Yamanaka. All rights reserved.
//

import UIKit

class PostDetailViewController: UIViewController {
    
    @IBOutlet var userFaceNameLabel: UILabel!
    @IBOutlet var userNameLabel: UILabel!
    @IBOutlet var userProfileImageView: UIImageView!
    @IBOutlet var postDateLabel: UILabel!
    @IBOutlet var postTextLabel: UILabel!
    @IBOutlet var postImageView: UIImageView!
    @IBOutlet var postImageViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet var commentButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    
    var userFaceName: String!
    var userName: String!
    var userProfileImage: UIImage!
    var postDateText: String!
    var postText: String!
    var postImage: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        userFaceNameLabel.text = userFaceName
        userNameLabel.text = userName
        userProfileImageView.image = userProfileImage
        postDateLabel.text = postDateText
        postTextLabel.text = postText
        
        // 画像の有無で場合分け
        if (postImage == nil) {
            postImageView.image = nil
            postImageViewHeightConstraint.constant = 0.0
        } else {
            postImageView.image = postImage
            postImageViewHeightConstraint.constant = 400
        }
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    

    
}
