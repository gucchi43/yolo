//
//  PostDetail.swift
//  masterch
//
//  Created by Fumiya Yamanaka on 2016/02/19.
//  Copyright © 2016年 Fumiya Yamanaka. All rights reserved.
//

import UIKit

class PostDetailViewController: UIViewController {
    
    @IBOutlet var postTextLabel: UILabel!
    @IBOutlet var postImageView: UIImageView!
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
        postImageView.image = postImage
        
        // 画像のアスペクト比を維持しUIImageViewサイズに収まるように表示
        postImageView.contentMode = UIViewContentMode.ScaleAspectFit
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    

    
}
