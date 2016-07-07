//
//  AccountViewController.swift
//  masterch
//
//  Created by HIroki Taniguti on 2016/06/30.
//  Copyright © 2016年 Fumiya Yamanaka. All rights reserved.
//

import UIKit
import DZNEmptyDataSet
import SVProgressHUD

class AccountViewController: UIViewController, addPostDetailDelegate,DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {

    @IBOutlet weak var tableView: UITableView!
    var user: NCMBUser?
    var selectedPostObject: NCMBObject!

    var postArray: NSArray = NSArray()

    let likeOnImage = UIImage(named: "hartButton_On")
    let likeOffImage = UIImage(named: "hartButton_Off")

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableViewAutomaticDimension
    }

    override func viewWillAppear(animated: Bool) {
        if let user = user{
            print("OtherAccountみたいなはず")
            print("アカウントのユーザー名(自分じゃないはず)", user.userName)
        }else {
            user = NCMBUser.currentUser()!
            print("OtherAccountみたいなはず")
            print("アカウントのユーザー名(自分じゃないはず)", user!.userName)
        }
        //自分の投稿をとってくるQUeryを投げる
        myAccountQuery()
    }

    func myAccountQuery () {
        let postQuery: NCMBQuery = NCMBQuery(className: "Post")
        postQuery.whereKey("user", equalTo: user)
        postQuery.orderByDescending("postDate") // cellの並べ方
        postQuery.limit = 20
        postQuery.includeKey("user")
        loadQuery(postQuery)
    }

    func loadQuery(postQuery: NCMBQuery) {
        postQuery.findObjectsInBackgroundWithBlock { (objects, error) in
            if let error = error {
                print("error", error.localizedDescription)
            } else {
                print("投稿数", objects.count)
                if objects.count > 0 {
                    self.postArray = objects
                    self.tableView.emptyDataSetSource = nil
                    self.tableView.emptyDataSetDelegate = nil
                } else {
                    self.postArray = []
                    self.tableView.emptyDataSetSource = self
                    self.tableView.emptyDataSetDelegate = self
                }
                self.tableView.reloadData()
            }
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var destination = segue.destinationViewController as UIViewController
        if let naviC = destination as? UINavigationController {
            destination = naviC.visibleViewController!
        }
        if let editProfileVC = destination as? EditProfileTableViewController {
            if segue.identifier == "toEditProfile" {
                editProfileVC.user = user
            }
        }
        if segue.identifier == "toPostDetail" {
            let postDetailVC = segue.destinationViewController as! PostDetailViewController
            //            postDetailVC.hidesBottomBarWhenPushed = true // trueならtabBar隠す
            postDetailVC.postObject = self.selectedPostObject
            postDetailVC.delegate = self
            if let sender = sender {
                postDetailVC.isSelectedCommentButton = sender as! Bool
            }
        }
        if segue.identifier == "toSubmit" {
            let submitVC = segue.destinationViewController as! SubmitViewController
            print("これはどうなる")
            submitVC.postDate = CalendarManager.currentDate
        }
        if segue.identifier == "toLog" {
            let logVC = segue.destinationViewController as! LogViewController
//            logVC.user = user!
//                        let calendarMonthVC = UIViewController as! CalendarMonthView
            if user! == NCMBUser.currentUser(){
//                logManager.sharedSingleton.logUser = user!
                logManager.sharedSingleton.logNumber = 0
            }else {
                logManager.sharedSingleton.logUser = user!
                logManager.sharedSingleton.logNumber = 2
            }
//            logVC.userName = user!.objectForKey("userFaceName") as? String
        }
        if segue.identifier == "toUserList" {
            let relationshipQuery = NCMBQuery(className: "Relationship")
            let userListVC = segue.destinationViewController as! UserListViewController

            guard let sender = sender as? String else { return }
            if sender == "follow" {
                relationshipQuery.whereKey("followed", equalTo: user)
                relationshipQuery.includeKey("follower")
                relationshipQuery.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
                    if error == nil {
                        guard let relationships = objects as? [NCMBObject] else { return }
                        for relationship in relationships {                            userListVC.userArray.append(relationship.objectForKey("follower") as! NCMBUser)
                        }
                        userListVC.userListTableView.reloadData()
                    }
                }
            } else if sender == "follower" {
                relationshipQuery.whereKey("follower", equalTo: user)
                relationshipQuery.includeKey("followed")
                relationshipQuery.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
                    if error == nil {
                        guard let relationships = objects as? [NCMBObject] else { return }
                        for relationship in relationships {
                            userListVC.userArray.append(relationship.objectForKey("followed") as! NCMBUser)
                        }
                        userListVC.userListTableView.reloadData()
                    }
                }
            }
        }
    }

    //投稿画面から戻った時にリロード
    func postDetailDismissionAction() {
        print("postDetailDismissionAction")
        tableView.reloadData()
    }
}


//---------------tableViewの生成やらあれこれ-------------------------
extension AccountViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postArray.count + 2
    }

    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }


    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            //プロフィールCell
            let cell = tableView.dequeueReusableCellWithIdentifier("ProfileCell", forIndexPath: indexPath) as! ProfileCell


            //ユーザーネームを表示
            cell.userProfileNameLabel.text = user!.objectForKey("userFaceName") as? String
            cell.userIdLabel.text = "@" + user!.userName
            cell.userSelfIntroductionTextView.text = user!.objectForKey("userSelfIntroduction") as? String
            cell.userSelfIntroductionTextView.textColor = UIColor.whiteColor()

            //プロフィール写真の形を円形にする
            cell.userProfileImageView.layer.cornerRadius = cell.userProfileImageView.frame.width/2

            //プロフィール写真を表示
            let userProfileImageName = (user!.objectForKey("userProfileImage") as? String)!
            let userProfileImageData = NCMBFile.fileWithName(userProfileImageName, data: nil) as! NCMBFile

            userProfileImageData.getDataInBackgroundWithBlock { (imageData: NSData?, error: NSError!) -> Void in
                if error != nil{
                    print("写真の取得失敗: \(error)")
                } else {
                    cell.userProfileImageView.image = UIImage(data: imageData!)
                }
            }

            //ホーム写真を表示
            let userHomeImageName = (user!.objectForKey("userHomeImage") as? String)!
            let userHomeImageData = NCMBFile.fileWithName(userHomeImageName, data: nil) as! NCMBFile

            userHomeImageData.getDataInBackgroundWithBlock { (imageData: NSData?, error: NSError!) -> Void in
                if error != nil{
                    print("写真の取得失敗: \(error)")
                } else {
                    cell.userHomeImageView.image = UIImage(data: imageData!)
                }
            }
//            cell.layoutIfNeeded()
            return cell

        case 1:
            //３つボタンCell(ログ、フォロー、フォロワー)
            let cell = tableView.dequeueReusableCellWithIdentifier("ThreeCircleCell", forIndexPath: indexPath) as! ThreeCircleCell

            getFllowNumber(cell)
            getFllowerNumbar(cell)

            cell.toLogButton.layer.cornerRadius = cell.toLogButton.frame.width/2
            cell.followNumbarButton.layer.cornerRadius = cell.followNumbarButton.frame.width/2
            cell.followerNumbarButton.layer.cornerRadius = cell.followerNumbarButton.frame.width/2

            cell.layoutIfNeeded()
            return cell

        default:
            //自分の投稿Cell
            let cell = tableView.dequeueReusableCellWithIdentifier("TimelineCell", forIndexPath: indexPath) as! TimelineCell
            //ImageViewの初期化的な
            cell.userProfileImageView.image = UIImage(named: "noprofile")
            cell.postImageView.image = nil

            // 各値をセルに入れる
            let postData = postArray[indexPath.row - 2]
            print("postData", postData)
            // postTextLabelには(key: "text")の値を入れる
            cell.postTextLabel.text = postData.objectForKey("text") as? String
            print("投稿内容", cell.postTextLabel.text)
            // postDateLabelには(key: "postDate")の値を、NSDateからstringに変換して入れる
            let date = postData.objectForKey("postDate") as? NSDate
            print("NSDateの内容", date)
            let postDateFormatter: NSDateFormatter = NSDateFormatter()
            postDateFormatter.dateFormat = "yyyy/MM/dd HH:mm"
            cell.postDateLabel.text = postDateFormatter.stringFromDate(date!)

            cell.commentButton.addTarget(self, action: #selector(LogViewController.pushCommentButton(_:)), forControlEvents: .TouchUpInside)

            //プロフィール写真の形を円形にする
            cell.userProfileImageView.layer.cornerRadius = cell.userProfileImageView.frame.width/2

            let author = postData.objectForKey("user") as? NCMBUser
            if let author = author {
                cell.userNameLabel.text = author.objectForKey("userFaceName") as? String

                let postImageData = NCMBFile.fileWithName(author.objectForKey("userProfileImage") as? String, data: nil) as! NCMBFile
                postImageData.getDataInBackgroundWithBlock({ (imageData: NSData?, error: NSError!) -> Void in
                    if let error = error {
                        print("プロフィール画像の取得失敗： ", error)
                        cell.userProfileImageView.image = UIImage(named: "noprofile")
                    } else {
                        cell.userProfileImageView.image = UIImage(data: imageData!)

                    }
                })
            } else {
                cell.userNameLabel.text = "username"
                cell.userProfileImageView.image = UIImage(named: "noprofile")
            }

            //画像データの取得
            if let postImageName = postData.objectForKey("image1") as? String {
                cell.imageViewHeightConstraint.constant = 150.0
                let postImageData = NCMBFile.fileWithName(postImageName, data: nil) as! NCMBFile
                postImageData.getDataInBackgroundWithBlock({ (imageData: NSData?, error: NSError!) -> Void in
                    if let error = error {
                        print("写真の取得失敗： ", error)
                    } else {
                        cell.postImageView.image = UIImage(data: imageData!)
                        cell.postImageView.layer.cornerRadius = 5.0
                    }
                })
            } else {
                cell.postImageView.image = nil
                cell.imageViewHeightConstraint.constant = 0.0
            }

            //いいね
            if postData.objectForKey("likeUser") != nil{
                //今までで、消されたかもだけど、必ずいいねされたことはある
                let postLikeUserString = postData.objectForKey("likeUser")
                //StringをNSArrayに変換
                let postLikeUserArray = postLikeUserString as! NSArray
                let postLikeUserCount = postLikeUserArray.count
                if postLikeUserCount > 0 {
                    //いいねをしたユーザーが１人以上いる
                    cell.likeCounts = postLikeUserCount
                    if postLikeUserArray.containsObject(NCMBUser.currentUser().objectId) == true{
                        //自分がいいねしている
                        print("私はすでにいいねをおしている")
                        cell.likeButton.setImage(likeOnImage, forState: .Normal)
                        cell.likeNumberButton.setTitle(String(cell.likeCounts!), forState: .Normal)
                        cell.isLikeToggle = true
                    }else{
                        //いいねはあるけど、自分がいいねしていない
                        cell.likeButton.setImage(likeOffImage, forState: .Normal)
                        cell.likeNumberButton.setTitle(String(cell.likeCounts!), forState: .Normal)
                    }
                }else{
                    //いいねしたユーザーはいない
                    cell.likeButton.setImage(likeOffImage, forState: .Normal)
                    cell.likeNumberButton.setTitle("", forState: .Normal)
                }
            }else{
                //今まで一度もいいねされたことはない
                cell.likeButton.setImage(likeOffImage, forState: .Normal)
                cell.likeNumberButton.setTitle("", forState: .Normal)
            }
            cell.layoutIfNeeded()
            return cell
        }
    }
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        switch indexPath.row {
        case 0:
            //Profileのcell
            return nil
        case 1:
            //ThreeCircleのCell
            return nil
        default:
            return indexPath
        }
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("セルの選択: \(indexPath.row)")
        selectedPostObject = self.postArray[indexPath.row - 2] as! NCMBObject
        performSegueWithIdentifier("toPostDetail", sender: nil)
    }

    func getFllowNumber(cell: ThreeCircleCell) {
        let myFllowQuery: NCMBQuery = NCMBQuery(className: "Relationship")
        myFllowQuery.whereKey("followed", equalTo: user)
        myFllowQuery.countObjectsInBackgroundWithBlock { (count , error) -> Void in
            if let error = error{
                print("error", error)
            }else {
                print(self.user,"の, フォロー数: ", count)
                cell.followNumbarButton.setTitle("フォロー\n" + String(count), forState: .Normal)
                cell.followNumbarButton.titleLabel?.textAlignment = NSTextAlignment.Center
                cell.followNumbarButton.titleLabel?.adjustsFontSizeToFitWidth = true

            }
        }
    }

    func getFllowerNumbar(cell: ThreeCircleCell) {
        let myFllowerQuery: NCMBQuery = NCMBQuery(className: "Relationship")
        myFllowerQuery.whereKey("follower", equalTo: user)
        myFllowerQuery.countObjectsInBackgroundWithBlock { (count , error) -> Void in
            if let error = error{
                print("error", error)
            }else {
                print(self.user,"の, フォロワー数: ", count)
                cell.followerNumbarButton.setTitle("フォロワー\n" + String(count), forState: .Normal)
                cell.followerNumbarButton.titleLabel?.textAlignment = NSTextAlignment.Center
                cell.followerNumbarButton.titleLabel?.adjustsFontSizeToFitWidth = true
            }
        }
    }
}

//---------------＜2行目以降＞ログ、フォロー、フォロワーへの遷移アクション--------------------
extension AccountViewController {

    @IBAction func pushToLogButton(sender: AnyObject) {
        performSegueWithIdentifier("toLog", sender: nil)
    }

    @IBAction func pushFollowNumbarButton(sender: AnyObject) {
        performSegueWithIdentifier("toUserList", sender: "follow")
    }

    @IBAction func pushFollowerNumbarButton(sender: AnyObject) {
        performSegueWithIdentifier("toUserList", sender: "follower")
    }
}


//---------------＜3行目以降＞自分の投稿へのアクション（いいね)--------------------
extension AccountViewController {
    @IBAction func pushLikeButton(sender: AnyObject) {
        print("LIKEボタン押した")
        let button = sender as! UIButton
        let cell = button.superview?.superview as! TimelineCell
        print("投稿内容", cell.postTextLabel.text)
        let row = tableView.indexPathForCell(cell)?.row
        let postData = postArray[row! - 2] as! NCMBObject

        //いいねアクション実行
        if cell.isLikeToggle == true{
            disLike(postData, cell: cell)
        } else {
            like(postData, cell: cell)
        }
    }

    func like(postData: NCMBObject, cell: TimelineCell) {
        //いいねONボタン
        cell.likeButton.setImage(likeOnImage, forState: .Normal)

        if cell.likeCounts != nil{
            //likeCountが追加で変更される時（2回目以降）
            if let oldLinkCounts = Int(cell.likeNumberButton.currentTitle!){
                print("oldLinkCounts", oldLinkCounts)
                //普通にいいねを１追加（2~）
                let newLikeCounts = oldLinkCounts + 1
                cell.likeNumberButton.setTitle(String(newLikeCounts), forState: .Normal)
            }else {
                //oldCountがない場合（以前いいねされたけど、削除されて0になってlikeCountがnullの場合）
                let newLikeCounts = 1
                cell.likeNumberButton.setTitle(String(newLikeCounts), forState: .Normal)
            }
        }else{
            //likeCountが初めて変更される時
            let newLikeCounts = 1
            cell.likeNumberButton.setTitle(String(newLikeCounts), forState: .Normal)
        }
        postData.addUniqueObject(NCMBUser.currentUser().objectId, forKey: "likeUser")
        postData.saveEventually ({ (error) -> Void in
            if let error = error{
                print(error.localizedDescription)
            }else {
                print("save成功 いいね保存")
                cell.isLikeToggle = true
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
                notificationManager.likeNotification(auther, post: postData, postHeader: postHeader!)
            }
        })

    }


    func disLike(postData: NCMBObject, cell: TimelineCell) {
        //いいねOFFボタン
        cell.likeButton.setImage(likeOffImage, forState: .Normal)
        cell.likeNumberButton.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)

        if cell.likeCounts != nil{
            //likeCountがある時（1~）
            let oldLinkCounts = Int(cell.likeNumberButton.currentTitle!)
            print("oldLinkCounts", oldLinkCounts)
            let newLikeCounts = oldLinkCounts! - 1
            if newLikeCounts > 0{
                //変更後のlikeCountが0より上の場合（1~）
                cell.likeNumberButton.setTitle(String(newLikeCounts), forState: .Normal)
            }else {
                //変更後のlikeCountが0を含むそれ以下の場合(~0)
                let newLikeCounts = ""
                cell.likeNumberButton.setTitle(String(newLikeCounts), forState: .Normal)
            }
        }else {
            //likeCountが今までついたことがなかった場合
            let newLikeCounts = ""
            cell.likeNumberButton.setTitle(String(newLikeCounts), forState: .Normal)
        }

        let auther = postData.objectForKey("user") as! NCMBUser
        postData.removeObject(NCMBUser.currentUser().objectId, forKey: "likeUser")
        postData.saveEventually ({ (error) -> Void in
            if let error = error{
                print(error.localizedDescription)
            }else {
                print("save成功 いいね取り消し")
                cell.isLikeToggle = false
                let notificationManager = NotificationManager()
                notificationManager.deletelikeNotification(auther, post: postData)
            }
        })

    }
}


//---------------＜3行目以降＞自分の投稿へのアクション（コメント)--------------------
extension AccountViewController {
    @IBAction func pushCommentButton(sender: AnyObject) {
        // 押されたボタンを取得
        let cell = sender.superview?!.superview as! TimelineCell
        let row = tableView.indexPathForCell(cell)?.row
        selectedPostObject = self.postArray[row! - 2] as! NCMBObject

        performSegueWithIdentifier("toPostDetail", sender: true)
    }
    
}
