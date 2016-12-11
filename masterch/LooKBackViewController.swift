//
//  LooKBackViewController.swift
//  masterch
//
//  Created by HIroki Taniguti on 2016/09/30.
//  Copyright © 2016年 Fumiya Yamanaka. All rights reserved.
//

import UIKit
import NCMB
import SwiftDate
import DZNEmptyDataSet
import TTTAttributedLabel
import SDWebImage

class LooKBackViewController: UIViewController, addPostDetailDelegate {
    
    @IBOutlet weak var segment: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    var posts: NSArray = NSArray()
    var dayLoadingToggle = false
    
    let likeOnImage = UIImage(named: "hartON")
    let likeOffImage = UIImage(named: "hartOFF")

    //    セル選択時の変数
    var selectedPostObject: NCMBObject!
    var selectedPostImage: UIImage?
    
    override func viewDidLoad() {
        posts = []
        segment.tintColor = ColorManager.sharedSingleton.mainColor()
        tableView.estimatedRowHeight = 370
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        self.tableView.tableFooterView =  UIView()

        tableView.sectionHeaderHeight = 50

        resetAndLoading()
        loadQuery()
    }
    
    //tableViewに表示するその日の投稿をQueryから取ってくる
    func loadQuery(){
        var query: NCMBQuery = NCMBQuery()
        let queryManager = LookBackQueryManager()
        switch segment.selectedSegmentIndex {
        case 0:
            query = queryManager.getOneWeekAgoQuery()
            break
            
        case 1:
            query = queryManager.getOneMonthAgoQuery()
            break
            
        case 2:
            query = queryManager.getOneYearAgoQuery()
            break
            
        default:
            break
        }

        query.findObjectsInBackgroundWithBlock({(objects, error) in
            if let error = error {
                self.dayLoadingToggle = false
                print(error.localizedDescription)
            } else {
                self.dayLoadingToggle = false
                if objects.count > 0 {
                    print("その日に投稿があるパターン")
                    print("投稿数", objects.count)
                    self.posts = objects
                    self.tableView.emptyDataSetSource = nil
                    self.tableView.emptyDataSetDelegate = nil
                } else {
                    print("その日に投稿がないパターン")
                    self.posts = []
                    self.tableView.emptyDataSetSource = self
                    self.tableView.emptyDataSetDelegate = self
                }
                self.tableView.reloadData()
            }
        })
    }

    func resetAndLoading() {
        if posts == [] {
            print("empty状態だった時")
        }else {
            print("reset tableView position")
            let indexPath = NSIndexPath(forRow: 0, inSection: 0)
            tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Top, animated: false)
        }
        dayLoadingToggle = true
        posts = []
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        tableView.reloadData()
    }

    @IBAction func selectSegmentAction(sender: AnyObject) {
        resetAndLoading()
        loadQuery()
    }
    
    @IBAction func tapCommentButtonAction(sender: UIButton) {
        // 押されたボタンを取得
        let cell = sender.superview?.superview as! TimelineCell
        let row = tableView.indexPathForCell(cell)?.row
        selectedPostObject = self.posts[row!] as! NCMBObject
        
        performSegueWithIdentifier("toPostDetailVC", sender: true)
    }
    
    @IBAction func tapLikeButtonAction(sender: AnyObject) {
        print("LIKEボタン押した")
        let button = sender as! UIButton
        let cell = button.superview?.superview as! TimelineCell
        print("投稿内容", cell.postTextLabel.text)
        let row = tableView.indexPathForCell(cell)?.row
        let postData = posts[row!] as! NCMBObject
        
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
                cell.isLikeToggle = false
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
    
    func postDetailDismissionAction() {
        print("postDetailDismissionAction")
        tableView.reloadData()
    }
}

extension LooKBackViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate{
    //------------------DZNEmptyDataSet(セルが無い時に表示するViewの設定--------------------
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        if self.dayLoadingToggle == true {
            let str = "💨 タイムトリップ中 💨"
            let attrs = [NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline) , NSForegroundColorAttributeName:  UIColor.whiteColor()]
            return NSAttributedString(string: str, attributes: attrs)
        }else {
            let str = "😪 その日のログはなかったよ 😪"
            let attrs = [NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline), NSForegroundColorAttributeName: UIColor.whiteColor()]
            return NSAttributedString(string: str, attributes: attrs)
        }
    }

    func descriptionForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        if self.dayLoadingToggle == true {
            let str = "ちょっとまってね..."
            let attrs = [NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleBody), NSForegroundColorAttributeName: UIColor.whiteColor()]
            return NSAttributedString(string: str, attributes: attrs)
        }else {
            let str = "ドンマイ!!"
            let attrs = [NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleBody), NSForegroundColorAttributeName: UIColor.whiteColor()]
            return NSAttributedString(string: str, attributes: attrs)
        }
    }

    func backgroundColorForEmptyDataSet(scrollView: UIScrollView!) -> UIColor! {
        return UIColor.lightGrayColor()
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

extension LooKBackViewController: UITableViewDelegate, UITableViewDataSource, TTTAttributedLabelDelegate {

    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor.whiteColor()
        let label = UILabel(frame: CGRectMake(0, 0, tableView.frame.width, 50))
        label.textColor = ColorManager.sharedSingleton.mainColor()
//        label.font = UIFont.boldSystemFontOfSize(24)
        label.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 24)
        label.textAlignment = NSTextAlignment.Center

        var agoDayTitle: String?
        let dayTitleManager = LookBackDayTitleManager()

        switch segment.selectedSegmentIndex {
        case 0:
            agoDayTitle = "🚁 " + dayTitleManager.getWeekAgoDayTitle(NSDate(), agoInt: 1) + " 🚁"
            break

        case 1:
            agoDayTitle =  "✈️ " + dayTitleManager.getMonthAgoDayTitle(NSDate(), agoInt: 1) + " ✈️"
            break

        case 2:
            agoDayTitle = "🚀 " + dayTitleManager.getYearAgoDayTitle(NSDate(), agoInt: 1) + " 🚀"
            break

        default:
            break
        }

        label.text = agoDayTitle
        view.addSubview(label)

        return view
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellId = "TimelineCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellId, forIndexPath: indexPath) as! TimelineCell
        
        //ImageViewの初期化的な
        cell.userProfileImageView.image = UIImage(named: "noprofile")
        cell.postImageView.image = nil
        
        // 各値をセルに入れる
        let postData = posts[indexPath.row] as! NCMBObject
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





//        //プロフィール写真の形を円形にする
//        cell.userProfileImageView.layer.cornerRadius = cell.userProfileImageView.frame.width/2
//        let author = postData.objectForKey("user") as? NCMBUser
//        if let author = author {
//            cell.userNameLabel.text = author.objectForKey("userFaceName") as? String
//
//            //一度ロードしたか？
//            print("indexPath.row", indexPath.row)
//            if let cashProfileImage = cashProfileImageDictionary[indexPath.row] {
//                cell.userProfileImageView.image = cashProfileImage
//            }else {
//                let postImageData = NCMBFile.fileWithName(author.objectForKey("userProfileImage") as? String, data: nil) as! NCMBFile
//                postImageData.getDataInBackgroundWithBlock({ (imageData: NSData?, error: NSError!) -> Void in
//                    if let error = error {
//                        print("プロフィール画像の取得失敗： ", error)
//                        cell.userProfileImageView.image = UIImage(named: "noprofile")
//                    } else {
//                        cell.userProfileImageView.image = UIImage(data: imageData!)
//                        print("(before)indexPath -> cashProfileImageDictionary", indexPath.row, "->", self.cashProfileImageDictionary)
//                        self.cashProfileImageDictionary[indexPath.row] = UIImage(data: imageData!)
//                        print("(after)indexPath -> cashProfileImageDictionary", indexPath.row, "->", self.cashProfileImageDictionary)
//
//                    }
//                })
//            }
//        } else {
//            cell.userNameLabel.text = "username"
//            cell.userProfileImageView.image = UIImage(named: "noprofile")
//        }

        // postTextLabel
        cell.postTextLabel.delegate = self
        // urlをリンクにする設定
        let linkColor = ColorManager.sharedSingleton.mainColor()
        let linkActiveColor = ColorManager.sharedSingleton.mainColor().darken(0.25)
        cell.postTextLabel.linkAttributes = [kCTForegroundColorAttributeName : linkColor]
        cell.postTextLabel.activeLinkAttributes = [kCTForegroundColorAttributeName : linkActiveColor]
        cell.postTextLabel.enabledTextCheckingTypes = NSTextCheckingType.Link.rawValue
        cell.postTextLabel.text = postData.objectForKey("text") as? String

        // postDateLabel
        let date = postData.objectForKey("postDate") as? NSDate
        print("NSDateの内容", date)
        let postDateFormatter: NSDateFormatter = NSDateFormatter()
        postDateFormatter.dateFormat = "yyyy/MM/dd HH:mm"
        cell.postDateLabel.text = postDateFormatter.stringFromDate(date!)

        //commentButton
        cell.commentButton.addTarget(self, action: #selector(LooKBackViewController.tapCommentButtonAction(_:)), forControlEvents: .TouchUpInside)

        //postImageView
        cell.postImageView.image = nil
        if let postImageName = postData.objectForKey("image1") as? String {
            cell.imageViewHeightConstraint.constant = 150.0
//            cell.postImageView.layer.cornerRadius = 5.0
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
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("セルの選択: \(indexPath.row)")
        selectedPostObject = self.posts[indexPath.row] as! NCMBObject
        performSegueWithIdentifier("toPostDetailVC", sender: nil)
    }

//     urlリンクをタップされたときの処理を記述します
    func attributedLabel(label: TTTAttributedLabel!, didSelectLinkWithURL url: NSURL!)
    {
        print(url)
        if UIApplication.sharedApplication().canOpenURL(url!){
            UIApplication.sharedApplication().openURL(url!)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toPostDetailVC" {
            let postDetailVC: PostDetailViewController = segue.destinationViewController as! PostDetailViewController
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
    }
}

