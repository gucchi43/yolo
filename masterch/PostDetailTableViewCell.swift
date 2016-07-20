//
//  PostDetailTableViewCell.swift
//  masterch
//
//  Created by Fumiya Yamanaka on 2016/05/30.
//  Copyright © 2016年 Fumiya Yamanaka. All rights reserved.
//

import UIKit
import Foundation
import SVProgressHUD

protocol PostDetailTableViewCellDelegate {
    func didSelectCommentButton()
    func didSelectPostProfileImageView()
    func didSelectPostImageView(postImage: UIImage, postText: String)
}

class PostDetailTableViewCell: UITableViewCell {
    
    @IBOutlet var userProfileNameLabel: UILabel!
    @IBOutlet var userNameIDLabel: UILabel!
    @IBOutlet var userProfileImageView: UIImageView!
    @IBOutlet var postDateLabel: UILabel!
    @IBOutlet var postTextLabel: UILabel!
    @IBOutlet var postImageView: UIImageView!
    @IBOutlet var postImageViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var likeNumberButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    
    var auther: NCMBUser!

    var postObject: NCMBObject!
    var likeCounts: Int?

    let likeOnImage = UIImage(named: "hartON")
    let likeOffImage = UIImage(named: "hartOFF")
    
    var isLikeToggle = false
    
    var delegate: PostDetailTableViewCellDelegate!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        userProfileImageView.layer.cornerRadius = userProfileImageView.layer.bounds.width/2
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        print("postDetailTableView")
    }
    
    func setPostDetailCell() {
    
        if let auther = postObject.objectForKey("user") as? NCMBUser {
            print("auther", auther)
            print("postObject", postObject)
            userProfileNameLabel.text = auther.objectForKey("userFaceName") as? String
            userNameIDLabel.text = "@" + auther.userName
            
            //プロフィール写真の形を円形にする
            userProfileImageView.layer.cornerRadius = userProfileImageView.frame.width/2
            let gestureUserProfileImage = UITapGestureRecognizer(target: self, action: #selector(PostDetailTableViewCell.tapUserProfileImage(_:)))
            userProfileImageView.addGestureRecognizer(gestureUserProfileImage)
            
            let userImageData = NCMBFile.fileWithName(auther.objectForKey("userProfileImage") as? String, data: nil) as! NCMBFile
            userImageData.getDataInBackgroundWithBlock({ (imageData: NSData?, error: NSError!) -> Void in
                if let error = error {
                    print("プロフィール画像の取得失敗： ", error)
                    self.userProfileImageView.image = UIImage(named: "noprofile")
                } else {
                    self.userProfileImageView.image = UIImage(data: imageData!)
                }
            })
        } else {
            userNameIDLabel.text = "username"
            userProfileImageView.image = UIImage(named: "noprofile")
        }
        
        postTextLabel.text = postObject.objectForKey("text") as? String
        
        // postDateLabelには(key: "postDate")の値を、NSDateからstringに変換して入れる
        let date = postObject.objectForKey("postDate") as? NSDate
        let postDateFormatter: NSDateFormatter = NSDateFormatter()
        postDateFormatter.dateFormat = "yyyy MM/dd HH:mm"
        postDateLabel.text = postDateFormatter.stringFromDate(date!)
        
        // 画像データの取得
        let gesturePostImage = UITapGestureRecognizer(target: self, action: #selector(PostDetailTableViewCell.tapPostImage(_:)))
        postImageView.addGestureRecognizer(gesturePostImage)
        if let postImageName = postObject.objectForKey("image1") as? String {
            self.postImageViewHeightConstraint.constant = 300

            let postImageData = NCMBFile.fileWithName(postImageName, data: nil) as! NCMBFile
            postImageData.getDataInBackgroundWithBlock({ (imageData: NSData?, error: NSError!) -> Void in
                if let error = error {
                    print("写真の取得失敗： ", error)
//                    SVProgressHUD.showErrorWithStatus("読み込みに失敗しました")
                    self.postImageView.image = nil
                    self.postImageViewHeightConstraint.constant = 0.0
                } else {
                    print(UIImage(data: imageData!))
//                    SVProgressHUD.dismiss()
                    let imageHeight = UIImage(data: imageData!)!.size.height
                    self.postImageViewHeightConstraint.constant = 300
                    self.postImageView.image = UIImage(data: imageData!)
                }
                }, progressBlock: { (progress) in
//                    SVProgressHUD.showProgress(Float(progress)/100, status: "画像読み込み中")
                    print("postImage進行速度 %: ", Float(progress)/100)

            })
        } else {
            self.postImageView.image = nil
            self.postImageViewHeightConstraint.constant = 0.0
        }
        
        if postObject.objectForKey("likeUser") != nil{
            //今までで、消されたかもだけど、必ずいいねされたことはある
            let postLikeUserString = postObject.objectForKey("likeUser")
            //StringをNSArrayに変換
            let postLikeUserArray = postLikeUserString as! NSArray
            let postLikeUserCount = postLikeUserArray.count
            if postLikeUserCount > 0 {
                //いいねをしたユーザーが１人以上いる
                self.likeCounts = postLikeUserCount
                if postLikeUserArray.containsObject(NCMBUser.currentUser().objectId) == true{
                    //自分がいいねしている
                    print("私はすでにいいねをおしている")
                    self.likeButton.setImage(likeOnImage, forState: .Normal)
                    self.likeNumberButton.setTitle(String(self.likeCounts!) + "いいね", forState: .Normal)
                    self.isLikeToggle = true
                }else{
                    //いいねはあるけど、自分がいいねしていない
                    self.likeButton.setImage(likeOffImage, forState: .Normal)
                    self.likeNumberButton.setTitle(String(self.likeCounts!), forState: .Normal)
                }
            }else{
                //いいねしたユーザーはいない
                self.likeButton.setImage(likeOffImage, forState: .Normal)
                self.likeNumberButton.setTitle("", forState: .Normal)
            }
        }else{
            //今まで一度もいいねされたことはない
            self.likeButton.setImage(likeOffImage, forState: .Normal)
            self.likeNumberButton.setTitle("", forState: .Normal)
        }
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

//ユーザーの写真を押して遷移
extension PostDetailTableViewCell: IDMPhotoBrowserDelegate  {
    func tapUserProfileImage (recoginizer: UITapGestureRecognizer){
        print("写真押された")
        delegate.didSelectPostProfileImageView()
    }

    func tapPostImage(recoginizer: UITapGestureRecognizer) {
        print("tapPostImage")
        if let postImage = postImageView.image{
            delegate.didSelectPostImageView(postImage, postText: postTextLabel.text!)
        }

//        let photo = IDMPhoto(image: postImageView.image)
//        photo.caption = "センチメンタルキッス"
//        let photos: NSArray = [photo]
//        let browser = IDMPhotoBrowser.init(photos: photos as [AnyObject])
//        browser.delegate = self
//        let postDetailVC = PostDetailViewController()
//        postDetailVC.presentViewController(browser,animated:true ,completion:nil)
    }
}

// コメント
extension PostDetailTableViewCell {
    
    @IBAction func pushCommentButton(sender: UIButton) {
        print("コメントボタンプッシュ")
//        キーボードが出るようにしたい
        delegate.didSelectCommentButton()
    }
    
}

// いいね
extension PostDetailTableViewCell {
    
    @IBAction func pushLikeButton(sender: AnyObject) {
        print("Likeボタン押してやったぜ")
        let postData = postObject
        //いいねアクション実行
        if self.isLikeToggle == true{
            disLike(postData)
        } else {
            like(postData)
        }
        
    }
    
    func like(postData: NCMBObject){
        //いいねONボタン
        self.likeButton.enabled = false
        self.likeButton.setImage(likeOnImage, forState: .Normal)
        if self.likeCounts != nil{
            //likeCountが追加で変更される時（2回目以降）
            if let oldLinkCounts = Int(self.likeNumberButton.currentTitle!.stringByReplacingOccurrencesOfString("いいね", withString: "")){
                //普通にいいねを１追加（2~）
                print("oldLinkCounts", oldLinkCounts)
                let newLikeCounts = oldLinkCounts + 1
                self.likeNumberButton.setTitle(String(newLikeCounts) + "いいね", forState: .Normal)
            }else {
                //oldCountがない場合（以前いいねされたけど、削除されて0になってlikeCountがnullの場合）
                let newLikeCounts = 1
                self.likeNumberButton.setTitle(String(newLikeCounts) + "いいね", forState: .Normal)
            }
        }else{
            //likeCountが初めて変更される時
            let newLikeCounts = 1
            self.likeNumberButton.setTitle(String(newLikeCounts) + "いいね", forState: .Normal)
        }
        postData.addUniqueObject(NCMBUser.currentUser().objectId, forKey: "likeUser")
        postData.saveEventually ({ (error) -> Void in
            if let error = error{
                print(error.localizedDescription)
                self.likeButton.enabled = true
            }else {
                print("save成功 いいね保存")
                self.isLikeToggle = true
                //いいねしたことを通知画面のDBに保存
                let auther = postData.objectForKey("user") as! NCMBUser
                let allPostText = postData.objectForKey("text") as! String
                let allPostTextCount = allPostText.characters.count
                print("allPostTextCount", allPostTextCount)
                let postHeader: String?
                if allPostTextCount > 100{
                    postHeader = allPostText.substringToIndex(allPostText.startIndex.advancedBy(100))
                }else {
                    postHeader = allPostText
                }
                print("Notificatoinに保存する最初の５０文字", postHeader!)
                let notificationManager = NotificationManager()
                notificationManager.likeNotification(auther, post: postData, postHeader: postHeader!, button: self.likeButton)
            }
        })
        
    }
    
    func disLike(postData: NCMBObject){
        //いいねOFFボタン
        self.likeButton.enabled = false
        self.likeButton.setImage(likeOffImage, forState: .Normal)
        self.likeNumberButton.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
        if self.likeCounts != nil{
            //likeCountがある時（1~）
            let oldLinkCounts = Int(self.likeNumberButton.currentTitle!.stringByReplacingOccurrencesOfString("いいね", withString: ""))
            print("oldLinkCounts", oldLinkCounts)
            let newLikeCounts = oldLinkCounts! - 1
            if newLikeCounts > 0{
                //変更後のlikeCountが0より上の場合（1~）
                self.likeNumberButton.setTitle(String(newLikeCounts) + "いいね", forState: .Normal)
            }else {
                //変更後のlikeCountが0を含むそれ以下の場合(~0)
                let newLikeCounts = ""
                self.likeNumberButton.setTitle(String(newLikeCounts), forState: .Normal)
            }
        }else {
            //likeCountが今までついたことがなかった場合
            let newLikeCounts = ""
            self.likeNumberButton.setTitle(String(newLikeCounts), forState: .Normal)
        }
        postData.removeObject(NCMBUser.currentUser().objectId, forKey: "likeUser")
        postData.saveEventually ({ (error) -> Void in
            if let error = error{
                print(error.localizedDescription)
                self.likeButton.enabled = true
            }else {
                print("save成功 いいね取り消し")
                self.isLikeToggle = false
                let auther = postData.objectForKey("user") as! NCMBUser
                let notificationManager = NotificationManager()
                notificationManager.deletelikeNotification(auther, post: postData, button: self.likeButton)

            }
        })
        
    }
}
