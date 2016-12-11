//
//  AccountViewController.swift
//  masterch
//
//  Created by HIroki Taniguti on 2016/06/30.
//  Copyright © 2016年 Fumiya Yamanaka. All rights reserved.
//

import UIKit
import NCMB
import DZNEmptyDataSet
import SVProgressHUD
import TwitterKit
import TTTAttributedLabel
import Colours
import FBSDKLoginKit
import FBSDKCoreKit
import SDWebImage

class AccountViewController: UIViewController, addPostDetailDelegate{
    
    @IBOutlet weak var tableView: UITableView!
    var user: NCMBUser?
    var selectedPostObject: NCMBObject!
    var selectedPostImage: UIImage?
    var ownerUserToggle: Bool = false
    
    var postArray: NSArray = NSArray()
    
    let likeOnImage = UIImage(named: "hartON")
    let likeOffImage = UIImage(named: "hartOFF")

    var isFollowing: Bool = false
    var isTwitterConnecting: Bool = false
    var isFacebookConnecting: Bool = false
    
    var followingRelationshipObject = NCMBObject()
    
    var profileCell: ProfileCell!
    var threeCircleCell: ThreeCircleCell!
    var timelineCell: TimelineCell!
    
    var myProfileImage: UIImage?
    var myProfileHomeImage: UIImage?
    var myProfileName: String?
    var myProfileSelfintroduction: String?

    var followNumbarInt: Int = 0
    var followerNumbarInt: Int = 0

    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(AccountViewController.handleRefresh(_:)), forControlEvents: UIControlEvents.ValueChanged)

        return refreshControl
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView()
        self.tableView.addSubview(self.refreshControl)

    }

    override func viewWillAppear(animated: Bool) {


        if let user = user {
            if user.userName == NCMBUser.currentUser().userName{
                ownerUserToggle = true
                print("自分のアカウント")
                print("アカウントのユーザー名(自分)", user.userName)

            }else {
                ownerUserToggle = false
                print("他のアカウント")
                print("アカウントのユーザー名(他人)", user.userName)
            }
        }else {
            user = NCMBUser.currentUser()
            ownerUserToggle = true
            print("自分のアカウント")
            print("アカウントのユーザー名(自分)", user!.userName)
        }
        print("アカウントのユーザーネーム" ,user!.userName)
        print("currentUserのユーザーネーム", NCMBUser.currentUser().userName)
        //
        checkFollowing()
        //フォロー数、フォロワー数を取ってくる
        getFllowNumbarInt()
        getFllowerNumbarInt()
        //投稿をとってくるQUeryを投げる
        myAccountQuery()
    }

    func getFllowNumbarInt() {
        let myFllowQuery: NCMBQuery = NCMBQuery(className: "Relationship")
        myFllowQuery.whereKey("followed", equalTo: user)
        myFllowQuery.countObjectsInBackgroundWithBlock { (count , error) -> Void in
            if let error = error{
                print("error", error)
            }else {
                print(self.user,"の, フォロー数: ", count)
                self.followNumbarInt = Int(count)
            }
        }
    }

    func getFllowerNumbarInt() {
        let myFllowerQuery: NCMBQuery = NCMBQuery(className: "Relationship")
        myFllowerQuery.whereKey("follower", equalTo: user)
        myFllowerQuery.countObjectsInBackgroundWithBlock { (count , error) -> Void in
            if let error = error{
                print("error", error)
            }else {
                print(self.user,"の, フォロワー数: ", count)
                self.followerNumbarInt = Int(count)
            }
        }
    }

    func myAccountQuery () {
        let postQuery: NCMBQuery = NCMBQuery(className: "Post")
        postQuery.whereKey("user", equalTo: user)
        postQuery.orderByDescending("postDate") // cellの並べ方
        if ownerUserToggle == false { //自分じゃないアカウントの時、カギを有効にする
            postQuery.whereKey("secretKey", notEqualTo: true)
        }
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
                print("myProfileName", myProfileName)
                print("myProfileSelfintroduction", myProfileSelfintroduction)
                editProfileVC.profileImage = myProfileImage
                editProfileVC.profileHomeImage
                    = myProfileHomeImage
                editProfileVC.ProfileName = myProfileName
                editProfileVC.profileSelfIntroduction = myProfileSelfintroduction
            }
        }
        if segue.identifier == "toPostDetail" {
            let postDetailVC = segue.destinationViewController as! PostDetailViewController
            //            postDetailVC.hidesBottomBarWhenPushed = true // trueならtabBar隠す
            postDetailVC.postObject = self.selectedPostObject
            if let selectedPostImage = selectedPostImage {
                postDetailVC.postImage = selectedPostImage
            }
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
//            let logVC = segue.destinationViewController as! LogViewController
            if ownerUserToggle == true{
                logManager.sharedSingleton.logNumber = 0
            }else {
                logManager.sharedSingleton.logUser = user!
                logManager.sharedSingleton.logNumber = 2
            }
        }
        if segue.identifier == "toUserList" {
            SVProgressHUD.show()
            let relationshipQuery = NCMBQuery(className: "Relationship")
            let userListVC = segue.destinationViewController as! UserListViewController
            
            guard let sender = sender as? String else { return }
            if sender == "follow" {
                relationshipQuery.whereKey("followed", equalTo: user)
                relationshipQuery.includeKey("follower")
                relationshipQuery.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
                    if error == nil {
                        guard let relationships = objects as? [NCMBObject] else { return }
                        for relationship in relationships{
                            userListVC.userArray.append(relationship.objectForKey("follower") as! NCMBUser)
                        }
                        userListVC.userListTableView.reloadData()
                        SVProgressHUD.dismiss()
                    } else {
                        SVProgressHUD.showErrorWithStatus("読み込みに失敗しました")
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
                        SVProgressHUD.dismiss()
                    } else {
                        SVProgressHUD.showErrorWithStatus("読み込みに失敗しました")
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
extension AccountViewController: UITableViewDelegate, UITableViewDataSource, TTTAttributedLabelDelegate {

    func handleRefresh(refreshControl: UIRefreshControl) {
        myAccountQuery()
        tableView.reloadData()
        refreshControl.endRefreshing()
    }

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

            //アカウントのユーザーが自分or他人
            if ownerUserToggle == true{ //自分の時
                cell.followButton.hidden = true
                cell.settingButton.hidden = false
                cell.profileChangeButton.hidden = false
                checkConnectTwitter(user!, cell:cell)
                checkConnectFacebook(user!, cell: cell)
                cell.twitterConnectButton.hidden = false
                cell.facebookConnectButton.hidden = false
            }else {//自分じゃない時
                cell.followButton.hidden = false
                cell.settingButton.hidden = true
                cell.profileChangeButton.hidden = true
                cell.twitterConnectButton.hidden = true
                cell.facebookConnectButton.hidden = true
                //フォロー中orフォローしていない
                if checkFollowing() == true{
                    cell.followButton.setImage(UIImage(named: "followNow"), forState: UIControlState.Normal)
                    //                    cell.followButton.setTitle("フォロー中", forState: .Normal)
                }else {
                    cell.followButton.setImage(UIImage(named: "follow"), forState: UIControlState.Normal)
                    //                    cell.followButton.setTitle("フォロー", forState: .Normal)
                }
                if self.isFollowing == true{
                    cell.followButton.setImage(UIImage(named: "followNow"), forState: UIControlState.Normal)
                    //                    cell.followButton.setTitle("フォロー中", forState: .Normal)
                }else {
                    cell.followButton.setImage(UIImage(named: "follow"), forState: UIControlState.Normal)
                    //                    cell.followButton.setTitle("フォロー", forState: .Normal)
                }
            }

            cell.userIdLabel.text = "@" + user!.userName
            if let userFaceName = user!.objectForKey("userFaceName") as? String{
                cell.userProfileNameLabel.text = userFaceName
            }else {
                cell.userProfileNameLabel.text = "userName"
            }
            if let userSelfIntroduction = user!.objectForKey("userSelfIntroduction") as? String{
                cell.userSelfIntroductionTextView.text = userSelfIntroduction
            }else {
                cell.userSelfIntroductionTextView.text = "自己紹介文はまだありません"
            }
            cell.userSelfIntroductionTextView.textColor = UIColor.whiteColor()
            cell.userProfileImageView.layer.cornerRadius = cell.userProfileImageView.frame.width/2

            if let userProfileImageName = user!.objectForKey("userProfileImage") as? String{
                let userProfileImageFile = NCMBFile.fileWithName(userProfileImageName, data: nil) as! NCMBFile
                SDWebImageManager.sharedManager().imageCache.queryDiskCacheForKey(userProfileImageFile.name, done: { (image, SDImageCacheType) in
                    if let image = image {
                        cell.userProfileImageView.image = image
                    }else {
                        userProfileImageFile.getDataInBackgroundWithBlock({ (imageData: NSData?, error: NSError!) -> Void in
                            if let error = error {
                                print("profileImageの取得失敗： ", error)
                                cell.userProfileImageView.image = UIImage(named: "noprofile")
                            } else {
                                cell.userProfileImageView.image = UIImage(data: imageData!)
                                SDWebImageManager.sharedManager().imageCache.storeImage(UIImage(data: imageData!), forKey: userProfileImageFile.name)
                            }
                        })
                    }
                })
            }else {
                cell.userProfileImageView.image = UIImage(named: "noprofile")
            }

            if let userHomeImageName = user!.objectForKey("userHomeImage") as? String{
                let userHomeImageFile = NCMBFile.fileWithName(userHomeImageName, data: nil) as! NCMBFile
                SDWebImageManager.sharedManager().imageCache.queryDiskCacheForKey(userHomeImageFile.name, done: { (image, SDImageCacheType) in
                    if let image = image {
                        cell.userHomeImageView.image = image
                    }else {
                        userHomeImageFile.getDataInBackgroundWithBlock({ (imageData: NSData?, error: NSError!) -> Void in
                            if let error = error {
                                print("profileImageの取得失敗： ", error)
                                cell.userHomeImageView.image = UIImage(named: "noprofile")
                            } else {
                                cell.userHomeImageView.image = UIImage(data: imageData!)
                                SDWebImageManager.sharedManager().imageCache.storeImage(UIImage(data: imageData!), forKey: userHomeImageFile.name)
                            }
                        })
                    }
                })
            }else {
                cell.userHomeImageView.image = UIImage(named: "noprofile")
            }

            //Twiiter連携しているか？
            if isTwitterConnecting == true {
                cell.twitterConnectButton.setImage(UIImage(named: "twitterON"), forState: .Normal)
            }else {
                cell.twitterConnectButton.setImage(UIImage(named: "twitterWhite"), forState: .Normal)
            }
            //Facebook連携しているか？
            if isFacebookConnecting == true {
                cell.facebookConnectButton.setImage(UIImage(named: "facebookON"), forState: .Normal)
            }else {
                cell.facebookConnectButton.setImage(UIImage(named: "facebookWhite"), forState: .Normal)
            }
            //EditProfileVCへ渡すデータ（アカウントが自分だった時）
            if user == NCMBUser.currentUser(){
                myProfileName = cell.userProfileNameLabel.text
                myProfileSelfintroduction = cell.userSelfIntroductionTextView.text
                myProfileImage = cell.userProfileImageView.image
                myProfileHomeImage = cell.userHomeImageView.image
            }
            //            cell.layoutIfNeeded()
            return cell
            
        case 1:
            //３つボタンCell(ログ、フォロー、フォロワー)
            let cell = tableView.dequeueReusableCellWithIdentifier("ThreeCircleCell", forIndexPath: indexPath) as! ThreeCircleCell
            cell.followNumbarButton.setTitle("フォロー\n" + String(followNumbarInt), forState: .Normal)
//            if let followNumbarInt = self.followNumbarInt {
//                cell.followNumbarButton.setTitle("フォロー\n" + String(followNumbarInt), forState: .Normal)
//            }else {
//                cell.followNumbarButton.setTitle("フォロー\n" + String(""), forState: .Normal)
//            }
            cell.followNumbarButton.titleLabel?.textAlignment = NSTextAlignment.Center
            cell.followNumbarButton.titleLabel?.adjustsFontSizeToFitWidth = true

            cell.followerNumbarButton.setTitle("フォロワー\n" + String(followerNumbarInt), forState: .Normal)
//            if let followerNumbarInt = self.followerNumbarInt {
//                cell.followerNumbarButton.setTitle("フォロワー\n" + String(followerNumbarInt), forState: .Normal)
//            }else {
//                cell.followerNumbarButton.setTitle("フォロワー\n" + String(""), forState: .Normal)
//            }
            cell.followerNumbarButton.titleLabel?.textAlignment = NSTextAlignment.Center
            cell.followerNumbarButton.titleLabel?.adjustsFontSizeToFitWidth = true
            
            cell.toLogButton.layer.cornerRadius = cell.toLogButton.frame.width/2
            cell.followNumbarButton.layer.cornerRadius = cell.followNumbarButton.frame.width/2
            cell.followerNumbarButton.layer.cornerRadius = cell.followerNumbarButton.frame.width/2
            
            cell.layoutIfNeeded()
            return cell
            
        default:
            print("postArray.count", postArray.count)
            if postArray.count == 0{
                tableView.emptyDataSetSource = self
                tableView.emptyDataSetDelegate = self
            }

            //自分の投稿Cell
            let cellId = "TimelineCell"
            let cell = tableView.dequeueReusableCellWithIdentifier(cellId, forIndexPath: indexPath) as! TimelineCell

            let postData = postArray[indexPath.row - 2] as! NCMBObject
            print("postData", postData)

            //userNameLabel
            //userProfileImageView
            cell.userProfileImageView.layer.cornerRadius = cell.userProfileImageView.frame.width/2
            if let author = postData.objectForKey("user") as? NCMBUser {
                cell.userNameLabel.text = author.objectForKey("userFaceName") as? String
                if let profileImageName = author.objectForKey("userProfileImage") as? String{
                    let profileImageFile = NCMBFile.fileWithName(profileImageName, data: nil) as! NCMBFile
                    SDWebImageManager.sharedManager().imageCache.queryDiskCacheForKey(profileImageFile.name, done: { (image, SDImageCacheType) in
                        if let image = image {
                            cell.userProfileImageView.image = image
                        }else {
                            profileImageFile.getDataInBackgroundWithBlock({ (imageData: NSData?, error: NSError!) -> Void in
                                if let error = error {
                                    print("profileImageの取得失敗： ", error)
                                    cell.userProfileImageView.image = UIImage(named: "noprofile")
                                } else {
                                    cell.userProfileImageView.image = UIImage(data: imageData!)
                                    SDWebImageManager.sharedManager().imageCache.storeImage(UIImage(data: imageData!), forKey: profileImageFile.name)
                                }
                            })
                        }
                    })
                }else {
                    cell.userProfileImageView.image = UIImage(named: "noprofile")
                }
            } else {
                cell.userNameLabel.text = "username"
                cell.userProfileImageView.image = UIImage(named: "noprofile")
            }

            // postTextLabel
            // urlをリンクにする設定
            cell.postTextLabel.delegate = self
            let linkColor = ColorManager.sharedSingleton.mainColor()
            let linkActiveColor = ColorManager.sharedSingleton.mainColor().darken(0.25)
            cell.postTextLabel.linkAttributes = [kCTForegroundColorAttributeName : linkColor]
            cell.postTextLabel.activeLinkAttributes = [kCTForegroundColorAttributeName : linkActiveColor]
            cell.postTextLabel.enabledTextCheckingTypes = NSTextCheckingType.Link.rawValue
            cell.postTextLabel.text = postData.objectForKey("text") as? String
            print("投稿内容", cell.postTextLabel.text)

            // postDateLabel
            let date = postData.objectForKey("postDate") as? NSDate
            print("NSDateの内容", date)
            let postDateFormatter: NSDateFormatter = NSDateFormatter()
            postDateFormatter.dateFormat = "yyyy/MM/dd HH:mm"
            cell.postDateLabel.text = postDateFormatter.stringFromDate(date!)

            //commentButton
            cell.commentButton.addTarget(self, action: #selector(LogViewController.pushCommentButton(_:)), forControlEvents: .TouchUpInside)

            //postImageView
            cell.postImageView.image = nil
            if let postImageName = postData.objectForKey("image1") as? String {
                cell.imageViewHeightConstraint.constant = 150.0
//                cell.postImageView.layer.cornerRadius = 5.0
                let postImageFile = NCMBFile.fileWithName(postImageName, data: nil) as! NCMBFile
                SDWebImageManager.sharedManager().imageCache.queryDiskCacheForKey(postImageFile.name, done: { (image, SDImageCacheType) in
                    if let image = image {
                        cell.postImageView.image = image
                    }else {
                        postImageFile.getDataInBackgroundWithBlock({ (imageData: NSData?, error: NSError!) -> Void in
                            if let error = error {
                                print("postImageの取得失敗： ", error)
                            } else {
                                cell.postImageView.image = UIImage(data: imageData!)
                                SDWebImageManager.sharedManager().imageCache.storeImage(UIImage(data: imageData!), forKey: postImageFile.name)
                            }
                        })
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
    
    //cellをタップしもても何も反応させないため(nilだと反応しない)
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

    func attributedLabel(label: TTTAttributedLabel!, didSelectLinkWithURL url: NSURL!) {
        print(url)
        if UIApplication.sharedApplication().canOpenURL(url!){
            UIApplication.sharedApplication().openURL(url!)
        }
    }
    
    func checkFollowing() -> Bool{
        //フォロー/フォロワーが合致してたらフォローしてるってことでRelationshipクラスのインスタンスを検索
        let relationshipQuery: NCMBQuery = NCMBQuery(className: "Relationship")
        relationshipQuery.whereKey("followed", equalTo: NCMBUser.currentUser())
        relationshipQuery.whereKey("follower", equalTo: user)
        relationshipQuery.getFirstObjectInBackgroundWithBlock { (object, error) -> Void in
            guard error == nil else { return }
            if object == nil {
                print("フォローしてない")
                self.isFollowing = false
            }else{
                print("フォローしてる")
                self.followingRelationshipObject = object as NCMBObject
                self.isFollowing = true
            }
        }
        return isFollowing
    }
}

//---------------＜1行目＞プロフィールのメソッド--------------------
extension AccountViewController {
    @IBAction func tapFollowButton(sender: AnyObject) {
        let followButton = sender as! UIButton
        print("followButton押した。")
        if isFollowing == true {
            followOFFActionSheet(followButton)
//            followOFF(followButton)
        }else {
            followON(followButton)
        }
    }

    //特定のcellだけreloadかける(何行目: 0スタート, 何セクション目: このViewではわけてないので0だけ)
    func reloadOnlyCell(forRow: Int, inSection: Int){
        let indexPaths = NSIndexPath(forRow: forRow, inSection: inSection)
        tableView.reloadRowsAtIndexPaths([indexPaths], withRowAnimation: UITableViewRowAnimation.Fade)
    }
    
    func followON(followButton: UIButton){
        print("フォロー開始")
        followerNumbarInt = followerNumbarInt + 1
        followButton.setImage(UIImage(named: "followNow"), forState: UIControlState.Normal)
        followButton.enabled = false
        reloadOnlyCell(1, inSection: 0)
//        print("followingRelationshipObject", followingRelationshipObject)
        let relationObject = NCMBObject(className: "Relationship")
        relationObject.setObject(NCMBUser.currentUser(), forKey: "followed")
        relationObject.setObject(user, forKey: "follower")
        relationObject.saveEventually({ (error) -> Void in
            if let error = error {
                print("フォロー失敗")
                print(error.localizedDescription)
                let alert: UIAlertController = UIAlertController(title: "エラー",
                    message: "フォロー出来ませんでした",
                    preferredStyle:  UIAlertControllerStyle.Alert)
                let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler:{
                    // ボタンが押された時の処理を書く（クロージャ実装）
                    (action: UIAlertAction!) -> Void in
                    print("OK")
                })
                alert.addAction(defaultAction)
                self.presentViewController(alert, animated: true, completion: nil)
                self.isFollowing = false
                followButton.setImage(UIImage(named: "follow"), forState: UIControlState.Normal)
                self.followerNumbarInt = self.followerNumbarInt - 1
                followButton.enabled = true
                self.reloadOnlyCell(1, inSection: 0)
            }else {
                self.isFollowing = true
                print("フォロー成功", NCMBUser.currentUser().userName, "→", self.user!.userName)
                followButton.setImage(UIImage(named: "followNow"), forState: UIControlState.Normal)
                self.followingRelationshipObject.objectId = relationObject.objectId
                self.followingRelationshipObject = relationObject as NCMBObject
                //フォローしたことを通知画面のDBに保存
                let notificationManager = NotificationManager()
                notificationManager.followNotification(self.user!)
                followButton.enabled = true
            }
        })
    }

    func followOFFActionSheet(followButton: UIButton) {
        let alert: UIAlertController = UIAlertController(title: "@" + user!.userName,
                                                         message: nil,
                                                         preferredStyle:  UIAlertControllerStyle.ActionSheet)
        let destructiveAction: UIAlertAction = UIAlertAction(title: "フォロー解除", style: UIAlertActionStyle.Destructive, handler:{
            // ボタンが押された時の処理を書く（クロージャ実装）
            (action: UIAlertAction!) -> Void in
            print("OK")
            self.followOFF(followButton)
        })
        let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertActionStyle.Cancel, handler:{
            // ボタンが押された時の処理を書く（クロージャ実装）
            (action: UIAlertAction!) -> Void in
            print("Cancel")
        })
        alert.addAction(destructiveAction)
        alert.addAction(cancelAction)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func followOFF(followButton: UIButton){
        print("フォロー解除開始")
        followerNumbarInt = followerNumbarInt - 1
        followButton.setImage(UIImage(named: "follow"), forState: UIControlState.Normal)
        followButton.enabled = false
        reloadOnlyCell(1, inSection: 0)
        followingRelationshipObject.fetchInBackgroundWithBlock({ (error) -> Void in
            if let error = error {
                print(error.localizedDescription)
                print("フォロー解除失敗")
                let alert: UIAlertController = UIAlertController(title: "エラー",
                    message: "フォロー解除出来ませんでした",
                    preferredStyle:  UIAlertControllerStyle.Alert)
                let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler:{
                    // ボタンが押された時の処理を書く（クロージャ実装）
                    (action: UIAlertAction!) -> Void in
                    print("OK")
                })
                alert.addAction(defaultAction)
                self.presentViewController(alert, animated: true, completion: nil)
                self.isFollowing = true
                followButton.setImage(UIImage(named: "followNow"), forState: UIControlState.Normal)
                self.followerNumbarInt = self.followerNumbarInt + 1
                followButton.enabled = true
                self.reloadOnlyCell(1, inSection: 0)
            }else {
                self.followingRelationshipObject.deleteEventually({(error) in
                    if let error = error {
                        print(error.localizedDescription)
                        print("フォロー解除失敗")
                        let alert: UIAlertController = UIAlertController(title: "エラー",
                            message: "フォロー解除出来ませんでした",
                            preferredStyle:  UIAlertControllerStyle.Alert)
                        let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler:{
                            // ボタンが押された時の処理を書く（クロージャ実装）
                            (action: UIAlertAction!) -> Void in
                            print("OK")
                        })
                        alert.addAction(defaultAction)
                        self.presentViewController(alert, animated: true, completion: nil)

                        self.isFollowing = true
                        followButton.setImage(UIImage(named: "followNow"), forState: UIControlState.Normal)
                        self.followerNumbarInt = self.followerNumbarInt + 1
                        followButton.enabled = true
                        self.reloadOnlyCell(1, inSection: 0)
                    }else {
                        print("フォロー解除成功", NCMBUser.currentUser().userName, "→", self.user!.userName)
                        self.isFollowing = false
                        followButton.setImage(UIImage(named: "follow"), forState: UIControlState.Normal)
                        self.followingRelationshipObject.objectId = "dummy"
                        //フォローしたデータを通知画面のDBから削除
                        let notificationManager = NotificationManager()
                        notificationManager.deleteFollowNotification(self.user!)
                        followButton.enabled = true
                    }
                })
            }
        })
        
    }

    @IBAction func tapFeedBackButton(sender: AnyObject) {
        let feedBackUrlString = "http://goo.gl/forms/uSG7WoORa3kaxFBs2"
        toSafariBrowser(feedBackUrlString)
    }
    
    @IBAction func tapSettingButton(sender: AnyObject) {
    }
    
    @IBAction func tapProfileChangeButton(sender: AnyObject) {
        performSegueWithIdentifier("toEditProfile", sender: nil)
        
    }
    
    @IBAction func tapConnectTwitterButton(sender: AnyObject) {
        if isTwitterConnecting == true{                        deleteTwitterAccount(user!)
        }else {
            addSnsToTwitter(user!)
        }
    }
    
    @IBAction func tapConnectFacebookButton(sender: AnyObject) {
        if isFacebookConnecting == true{                        deleteFacebookAccount(user!)
        }else {
            //β版限定
//            cannotConnectFacebookAlert(user!)
            //本番まで待ち
            addSnsToFacebook(user!)
        }
    }

    func toSafariBrowser (url: String){
        let app:UIApplication = UIApplication.sharedApplication()
        app.openURL(NSURL(string: url)!)
    }

    func checkConnectTwitter(user: NCMBUser, cell: ProfileCell){
        if let twitterLink = user.objectForKey("twitterLink"){
            if twitterLink.isKindOfClass(NSNull) == false{
                print("Twitter連携済み")
                isTwitterConnecting = true
                cell.twitterConnectButton.setImage(UIImage(named: "twitterON"), forState: .Normal)
            }else {
                isTwitterConnecting = false
                cell.twitterConnectButton.setImage(UIImage(named: "twitterWhite"), forState: .Normal)
            }
        }else {
            isTwitterConnecting = false
            cell.twitterConnectButton.setImage(UIImage(named: "twitterWhite"), forState: .Normal)
        }
    }

    func addSnsToTwitter(user: NCMBUser) {
        Twitter.sharedInstance().logInWithCompletion {
            (session, error) -> Void in
            if let session = session {
                let authToken = session.authToken
                let authTokenSecret = session.authTokenSecret
                let userName = session.userName
                let userID = session.userID
                let store = Twitter.sharedInstance().sessionStore
                store.saveSessionWithAuthToken(authToken, authTokenSecret: authTokenSecret, completion: { (session, error) in
                    if let error = error {
                        print("Twitterstore保存失敗 : ", error.localizedDescription)
                    }else {
                        print("Twitterstore保存クリア!")
                        let saveSession =  ["authToken" : authToken, "authTokenSecret" : authTokenSecret, "userName" : userName, "userID" : userID]
                        user.setObject(saveSession, forKey: "twitterLink")
                        user.saveInBackgroundWithBlock({ (error) in
                            if let error = error {
                                print("NiftyデータベースへのTwitterリンクデータ保存失敗", error.localizedDescription)
                            }else {
                                print("NiftyデータベースへのTwitterリンクデータ保存クリア!")
                                self.isTwitterConnecting = true
                                //特定のcellだけreloadかける（1行目）
                                let indexPaths = NSIndexPath(forRow: 0, inSection: 0)
                                self.tableView.reloadRowsAtIndexPaths([indexPaths], withRowAnimation: UITableViewRowAnimation.Fade)
                            }
                        })
                    }
                })
            } else {
                print("Error：\(error!.localizedDescription)");
            }
        }
    }


    //Twitterアンリンク
    func deleteTwitterAccount(user: NCMBUser) {
        //「解除しますか？」アラート呼び出し
        print("userじょうほう", user)
        let alert: UIAlertController = UIAlertController(title: "このアカウントはすでにTwitterと連携しています。",
                                                         message: "連携を解除する場合は、解除するボタンを押してください",
                                                         preferredStyle:  UIAlertControllerStyle.Alert)
        // OKボタン
        let defaultAction: UIAlertAction = UIAlertAction(title: "解除する", style: UIAlertActionStyle.Default, handler:{
            // ボタンが押された時の処理を書く（クロージャ実装）
            (action: UIAlertAction!) -> Void in
            print("解除する")
            let store = Twitter.sharedInstance().sessionStore
            if let userID = store.session()?.userID {
                print(userID)
                user.removeObjectForKey("twitterLink")
                user.saveInBackgroundWithBlock({ (error) in
                    if let error = error {
                        print("twitterアンリンク失敗 : ", error.localizedDescription)
                    }else {
                        store.logOutUserID(userID)
                        print("twitterアンリンククリア！")
                        self.isTwitterConnecting = false
                        //特定のcellだけreloadかける（1行目）
                        let indexPaths = NSIndexPath(forRow: 0, inSection: 0)
                        self.tableView.reloadRowsAtIndexPaths([indexPaths], withRowAnimation: UITableViewRowAnimation.Fade)
                    }
                })
            }
        })
        // キャンセルボタン
        let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertActionStyle.Cancel, handler:{
            // ボタンが押された時の処理を書く（クロージャ実装）
            (action: UIAlertAction!) -> Void in
            print("Cancel")
        })
        alert.addAction(cancelAction)
        alert.addAction(defaultAction)
        presentViewController(alert, animated: true, completion: nil)
    }

    func checkConnectFacebook(user: NCMBUser, cell: ProfileCell){
        if let facebookLink = user.objectForKey("facebookLink"){
            if facebookLink.isKindOfClass(NSNull) == false{
                print("Twitter連携済み")
                isFacebookConnecting = true
                cell.facebookConnectButton.setImage(UIImage(named: "facebookON"), forState: .Normal)
            }else {
                isFacebookConnecting = false
                cell.facebookConnectButton.setImage(UIImage(named: "facebookWhite"), forState: .Normal)
            }
        }else {
            isFacebookConnecting = false
            cell.facebookConnectButton.setImage(UIImage(named: "facebookWhite"), forState: .Normal)
        }
    }


    func addSnsToFacebook (user: NCMBUser) {
        let loginManager: FBSDKLoginManager = FBSDKLoginManager()
        loginManager.logInWithReadPermissions(["public_profile", "email", "user_friends","user_posts"], fromViewController: self) { (result, error) in
            if (error != nil) {
                // エラーが発生した場合
                print("Process error")
            } else if result.isCancelled {
                // ログインをキャンセルした場合
                print("Cancelled")
            } else {
                // その他
                print("Login Succeeded")
                loginManager.logInWithPublishPermissions(["publish_actions"], fromViewController: self, handler: { (result, error) in
                    if (error != nil) {
                        // エラーが発生した場合
                        print("Process error")
                    } else if result.isCancelled {
                        // ログインをキャンセルした場合
                        print("Cancelled")
                        if let token = FBSDKAccessToken.currentAccessToken() {
                            let saveSession = ["uerID" : token.userID, "token" : token.tokenString, "expirationDate" : token.expirationDate]
                            user.setObject(saveSession, forKey: "facebookLink")
                            user.saveInBackgroundWithBlock({ (error) in
                                if let error = error {
                                    print("NiftyデータベースへのFacebookリンクデータ保存失敗 : ", error.localizedDescription)
                                }else {
                                    print("NiftyデータベースへのFacebookリンクデータ保存クリア!")
                                    self.isFacebookConnecting = true
                                    //特定のcellだけreloadかける（1行目）
                                    let indexPaths = NSIndexPath(forRow: 0, inSection: 0)
                                    self.tableView.reloadRowsAtIndexPaths([indexPaths], withRowAnimation: UITableViewRowAnimation.Fade)
                                }
                            })
                        }else {
                            print("currentAccessTokenがない")
                        }
                    }else {
                        print("認証成功!!!")
                        let token = FBSDKAccessToken.currentAccessToken()
                        let saveSession = ["uerID" : token.userID, "token" : token.tokenString, "expirationDate" : token.expirationDate]
                        user.setObject(saveSession, forKey: "facebookLink")
                        user.saveInBackgroundWithBlock({ (error) in
                            if let error = error {
                                print("NiftyデータベースへのFacebookリンクデータ保存失敗 : ", error.localizedDescription)
                            }else {
                                print("NiftyデータベースへのFacebookリンクデータ保存クリア!")
                                self.isFacebookConnecting = true
                                //特定のcellだけreloadかける（1行目）
                                let indexPaths = NSIndexPath(forRow: 0, inSection: 0)
                                self.tableView.reloadRowsAtIndexPaths([indexPaths], withRowAnimation: UITableViewRowAnimation.Fade)
                            }
                        })
                    }
                })
            }
        }
    }


    //Facebookアンリンク
    func deleteFacebookAccount(user: NCMBUser) {
        //「解除しますか？」アラート呼び出し
        let alert: UIAlertController = UIAlertController(title: "このアカウントはすでにFacebookと連携しています。",
                                                         message: "連携を解除する場合は、解除するボタンを押してください",
                                                         preferredStyle:  UIAlertControllerStyle.Alert)
        // OKボタン
        let defaultAction: UIAlertAction = UIAlertAction(title: "解除する", style: UIAlertActionStyle.Default, handler:{
            // ボタンが押された時の処理を書く（クロージャ実装）
            (action: UIAlertAction!) -> Void in
            print("解除する")
            let loginManager: FBSDKLoginManager = FBSDKLoginManager()
            loginManager.logOut()
                user.removeObjectForKey("facebookLink")
                user.saveInBackgroundWithBlock({ (error) in
                    if let error = error {
                        print("facebookアンリンク失敗 : ", error.localizedDescription)
                    }else {
                        print("facebookアンリンククリア！")
                        self.isFacebookConnecting = false
                        //特定のcellだけreloadかける（1行目）
                        let indexPaths = NSIndexPath(forRow: 0, inSection: 0)
                        self.tableView.reloadRowsAtIndexPaths([indexPaths], withRowAnimation: UITableViewRowAnimation.Fade)
                    }
            })
        })
        // キャンセルボタン
        let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertActionStyle.Cancel, handler:{
            // ボタンが押された時の処理を書く（クロージャ実装）
            (action: UIAlertAction!) -> Void in
            print("Cancel")
        })
        alert.addAction(cancelAction)
        alert.addAction(defaultAction)
        presentViewController(alert, animated: true, completion: nil)
    }
}




//---------------＜2行目＞ログ、フォロー、フォロワーへの遷移アクション--------------------
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
        cell.likeButton.enabled = false
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
                cell.likeButton.enabled = true
                cell.isLikeToggle = false
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
                notificationManager.likeNotification(auther, post: postData, postHeader: postHeader!, button: cell.likeButton)
            }
        })
        
    }
    
    
    func disLike(postData: NCMBObject, cell: TimelineCell) {
        //いいねOFFボタン
        cell.likeButton.enabled = false
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
                cell.isLikeToggle = true
                cell.likeButton.enabled = true
            }else {
                print("save成功 いいね取り消し")
                cell.isLikeToggle = false
                let notificationManager = NotificationManager()
                notificationManager.deletelikeNotification(auther, post: postData, button: cell.likeButton)
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

extension AccountViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate{
    //------------------DZNEmptyDataSet(セルが無い時に表示するViewの設定--------------------

    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let str = "😝その日のログはまだないよ😝"
        let attrs = [NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline), NSForegroundColorAttributeName: UIColor.whiteColor()]
        return NSAttributedString(string: str, attributes: attrs)
    }

    func descriptionForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let str = "今すぐログっちゃおう"
        let attrs = [NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleBody), NSForegroundColorAttributeName: UIColor.whiteColor()]
        return NSAttributedString(string: str, attributes: attrs)
    }

    // 写真入れるならコメント外す
    //    func imageForEmptyDataSet(scrollView: UIScrollView!) -> UIImage! {
    //        return UIImage(named: "logGood")
    //    }

    func backgroundColorForEmptyDataSet(scrollView: UIScrollView!) -> UIColor! {
        return UIColor.lightGrayColor()
    }

//    func buttonTitleForEmptyDataSet(scrollView: UIScrollView!, forState state: UIControlState) -> NSAttributedString! {
//        let str = "∨"
//        let attrs = [NSFontAttributeName: UIFont.boldSystemFontOfSize(20.0), NSForegroundColorAttributeName: UIColor.whiteColor()]
//        return NSAttributedString(string: str, attributes: attrs)
//    }

    func emptyDataSetDidTapButton(scrollView: UIScrollView!) {
        print("tapemptyDataSetButton")
    }

    func emptyDataSetShouldDisplay(scrollView: UIScrollView!) -> Bool {
        return true
    }

    func emptyDataSetShouldAllowTouch(scrollView: UIScrollView!) -> Bool {
        return false
    }

    func emptyDataSetShouldAllowScroll(scrollView: UIScrollView!) -> Bool {
        return false
    }

    func emptyDataSetShouldAnimateImageView(scrollView: UIScrollView!) -> Bool {
        return false
    }
    
}

extension AccountViewController{

    @IBAction func testConfirm(sender: AnyObject) {
        print("userInfo: ", NCMBUser.currentUser())
        let alert: UIAlertController = UIAlertController(title: NCMBUser.currentUser().userName,
                                                         message: nil,
                                                         preferredStyle:  UIAlertControllerStyle.ActionSheet)
        // OKボタン
        let defaultAction: UIAlertAction = UIAlertAction(title: "解除する", style: UIAlertActionStyle.Default, handler:{
            // ボタンが押された時の処理を書く（クロージャ実装）
            (action: UIAlertAction!) -> Void in
            print("解除する")
        })
        // キャンセルボタン
        let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertActionStyle.Cancel, handler:{
            // ボタンが押された時の処理を書く（クロージャ実装）
            (action: UIAlertAction!) -> Void in
            print("Cancel")
        })
        alert.addAction(cancelAction)
        alert.addAction(defaultAction)
        presentViewController(alert, animated: true, completion: nil)
    }
}
