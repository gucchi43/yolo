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

class LooKBackViewController: UIViewController {
    
    @IBOutlet weak var segment: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    var posts: NSArray = NSArray()
    var dayLoadingToggle = false
    
    let likeOnImage = UIImage(named: "hartON")
    let likeOffImage = UIImage(named: "hartOFF")
    var cashImageDictionary = [Int : UIImage]()
    var cashProfileImageDictionary = [Int : UIImage]()
    
    //    セル選択時の変数
    var selectedPostObject: NCMBObject!
    var selectedPostImage: UIImage?
    
    override func viewDidLoad() {
        posts = []
        tableView.estimatedRowHeight = 370
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        
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
                print(error.localizedDescription)
            } else {
                if objects.count > 0 {
                    print("その日に投稿があるパターン")
                    print("投稿数", objects.count)
                    self.posts = objects
                    //                    self.dayLoadingToggle = false
                    self.tableView.emptyDataSetSource = nil
                    self.tableView.emptyDataSetDelegate = nil
                } else {
                    print("その日に投稿がないパターン")
                    //                    self.dayLoadingToggle = false
                    self.posts = []
                    self.tableView.emptyDataSetSource = self
                    self.tableView.emptyDataSetDelegate = self
                }
                self.tableView.reloadData()
            }
        })
        
        
    }
    
    @IBAction func selectSegmentAction(sender: AnyObject) {
        loadQuery()
    }
}

extension LooKBackViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate{
    //------------------DZNEmptyDataSet(セルが無い時に表示するViewの設定--------------------
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        if self.dayLoadingToggle == true {
            let postDateFormatter: NSDateFormatter = NSDateFormatter()
            postDateFormatter.dateFormat = "dd"
            let dayString = postDateFormatter.stringFromDate(CalendarManager.currentDate)
            let str = "😴 " + dayString + "日" + " 😴"
            let attrs = [NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleTitle1) , NSForegroundColorAttributeName:  UIColor.whiteColor()]
            return NSAttributedString(string: str, attributes: attrs)
        }else {
            let logNumber: Int
            if logManager.sharedSingleton.logTitleToggle == true{
                logNumber = logManager.sharedSingleton.tabLogNumber
            }else {
                logNumber = logManager.sharedSingleton.logNumber
            }
            switch logNumber {
            case 0: //自分の時
                let str = "😝その日のログはまだないよ😝"
                let attrs = [NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline), NSForegroundColorAttributeName: UIColor.whiteColor()]
                return NSAttributedString(string: str, attributes: attrs)
            default: //自分ではない時
                let str = "😝その日のログはまだないよ😝"
                let attrs = [NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline), NSForegroundColorAttributeName: UIColor.whiteColor()]
                return NSAttributedString(string: str, attributes: attrs)
            }
        }
    }

    func descriptionForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        if self.dayLoadingToggle == true {
            let str = "読み込み中..."
            let attrs = [NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleBody), NSForegroundColorAttributeName: UIColor.whiteColor()]
            return NSAttributedString(string: str, attributes: attrs)
        }else {
            let logNumber: Int
            if logManager.sharedSingleton.logTitleToggle == true{
                logNumber = logManager.sharedSingleton.tabLogNumber
            }else {
                logNumber = logManager.sharedSingleton.logNumber
            }
            switch logNumber {
            case 0: //自分の時
                let str = "今すぐログっちゃおう"
                let attrs = [NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleBody), NSForegroundColorAttributeName: UIColor.whiteColor()]
                return NSAttributedString(string: str, attributes: attrs)
            default: //自分ではない時
                let str = "ヒマだよねー"
                let attrs = [NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleBody), NSForegroundColorAttributeName: UIColor.whiteColor()]
                return NSAttributedString(string: str, attributes: attrs)
            }

        }
    }

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
        // postTextLabelには(key: "text")の値を入れる
        cell.postTextLabel.delegate = self
        // urlをリンクにする設定
        let linkColor = ColorManager.sharedSingleton.mainColor()
        let linkActiveColor = ColorManager.sharedSingleton.mainColor().darken(0.25)
        cell.postTextLabel.linkAttributes = [kCTForegroundColorAttributeName : linkColor]
        cell.postTextLabel.activeLinkAttributes = [kCTForegroundColorAttributeName : linkActiveColor]
        cell.postTextLabel.enabledTextCheckingTypes = NSTextCheckingType.Link.rawValue
        
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

            //一度ロードしたか？
            print("indexPath.row", indexPath.row)
            if let cashProfileImage = cashProfileImageDictionary[indexPath.row] {
                cell.userProfileImageView.image = cashProfileImage
            }else {
                let postImageData = NCMBFile.fileWithName(author.objectForKey("userProfileImage") as? String, data: nil) as! NCMBFile
                postImageData.getDataInBackgroundWithBlock({ (imageData: NSData?, error: NSError!) -> Void in
                    if let error = error {
                        print("プロフィール画像の取得失敗： ", error)
                        cell.userProfileImageView.image = UIImage(named: "noprofile")
                    } else {
                        cell.userProfileImageView.image = UIImage(data: imageData!)
                        print("(before)indexPath -> cashProfileImageDictionary", indexPath.row, "->", self.cashProfileImageDictionary)
                        self.cashProfileImageDictionary[indexPath.row] = UIImage(data: imageData!)
                        print("(after)indexPath -> cashProfileImageDictionary", indexPath.row, "->", self.cashProfileImageDictionary)

                    }
                })
            }
        } else {
            cell.userNameLabel.text = "username"
            cell.userProfileImageView.image = UIImage(named: "noprofile")
        }
        
        //画像データの取得
        if let postImageName = postData.objectForKey("image1") as? String {
            cell.imageViewHeightConstraint.constant = 150.0
            //一度ロードしたか？
            print("indexPath.row", indexPath.row)
            if let cashImage = cashImageDictionary[indexPath.row] {
                cell.postImageView.image = cashImage
                cell.postImageView.layer.cornerRadius = 5.0
            }else {
                let postImageData = NCMBFile.fileWithName(postImageName, data: nil) as! NCMBFile
                postImageData.getDataInBackgroundWithBlock({ (imageData: NSData?, error: NSError!) -> Void in
                    if let error = error {
                        print("写真の取得失敗： ", error)
                    } else {
                        cell.postImageView.image = UIImage(data: imageData!)
                        cell.postImageView.layer.cornerRadius = 5.0
                        print("(before)indexPath -> cashImageDictionary", indexPath.row, "->", self.cashImageDictionary)
                        self.cashImageDictionary[indexPath.row] = UIImage(data: imageData!)
                        print("(after)indexPath -> cashImageDictionary", indexPath.row, "->", self.cashImageDictionary)
                    }
                })
            }
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
//        selectedPostObject = self.posts[indexPath.row] as! NCMBObject
//        if let cashImage = cashImageDictionary[indexPath.row] {
//            selectedPostImage = cashImage
//        }else {
//            selectedPostImage = nil
//        }
//        performSegueWithIdentifier("toPostDetailVC", sender: nil)
    }

//     urlリンクをタップされたときの処理を記述します
    func attributedLabel(label: TTTAttributedLabel!, didSelectLinkWithURL url: NSURL!)
    {
        print(url)
        if UIApplication.sharedApplication().canOpenURL(url!){
            UIApplication.sharedApplication().openURL(url!)
        }
    }
}

