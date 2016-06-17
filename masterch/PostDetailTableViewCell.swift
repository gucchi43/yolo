//
//  PostDetailTableViewCell.swift
//  masterch
//
//  Created by Fumiya Yamanaka on 2016/05/30.
//  Copyright © 2016年 Fumiya Yamanaka. All rights reserved.
//

import UIKit

protocol PostDetailTableViewCellDelegate {
    func didSelectCommentButton()
    func didSelectPostProfileImageView()
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
    var isLikeToggle: Bool = false
    var likeCounts: Int?

    let likeOnImage = UIImage(named: "hartButton_On")
    let likeOffImage = UIImage(named: "hartButton_Off")
    
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
    
        if let author = postObject.objectForKey("user") as? NCMBUser {
            userProfileNameLabel.text = author.objectForKey("userFaceName") as? String
            userNameIDLabel.text = "@" + author.userName
            
            //プロフィール写真の形を円形にする
            userProfileImageView.layer.cornerRadius = userProfileImageView.frame.width/2
            let gesture = UITapGestureRecognizer(target: self, action: #selector(PostDetailTableViewCell.tapImageView(_:)))
            userProfileImageView.addGestureRecognizer(gesture)
            
            let userImageData = NCMBFile.fileWithName(author.objectForKey("userProfileImage") as? String, data: nil) as! NCMBFile
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
        if let postImageName = postObject.objectForKey("image1") as? String {
            self.postImageViewHeightConstraint.constant = 300
            
            let postImageData = NCMBFile.fileWithName(postImageName, data: nil) as! NCMBFile
            postImageData.getDataInBackgroundWithBlock({ (imageData: NSData?, error: NSError!) -> Void in
                if let error = error {
                    print("写真の取得失敗： ", error)
                    self.postImageView.image = nil
                    self.postImageViewHeightConstraint.constant = 0.0
                } else {
                    print(UIImage(data: imageData!))
                    let imageHeight = UIImage(data: imageData!)!.size.height
                    self.postImageViewHeightConstraint.constant = 300
                    self.postImageView.image = UIImage(data: imageData!)
                }
            })
        } else {
            self.postImageView.image = nil
            self.postImageViewHeightConstraint.constant = 0.0
        }
        
        if postObject.objectForKey("likeUser") != nil{//一度もいいねが来たことがないかも 分岐
            let postLikeUserString = postObject.objectForKey("likeUser")
            let cleanLikeUserString = String(postLikeUserString!).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            let superCleanLinkUserString = cleanLikeUserString.stringByReplacingOccurrencesOfString("(\n)", withString: "")
            print("superCleanLinkUserString", superCleanLinkUserString)
            if superCleanLinkUserString.isEmpty == false{//いいねを取り消されて空かも 分岐
                let postLikeUserArray = superCleanLinkUserString.componentsSeparatedByString(",")
                print("postLikeUserArray", postLikeUserArray)
                let postLikeUserCount = postLikeUserArray.count
                print("postLikeUserCount", postLikeUserCount)
                self.likeCounts = postLikeUserCount
                self.likeNumberButton.setTitle(String(self.likeCounts!) + "いいね", forState: .Normal)
                for i in postLikeUserArray{
                    if i.rangeOfString(NCMBUser.currentUser().objectId) != nil{//自分がいいねしている
                        print("私はすでにいいねをおしている")
                        self.likeButton.setImage(likeOnImage, forState: .Normal)
                        self.likeNumberButton.setTitleColor(UIColor.redColor(), forState: .Normal)
                        self.isLikeToggle = true
                    }
                }
            }else {//いいねを取り消されて「空」状態
                self.likeButton.setImage(likeOffImage, forState: .Normal)
                self.likeNumberButton.setTitle("", forState: .Normal)
            }
        }else{//一度もいいねが来たことがない
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
extension PostDetailTableViewCell {
    func tapImageView (recoginizer: UITapGestureRecognizer){
        print("写真押された")
        delegate.didSelectPostProfileImageView()
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
        changeLikeStatus(postData)
        
    }
    
    func changeLikeStatus(postData: NCMBObject){
        if self.isLikeToggle == false {//いいねしてない時→いいね
            self.likeButton.setImage(likeOnImage, forState: .Normal)
            
            if let likeCounts = self.likeCounts{//likeCountが追加で変更される時（2回目以降）
                if let oldLinkCounts = Int(self.likeNumberButton.currentTitle!.stringByReplacingOccurrencesOfString("いいね", withString: "")){
                    let newLikeCounts = oldLinkCounts + 1
                    self.likeNumberButton.setTitle(String(newLikeCounts) + "いいね", forState: .Normal)
                    self.likeNumberButton.setTitleColor(UIColor.redColor(), forState: .Normal)
                }else {//oldCountがない場合（初めてのいいねじゃないけど、いいね１になる場合）
                    let newLikeCounts = 1
                    self.likeNumberButton.setTitle(String(newLikeCounts), forState: .Normal)
                    self.likeNumberButton.setTitleColor(UIColor.redColor(), forState: .Normal)
                }
            }else{//likeCountが初めて変更される時
                let newLikeCounts = 1
                self.likeNumberButton.setTitle(String(newLikeCounts) + "いいね", forState: .Normal)
                self.likeNumberButton.setTitleColor(UIColor.redColor(), forState: .Normal)
            }
            
            self.isLikeToggle = true
            
            postData.addUniqueObject(NCMBUser.currentUser().objectId, forKey: "likeUser")
            postData.saveInBackgroundWithBlock({ (error) -> Void in
                if let error = error{
                    print(error.localizedDescription)
                }else {
                    print("save成功 いいね保存")
                    //いいねしたことを通知画面のDBに保存
                    let notificationManager = NotificationManager()
                    notificationManager.likeNotification(self.auther, post: postData)
                }
            })
            
            
        }else {//いいねしている時
            self.likeButton.setImage(likeOffImage, forState: .Normal)
            
            if let likeCounts = self.likeCounts{
                let oldLinkCounts = Int(self.likeNumberButton.currentTitle!.stringByReplacingOccurrencesOfString("いいね", withString: ""))
                let newLikeCounts = oldLinkCounts! - 1
                if newLikeCounts > 0{//変更後のlikeCountが0より上の場合（1~）
                    let newLikeCounts = ""
                    self.likeNumberButton.setTitle(String(newLikeCounts), forState: .Normal)
                    self.likeNumberButton.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
                }else {//変更後のlikeCountが0を含むそれ以下の場合(~0)
                    self.likeNumberButton.setTitle(String(newLikeCounts) + "いいね", forState: .Normal)
                    self.likeNumberButton.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
                }
            }else{//likeCountが今までついたことがなかった場合
                let newLikeCounts = ""
                self.likeNumberButton.setTitle(String(newLikeCounts), forState: .Normal)
                self.likeNumberButton.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
            }
            
            self.isLikeToggle = false
            
            postData.removeObject(NCMBUser.currentUser().objectId, forKey: "likeUser")
            postData.saveInBackgroundWithBlock({ (error) -> Void in
                if let error = error{
                    print(error.localizedDescription)
                }else {
                    print("save成功 いいね取り消し")
                }
            })
            
        }
    }
}
