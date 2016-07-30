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
import TwitterKit

class AccountViewController: UIViewController, addPostDetailDelegate{
    
    @IBOutlet weak var tableView: UITableView!
    var user: NCMBUser?
    var selectedPostObject: NCMBObject!
    
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

    var followNumbarInt: Int?
    var followerNumbarInt: Int?

    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "handleRefresh:", forControlEvents: UIControlEvents.ValueChanged)

        return refreshControl
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView()
        self.tableView.addSubview(self.refreshControl)

    }

    override func viewWillAppear(animated: Bool) {
        if let user = user{
            print("自分じゃないAccountなはず")
            print("アカウントのユーザー名(自分じゃないはず)", user.userName)
        }else {
            user = NCMBUser.currentUser()!
            print("自分のAccountなはず")
            print("アカウントのユーザー名(自分のはず)", user!.userName)
            
        }
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
extension AccountViewController: UITableViewDelegate, UITableViewDataSource {

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
            if user == NCMBUser.currentUser(){//自分の時
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
            
            cell.userProfileNameLabel.text = user!.objectForKey("userFaceName") as? String
            cell.userIdLabel.text = "@" + user!.userName
            cell.userSelfIntroductionTextView.text = user!.objectForKey("userSelfIntroduction") as? String
            cell.userSelfIntroductionTextView.textColor = UIColor.whiteColor()
            cell.userProfileImageView.layer.cornerRadius = cell.userProfileImageView.frame.width/2
            let userProfileImageName = (user!.objectForKey("userProfileImage") as? String)!
            let userProfileImageData = NCMBFile.fileWithName(userProfileImageName, data: nil) as! NCMBFile
            userProfileImageData.getDataInBackgroundWithBlock { (imageData: NSData?, error: NSError!) -> Void in
                if error != nil{
                    print("写真の取得失敗: \(error)")
                } else {
                    cell.userProfileImageView.image = UIImage(data: imageData!)
                    //EditProfileVCへの遷移のデータ
                    if self.user == NCMBUser.currentUser() {
                        self.myProfileImage = cell.userProfileImageView.image
                    }
                }
            }
            let userHomeImageName = (user!.objectForKey("userHomeImage") as? String)!
            let userHomeImageData = NCMBFile.fileWithName(userHomeImageName, data: nil) as! NCMBFile
            userHomeImageData.getDataInBackgroundWithBlock { (imageData: NSData?, error: NSError!) -> Void in
                if error != nil{
                    print("写真の取得失敗: \(error)")
                } else {
                    cell.userHomeImageView.image = UIImage(data: imageData!)
                    //EditProfileVCへの遷移のデータ
                    if self.user == NCMBUser.currentUser() {
                        self.myProfileHomeImage = cell.userHomeImageView.image
                    }
                }
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
            if let followNumbarInt = self.followNumbarInt {
                cell.followNumbarButton.setTitle("フォロー\n" + String(followNumbarInt), forState: .Normal)
            }else {
                cell.followNumbarButton.setTitle("フォロー\n" + String(""), forState: .Normal)
            }
            cell.followNumbarButton.titleLabel?.textAlignment = NSTextAlignment.Center
            cell.followNumbarButton.titleLabel?.adjustsFontSizeToFitWidth = true

            if let followerNumbarInt = self.followerNumbarInt {
                cell.followerNumbarButton.setTitle("フォロワー\n" + String(followerNumbarInt), forState: .Normal)
            }else {
                cell.followerNumbarButton.setTitle("フォロワー\n" + String(""), forState: .Normal)
            }
            cell.followerNumbarButton.titleLabel?.textAlignment = NSTextAlignment.Center
            cell.followerNumbarButton.titleLabel?.adjustsFontSizeToFitWidth = true
            
            cell.toLogButton.layer.cornerRadius = cell.toLogButton.frame.width/2
            cell.followNumbarButton.layer.cornerRadius = cell.followNumbarButton.frame.width/2
            cell.followerNumbarButton.layer.cornerRadius = cell.followerNumbarButton.frame.width/2
            
            cell.layoutIfNeeded()
            return cell
            
        default:
            if postArray.count == 0{
                tableView.emptyDataSetSource = self
                tableView.emptyDataSetDelegate = self
            }

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
            followOFF(followButton)
            followerNumbarInt = followerNumbarInt! - 1
        }else {
            followON(followButton)
            followerNumbarInt = followerNumbarInt! + 1
        }
        //特定のcellだけreloadかける（２行目）
        let indexPaths = NSIndexPath(forRow: 1, inSection: 0)
        tableView.reloadRowsAtIndexPaths([indexPaths], withRowAnimation: UITableViewRowAnimation.Fade)
    }
    
    func followON(followButton: UIButton){
        print("フォローする")
        followButton.enabled = false
        let relationObject = NCMBObject(className: "Relationship")
        relationObject.setObject(NCMBUser.currentUser(), forKey: "followed")
        relationObject.setObject(user, forKey: "follower")
        relationObject.saveEventually({ (error) -> Void in
            if let error = error {
                print(error.localizedDescription)
                self.isFollowing = false
                followButton.setImage(UIImage(named: "follow"), forState: UIControlState.Normal)
            }else {
                self.isFollowing = true
                followButton.setImage(UIImage(named: "followNow"), forState: UIControlState.Normal)
                print("フォローした", NCMBUser.currentUser().userName, "→", self.user!.userName)
                self.followingRelationshipObject.objectId = relationObject.objectId
                self.followingRelationshipObject = relationObject as NCMBObject
                //フォローしたことを通知画面のDBに保存
                let notificationManager = NotificationManager()
                notificationManager.followNotification(self.user!)
            }
            followButton.enabled = true
        })
    }
    
    func followOFF(followButton: UIButton){
        print("フォローをやめる")
        followButton.enabled = false
        followingRelationshipObject.fetchInBackgroundWithBlock({ (error) -> Void in
            if let error = error {
                print(error.localizedDescription)
                self.isFollowing = true
                followButton.setImage(UIImage(named: "followNow"), forState: UIControlState.Normal)
            }else {
                self.followingRelationshipObject.deleteEventually({(error) in
                    if let error = error {
                        print(error.localizedDescription)
                        self.isFollowing = true
                        followButton.setImage(UIImage(named: "followNow"), forState: UIControlState.Normal)
                    }else {
                        print("フォローをやめました")
                        self.isFollowing = false
                        followButton.setImage(UIImage(named: "follow"), forState: UIControlState.Normal)
                        self.followingRelationshipObject.objectId = "dummy"
                        //フォローしたデータを通知画面のDBから削除
                        let notificationManager = NotificationManager()
                        notificationManager.deleteFollowNotification(self.user!)
                    }
                })
            }
            followButton.enabled = true
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
        if isTwitterConnecting == true{
            testDeleteLinkAccount(user!)
            //            deleteTwitterAccount(user!)
        }else {
            addSnsToTwitter(user!)
        }
    }
    
    @IBAction func tapConnectFacebookButton(sender: AnyObject) {
        if isFacebookConnecting == true{
            testDeleteLinkAccount(user!)
            //            deleteFacebookAccount(user!)
        }else {
            //β版限定
            cannotConnectFacebookAlert(user!)
            //β版限定
//            addSnsToFacebook(user!)
        }
    }

    func toSafariBrowser (url: String){
        //            let url = NSURL(string:"http://qiita.com")
        let app:UIApplication = UIApplication.sharedApplication()
        app.openURL(NSURL(string: url)!)
    }

    func checkConnectTwitter(user: NCMBUser, cell: ProfileCell){
        if NCMBTwitterUtils.isLinkedWithUser(user) == false{
            print("Twitter未連携")
            isTwitterConnecting = false
            cell.twitterConnectButton.setImage(UIImage(named: "twitterWhite"), forState: .Normal)
        }else {
            print("Twitter連携済み")
            isTwitterConnecting = true
            cell.twitterConnectButton.setImage(UIImage(named: "twitterON"), forState: .Normal)
        }
    }
    
    func checkConnectFacebook(user: NCMBUser, cell: ProfileCell){
        if NCMBFacebookUtils.isLinkedWithUser(user) == false{
            print("Facebook未連携")
            isFacebookConnecting = false
            cell.facebookConnectButton.setImage(UIImage(named: "facebookWhite"), forState: .Normal)
            
        }else{
            print("Facebook連携済み")
            isFacebookConnecting = true
            cell.facebookConnectButton.setImage(UIImage(named: "facebookON"), forState: .Normal)
        }
    }
    
    //Twitterリンク(NCMBとの連携もできる)
    func addSnsToTwitter(user: NCMBUser){
        NCMBTwitterUtils.linkUser(user) { (error) -> Void in
            if error == nil {
                if let authToken = NCMBTwitterUtils.twitter().authToken{
                    let authTokenSecret = NCMBTwitterUtils.twitter().authTokenSecret
                    let userName = NCMBTwitterUtils.twitter().screenName
                    let userID = NCMBTwitterUtils.twitter().userId
                    print("userName", userName)
                    print(authToken)
                    print(authTokenSecret)
                    user.setObject(userName, forKey: "twitterName")
                    user.setObject(userID, forKey: "twitterID")
                    let store = Twitter.sharedInstance().sessionStore
                    
                    print(store)
                    store.saveSessionWithAuthToken(authToken, authTokenSecret: authTokenSecret, completion: { (session, error) -> Void in
                        if error == nil {
                            print("sessionセーブ開始")
                            user.saveInBackgroundWithBlock({ (error) -> Void in
                                if error != nil {
                                    print("twitterリンク失敗", error)
                                }else {
                                    print("twitterリンク成功")
                                    self.isTwitterConnecting = true
                                    //特定のcellだけreloadかける（1行目）
                                    let indexPaths = NSIndexPath(forRow: 0, inSection: 0)
                                    self.tableView.reloadRowsAtIndexPaths([indexPaths], withRowAnimation: UITableViewRowAnimation.Fade)
                                }
                            })
                        }else {
                            print("error", error)
                        }
                    })
                }else{
                    print("error: authTokenなどが取得できなかった")
                }
            }
        }
    }
    
    //Facebookリンク
    func addSnsToFacebook(user: NCMBUser) {
        NCMBFacebookUtils.linkUser(user, withReadPermission: ["public_profile", "email", "user_friends"]) { (user: NCMBUser!, error: NSError!) -> Void in
            if error == nil{
                print("facebookリンク開始")
                NCMBFacebookUtils.linkUser(user, withPublishingPermission:["publish_actions"]) { (user: NCMBUser!, error: NSError!) -> Void in
                    if error == nil{
                        let graphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id,email,gender,link,locale,name,timezone,updated_time,verified,last_name,first_name,middle_name"])
                        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
                            if error == nil{
                                print("facebookリンク情報ゲット")
                                let name = result.valueForKey("name") as! NSString
                                print("facebookユーザー名 : \(name)")
                                user.setObject(name, forKey: "facebookName")
                                user.saveInBackgroundWithBlock({ (error) -> Void in
                                    if error != nil {
                                        print("Facebookリンク失敗", error)
                                    }else {
                                        print("Facebookリンク成功")
                                        print("FBデータ", result)
                                        self.isFacebookConnecting = true
                                        //特定のcellだけreloadかける（1行目）
                                        let indexPaths = NSIndexPath(forRow: 0, inSection: 0)
                                        self.tableView.reloadRowsAtIndexPaths([indexPaths], withRowAnimation: UITableViewRowAnimation.Fade)                                    }
                                })
                            }else{
                                print("facebook情報ゲット失敗その２", error.localizedDescription)
                            }
                        })
                    }else {
                        print(error.localizedDescription)
                    }
                }
            }else {
                print(error.localizedDescription)
            }
        }
    }
    
    /***SNSアンリンクメソッド***/
    //Twitterアンリンク
    func deleteTwitterAccount(user: NCMBUser) {
        //「解除しますか？」アラート呼び出し
        print("userじょうほう", user)
        RMUniversalAlert.showAlertInViewController(self,
                                                   withTitle: "このアカウントはすでにTwitterと連携しています。",
                                                   message: "連携を解除する場合は、解除するボタンを押してください",
                                                   cancelButtonTitle: "完了",
                                                   destructiveButtonTitle: "解除する",
                                                   otherButtonTitles:nil,
                                                   tapBlock: {(alert, buttonIndex) in
                                                    if (buttonIndex == alert.cancelButtonIndex) {
                                                        print("完了 Tapped")
                                                    } else if (buttonIndex == alert.destructiveButtonIndex) {
                                                        print("解除する Tapped")
                                                        let store = Twitter.sharedInstance().sessionStore
                                                        if let userID = store.session()?.userID {
                                                            print(userID)
                                                            store.logOutUserID(userID)
                                                            NCMBTwitterUtils.unlinkUserInBackground(user, block: { (error) -> Void in
                                                                if error == nil {
                                                                    user.removeObjectForKey("twitterName")
                                                                    user.removeObjectForKey("twitterID")
                                                                    user.saveInBackgroundWithBlock({ (error) -> Void in
                                                                        if error == nil {
                                                                            self.isTwitterConnecting = false
                                                                            //                                                                            self.conectSnsTabelView.reloadData()
                                                                            print("Twitterアンリンク成功")
                                                                        }else{
                                                                            print("Twitterアンリンク失敗", error)
                                                                        }
                                                                    })
                                                                }else {
                                                                    print(error)
                                                                }
                                                            })
                                                        } else if (buttonIndex >= alert.firstOtherButtonIndex) {
                                                            print("Other Button Index \(buttonIndex - alert.firstOtherButtonIndex)")
                                                        }
                                                    }
        })
    }
    
    
    //Facebookアンリンク
    func deleteFacebookAccount(user: NCMBUser) {
        //「解除しますか？」アラート呼び出し
        RMUniversalAlert.showAlertInViewController(self,
                                                   withTitle: "このアカウントはすでにFacebookと連携しています。",
                                                   message: "連携を解除する場合は、解除するボタンを押してください",
                                                   cancelButtonTitle: "完了",
                                                   destructiveButtonTitle: "解除する",
                                                   otherButtonTitles:nil,
                                                   tapBlock: {(alert, buttonIndex) in
                                                    if (buttonIndex == alert.cancelButtonIndex) {
                                                        print("完了 Tapped")
                                                    } else if (buttonIndex == alert.destructiveButtonIndex) {
                                                        print("解除する Tapped")
                                                        NCMBFacebookUtils.unLinkUser(user, withBlock: { (user, error) -> Void in
                                                            if error == nil {
                                                                print("Facebookアンリンク開始")
                                                                print("user情報", user)
                                                                user.removeObjectForKey("facebookName")
                                                                user.saveInBackgroundWithBlock({ (error) -> Void in
                                                                    if error == nil {
                                                                        self.isFacebookConnecting = false
                                                                        //                                                                        self.conectSnsTabelView.reloadData()
                                                                        print("Facebookアンリンク成功")
                                                                        print("user情報その２", user)
                                                                    }else{
                                                                        print("Facebookアンリンク失敗", error)
                                                                    }
                                                                })
                                                            }else {
                                                                print("Facebookアンリンクできず", error)
                                                            }
                                                        })
                                                    }
        })
    }

    //β版限定
    func cannotConnectFacebookAlert(user: NCMBUser) {
        //「Facebookが今は連携出来ない」アラート呼び出し
        print("userじょうほう", user)
        RMUniversalAlert.showAlertInViewController(self,
                                                   withTitle: "現versionではFacebook連携はできません",
                                                   message: "versionアップデートをお待ち下さい",
                                                   cancelButtonTitle: "閉じる",
                                                   destructiveButtonTitle: nil,
                                                   otherButtonTitles: nil) { (alert, buttonIndex) in
                                                    if (buttonIndex == alert.cancelButtonIndex) {
                                                        print("完了 Tapped")
                                                    }else {
                                                        print("何かを Tapped")
                                                    }
        }
    }

    func testDeleteLinkAccount(user: NCMBUser) {
        //「解除しますか？」アラート呼び出し
        print("userじょうほう", user)
        RMUniversalAlert.showAlertInViewController(self,
                                                   withTitle: "このアカウントはすでに連携されています",
                                                   message: "現在、連携を解除することが出来ません",
                                                   cancelButtonTitle: "閉じる",
                                                   destructiveButtonTitle: nil,
                                                   otherButtonTitles: nil) { (alert, buttonIndex) in
                                                    if (buttonIndex == alert.cancelButtonIndex) {
                                                        print("完了 Tapped")
                                                    }else {
                                                        print("何かを Tapped")
                                                    }
        }
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
        return UIColor.lightGrayColor()    }

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
