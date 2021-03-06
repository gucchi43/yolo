//
//  PostDetailTableViewCell.swift
//  masterch
//
//  Created by Fumiya Yamanaka on 2016/05/30.
//  Copyright © 2016年 Fumiya Yamanaka. All rights reserved.
//

import UIKit
import NCMB
import SVProgressHUD
import TTTAttributedLabel
import IDMPhotoBrowser
import SDWebImage

protocol PostDetailTableViewCellDelegate {
    func didSelectCommentButton()
    func didSelectPostProfileImageView()
    func didSelectPostImageView(postImage: UIImage, postText: String)
    func didselectOtherButton(object : NCMBObject)
}

class PostDetailTableViewCell: UITableViewCell, TTTAttributedLabelDelegate {
    
    @IBOutlet var userProfileNameLabel: UILabel!
    @IBOutlet var userNameIDLabel: UILabel!
    @IBOutlet var userProfileImageView: UIImageView!
    @IBOutlet var postDateLabel: UILabel!
    @IBOutlet weak var postTextLabel: TTTAttributedLabel!

    @IBOutlet var postImageView: UIImageView!
    @IBOutlet weak var postImageViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var likeNumberButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    
    var auther: NCMBUser!

    var postObject: NCMBObject!
    var likeCounts: Int?
    var postImage: UIImage?

    let likeOnImage = UIImage(named: "hartON")
    let likeOffImage = UIImage(named: "hartOFF")
    
    var isLikeToggle = false
    var postImageloardToggle = true
    
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
        print("postObject", postObject)
    
        //userNameLabel
        //userProfileImageView
        userProfileImageView.layer.cornerRadius = userProfileImageView.frame.width/2
        let gestureUserProfileImage = UITapGestureRecognizer(target: self, action: #selector(PostDetailTableViewCell.tapUserProfileImage(_:)))
        userProfileImageView.addGestureRecognizer(gestureUserProfileImage)
        if let auther = postObject.objectForKey("user") as? NCMBUser {
            userProfileNameLabel.text = auther.objectForKey("userFaceName") as? String
            userNameIDLabel.text = "@" + auther.userName
            if let userImageName = auther.objectForKey("userProfileImage") as? String {
                let userImageFile = NCMBFile.fileWithName(userImageName, data: nil) as! NCMBFile
                SDWebImageManager.sharedManager().imageCache.queryDiskCacheForKey(userImageFile.name, done: { (image, SDImageCacheType) in
                    if let image = image {
                        self.userProfileImageView.image = image
                    }else {
                        userImageFile.getDataInBackgroundWithBlock({ (imageData, error) in
                            if let error = error {
                                print("プロフィール画像の取得失敗： ", error)
                                self.userProfileImageView.image = UIImage(named: "noprofile")
                            }else {
                                self.userProfileImageView.image = UIImage(data: imageData!)
                                SDWebImageManager.sharedManager().imageCache.storeImage(UIImage(data: imageData!), forKey: userImageFile.name)
                            }
                        })
                    }
                })
            }else {
                self.userProfileImageView.image = UIImage(named: "noprofile")
            }
        } else {
            userNameIDLabel.text = "username"
            userProfileImageView.image = UIImage(named: "noprofile")
        }

        // postTextLabel
        // urlをリンクにする設定
        postTextLabel.delegate = self
        let linkColor = ColorManager.sharedSingleton.mainColor()
        let linkActiveColor = ColorManager.sharedSingleton.mainColor().darken(0.25)
        postTextLabel.linkAttributes = [kCTForegroundColorAttributeName : linkColor]
        postTextLabel.activeLinkAttributes = [kCTForegroundColorAttributeName : linkActiveColor]
        postTextLabel.enabledTextCheckingTypes = NSTextCheckingType.Link.rawValue
        postTextLabel.text = postObject.objectForKey("text") as? String

        // postDateLabel
        let date = postObject.objectForKey("postDate") as? NSDate
        let postDateFormatter: NSDateFormatter = NSDateFormatter()
        postDateFormatter.dateFormat = "yyyy MM/dd HH:mm"
        postDateLabel.text = postDateFormatter.stringFromDate(date!)
        
        // postImageView
        let gesturePostImage = UITapGestureRecognizer(target: self, action: #selector(PostDetailTableViewCell.tapPostImage(_:)))
        postImageView.addGestureRecognizer(gesturePostImage)
        postImageView.contentMode = UIViewContentMode.ScaleAspectFill
            if let postImageName = postObject.objectForKey("image1") as? String {
                self.postImageViewHeightConstraint.constant = (UIScreen.mainScreen().bounds.size.width - 20)
                let postImageFile = NCMBFile.fileWithName(postImageName, data: nil) as! NCMBFile
                SDWebImageManager.sharedManager().imageCache.queryDiskCacheForKey(postImageFile.name, done: { (image, SDImageCacheType) in
                    if let image = image {
                        self.postImageView.image = image
                        self.postImageloardToggle = true
                    }else {
                    postImageFile.getDataInBackgroundWithBlock({ (imageData: NSData?, error: NSError!) -> Void in
                            if let error = error {
                                print("postImageの取得失敗： ", error)
                                //                    SVProgressHUD.showErrorWithStatus("読み込みに失敗しました")
                                self.postImageView.image = UIImage(named: "pleaseReload")
                                self.postImageloardToggle = false
                            } else {
                                print(UIImage(data: imageData!))
                                //                    SVProgressHUD.dismiss()
                                self.postImageViewHeightConstraint.constant = (UIScreen.mainScreen().bounds.size.width - 20)
                                self.postImageView.image = UIImage(data: imageData!)
                                SDWebImageManager.sharedManager().imageCache.storeImage(UIImage(data: imageData!), forKey: postImageFile.name)
                                self.postImageloardToggle = true
                            }
                            }, progressBlock: { (progress) in
                                //                    SVProgressHUD.showProgress(Float(progress)/100, status: "画像読み込み中")
                                print("postImage進行速度 %: ", Float(progress)/100)
                                
                        })
                    }
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

    // urlリンクをタップされたときの処理を記述します
    func attributedLabel(label: TTTAttributedLabel!, didSelectLinkWithURL url: NSURL!)
    {
        print(url)
        if UIApplication.sharedApplication().canOpenURL(url!){
            UIApplication.sharedApplication().openURL(url!)
        }
    }

}




//写真タップ
extension PostDetailTableViewCell: IDMPhotoBrowserDelegate  {
    //ユーザー写真タップ
    func tapUserProfileImage (recoginizer: UITapGestureRecognizer){
        print("写真押された")
        delegate.didSelectPostProfileImageView()
    }

    //投稿写真タップ
    func tapPostImage(recoginizer: UITapGestureRecognizer) {
        print("tapPostImage")
        if let postImage = postImageView.image{
            if postImageloardToggle == false { //画像の読み込みがまだの時
                postImageView.image = nil
                if let postImageName = postObject.objectForKey("image1") as? String {
                    self.postImageViewHeightConstraint.constant = (UIScreen.mainScreen().bounds.size.width - 20)

                    let postImageFile = NCMBFile.fileWithName(postImageName, data: nil) as! NCMBFile
                    postImageFile.getDataInBackgroundWithBlock({ (imageData: NSData?, error: NSError!) -> Void in
                        if let error = error {
                            print("写真の取得失敗： ", error)
                            //                    SVProgressHUD.showErrorWithStatus("読み込みに失敗しました")
                            self.postImageView.image = UIImage(named: "pleaseReload")
                            self.postImageloardToggle = false
                        } else {
                            print(UIImage(data: imageData!))
                            //                    SVProgressHUD.dismiss()
                            self.postImageViewHeightConstraint.constant = (UIScreen.mainScreen().bounds.size.width - 20)
                            self.postImageView.image = UIImage(data: imageData!)
                            self.postImageloardToggle = true
                            SDWebImageManager.sharedManager().imageCache.storeImage(UIImage(data: imageData!), forKey: postImageFile.name)
                        }
                        }, progressBlock: { (progress) in
                            //                    SVProgressHUD.showProgress(Float(progress)/100, status: "画像読み込み中")
                            print("postImage進行速度 %: ", Float(progress)/100)
                    })
                } else {
                    self.postImageView.image = nil
                    self.postImageViewHeightConstraint.constant = 0.0
                }
            }else { //画像が読み込まれている時
                delegate.didSelectPostImageView(postImage, postText: postTextLabel.text!)
            }
        }
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

//その他ボタン機能(削除・編集)
extension PostDetailTableViewCell {



    @IBAction func tapOtherButton(sender: AnyObject) {

        delegate.didselectOtherButton(postObject)

//        let alert: UIAlertController = UIAlertController(title: "title",
//                                                         message: "message？⚠️",
//                                                         preferredStyle:  UIAlertControllerStyle.ActionSheet)
//        // OKボタン
//        let defaultAction: UIAlertAction = UIAlertAction(title: "削除", style: UIAlertActionStyle.Default, handler:{
//            // ボタンが押された時の処理を書く（クロージャ実装）
//            (action: UIAlertAction!) -> Void in
//            print("削除")
//        })
//        // キャンセルボタン
//        let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertActionStyle.Cancel, handler:{
//            // ボタンが押された時の処理を書く（クロージャ実装）
//            (action: UIAlertAction!) -> Void in
//            print("Cancel")
//        })
//        alert.addAction(cancelAction)
//        alert.addAction(defaultAction)
//        let postDetileViewController = PostDetailViewController()
//        postDetileViewController.presentViewController(alert, animated: true, completion: nil)
//        presentViewController(alert, animated: true, completion: nil)
    }

//    func deleteAlert() {
//        //「本当に削除しますか？」アラート呼び出し
//        let alert: UIAlertController = UIAlertController(title: "ログを削除",
//                                                         message: "本当にこのログを削除しますか？⚠️",
//                                                         preferredStyle:  UIAlertControllerStyle.Alert)
//        // OKボタン
//        let defaultAction: UIAlertAction = UIAlertAction(title: "削除", style: UIAlertActionStyle.Default, handler:{
//            // ボタンが押された時の処理を書く（クロージャ実装）
//            (action: UIAlertAction!) -> Void in
//            print("削除")
//        })
//        // キャンセルボタン
//        let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertActionStyle.Cancel, handler:{
//            // ボタンが押された時の処理を書く（クロージャ実装）
//            (action: UIAlertAction!) -> Void in
//            print("Cancel")
//        })
//        alert.addAction(cancelAction)
//        alert.addAction(defaultAction)
//        let postDetileViewController = PostDetailViewController()
//        postDetileViewController.presentViewController(alert, animated: true, completion: nil)
//    }
//
//    func deletePost(object : NCMBObject) {
//        print("削除する投稿内容", object)
//        object.deleteEventually { (error) in
//            if let error = error {
//                print(error.localizedDescription)
//            }else {
//                let postDetileViewController = PostDetailViewController()
//                postDetileViewController.postDetailTableView.reloadData()
//            }
//        }
//    }
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
                self.isLikeToggle = false
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
                self.isLikeToggle = true
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
