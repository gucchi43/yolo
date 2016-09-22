//
//  NotificationTableViewController.swift
//  
//
//  Created by HIroki Taniguti on 2016/06/14.
//
//

import UIKit
import NCMB
import SwiftDate
import DZNEmptyDataSet
import SVProgressHUD
import NSDate_TimeAgo

class NotificationTableViewController: UITableViewController {
    var notificationArray: NSArray = NSArray()
    
    var selectedUser: NCMBUser!
    var selectedObject: NCMBObject!

    var cashProfileImageDictionary = [Int : UIImage]()

    override func viewDidLoad() {
        super.viewDidLoad()
        //Cellの高さを可変にする(ストーリーボードのオートレイアウトに合わしている)
        self.tableView.estimatedRowHeight = 200
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.tableFooterView =  UIView()
        self.refreshControl?.addTarget(self, action: #selector(NotificationTableViewController.pullRefreshloadArray), forControlEvents: UIControlEvents.ValueChanged)
        firstLoadArray()
//        self.tableView.emptyDataSetSource = self
//        self.tableView.emptyDataSetDelegate = self
//        self.tableView.emptyDataSetSource = nil
    }

    override func viewWillAppear(animated: Bool) {
//        loadArray()
    }

    //viewDidLoadの時しか呼べれない(SVProgressHUDを使う)
    func firstLoadArray() {
            SVProgressHUD.show()
        cashProfileImageDictionary.removeAll()
        //includeKeyで全部撮ってきたいんねん!!!!ほんとのところは！
        let notificationQuery: NCMBQuery = NCMBQuery(className: "Notification")
        notificationQuery.whereKey("ownerUser", equalTo: NCMBUser.currentUser())
        notificationQuery.orderByDescending("updateDate") // cellの並べ方
        notificationQuery.includeKey("actionUser")
        notificationQuery.limit = 20 //取ってくるデータ最新から20件
        notificationQuery.findObjectsInBackgroundWithBlock { (objects, error) in
            if let error = error {
                print(error.localizedDescription)
                    SVProgressHUD.showErrorWithStatus("読み込みに失敗しました")
            }else {
                if objects.count > 0 {
                    print("通知テーブルセルの数", objects.count)
                    self.notificationArray = objects
                    self.tableView.emptyDataSetSource = nil
                    self.tableView.emptyDataSetDelegate = nil
                    self.refreshControl?.endRefreshing()
                }else {
                    self.notificationArray = []
                    print("通知はまだ0です……")
                    self.tableView.emptyDataSetSource = self
                    self.tableView.emptyDataSetDelegate = self
                }
                self.tableView.reloadData()
                    SVProgressHUD.dismiss()
            }
        }
    }


    //pullRefreshの時呼ばれる(refreshControlを使う)
    func pullRefreshloadArray() {
//        //includeKeyで全部撮ってきたいんねん!!!!ほんとのところは！
        let notificationQuery: NCMBQuery = NCMBQuery(className: "Notification")
        notificationQuery.whereKey("ownerUser", equalTo: NCMBUser.currentUser())
        notificationQuery.orderByDescending("updateDate") // cellの並べ方
        notificationQuery.includeKey("actionUser")
        notificationQuery.limit = 20 //取ってくるデータ最新から20件
        notificationQuery.findObjectsInBackgroundWithBlock { (objects, error) in
            if let error = error {
                print(error.localizedDescription)
                self.refreshControl?.endRefreshing()
                SVProgressHUD.showErrorWithStatus("読み込みに失敗しました")
            }else {
                if objects.count > 0 {
                    print("通知テーブルセルの数", objects.count)
                    self.notificationArray = objects
                    self.tableView.emptyDataSetSource = nil
                    self.tableView.emptyDataSetDelegate = nil
                }else {
                    self.notificationArray = []
                    print("通知はまだ0です……")
                    self.tableView.emptyDataSetSource = self
                    self.tableView.emptyDataSetDelegate = self

                }
                self.cashProfileImageDictionary.removeAll()
                self.tableView.reloadData()
                self.refreshControl?.endRefreshing()
            }
        }
    }

    func readedAction(object: NCMBObject) {
        object.setObject(1, forKey: "readToggle")
        object.saveInBackgroundWithBlock { (error) in
            if let error = error {
                print(error.localizedDescription)
            }else {
                print("readedAction成功")
            }
        }

    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //Arrayの頭からMAX20個にしたい
        let numberOfRow = notificationArray.count
        return numberOfRow
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let type = (notificationArray[indexPath.row] as! NCMBObject).objectForKey("type") as! String
        print("type", type)
        
        switch type{
            
        case "follow": //フォローのCell
            let cell = tableView.dequeueReusableCellWithIdentifier("followdCell", forIndexPath: indexPath) as! NotificationFollowTableViewCell
            let followerInfo = notificationArray[indexPath.row] as! NCMBObject
            print("followerInfo", followerInfo)
//            let agoTime = (followerInfo.objectForKey("date") as! NSDate).timeAgo()
            let agoTime = (followerInfo.createDate as NSDate).timeAgo()
            print("agoTime", agoTime)
            let readedToggle = followerInfo.objectForKey("readToggle") as? Int
            if readedToggle == 0 {
                //未読
                cell.backgroundColor = ColorManager.sharedSingleton.noReadColor()
                updateReadToggle(followerInfo, cell: cell)

            }else {
                //既読
                print("このセルは既読済み", indexPath)
                cell.backgroundColor = UIColor.whiteColor()
            }
            cell.postLabel.text = ""
            cell.userImageView.image = UIImage(named: "noprofile")
            cell.agoTimeLabel.text = agoTime
            cell.userImageView.layer.cornerRadius = cell.userImageView.frame.width/2
            //"user"情報読み込み
            let keyUser = followerInfo.objectForKey("actionUser") as? NCMBUser
            guard let user = keyUser else { return cell } //この場合、ユーザー情報が載ってないcellがreturnされる。
            cell.userLabel.text = user.objectForKey("userFaceName") as? String
            //一度ロードしたか？
            print("indexPath.row", indexPath.row)
            if let cashProfileImage = cashProfileImageDictionary[indexPath.row] {
                cell.userImageView.image = cashProfileImage
            }else {
                let userImage = NCMBFile.fileWithName(user.objectForKey("userProfileImage") as? String, data: nil) as! NCMBFile
                userImage.getDataInBackgroundWithBlock({ (imageData: NSData?, error: NSError!)-> Void in
                    if let error = error {
                        print("error", error.localizedDescription)
                    } else {
                        cell.userImageView.image = UIImage(data: imageData!)
                        self.cashProfileImageDictionary[indexPath.row] = UIImage(data: imageData!)
                    }
                })
            }
            cell.layoutIfNeeded()
            return cell
            
        case "like": //いいねのCell
            let cell = tableView.dequeueReusableCellWithIdentifier("likedCell", forIndexPath: indexPath) as! NotificationLikeTableViewCell
            let likeInfo = notificationArray[indexPath.row] as! NCMBObject
            print("likeInfo", likeInfo)
            let agoTime = (likeInfo.createDate as NSDate).timeAgo()
            print("agoTime", agoTime)
            let readedToggle = likeInfo.objectForKey("readToggle") as? Int
            if readedToggle == 0 {
                //未読
                cell.backgroundColor = ColorManager.sharedSingleton.noReadColor()
                updateReadToggle(likeInfo, cell: cell)
            }else {
                //既読
                print("このセルは既読済み", indexPath)
                cell.backgroundColor = UIColor.whiteColor()
            }
            cell.postLabel.text = ""
            cell.userImageView.image = UIImage(named: "noprofile")
            cell.agoTimeLabel.text = agoTime
            cell.userImageView.layer.cornerRadius = cell.userImageView.frame.width/2
            //"user"情報読み込み
            let keyUser = likeInfo.objectForKey("actionUser") as? NCMBUser
            guard let user = keyUser else { return cell } //この場合、ユーザー情報が載ってないcellがreturnされる。
            cell.userLabel.text = user.objectForKey("userFaceName") as? String
            //一度ロードしたか？
            print("indexPath.row", indexPath.row)
            if let cashProfileImage = cashProfileImageDictionary[indexPath.row] {
                cell.userImageView.image = cashProfileImage
            }else {
                let userImage = NCMBFile.fileWithName(user.objectForKey("userProfileImage") as? String, data: nil) as! NCMBFile
                userImage.getDataInBackgroundWithBlock({ (imageData: NSData?, error: NSError!)-> Void in
                    if let error = error {
                        print("error", error.localizedDescription)
                    } else {
                        cell.userImageView.image = UIImage(data: imageData!)
                        self.cashProfileImageDictionary[indexPath.row] = UIImage(data: imageData!)
                    }
                })
            }
            cell.postLabel.text = likeInfo.objectForKey("postHeader") as? String
            
            cell.layoutIfNeeded()
            return cell

            
        case "comment": //コメントのCell
            let cell = tableView.dequeueReusableCellWithIdentifier("commentedCell", forIndexPath: indexPath) as! NotificationCommentTableViewCell
            let commentInfo = notificationArray[indexPath.row] as! NCMBObject
            print("likeInfo", commentInfo)
            let agoTime = (commentInfo.createDate as NSDate).timeAgo()
            print("agoTime", agoTime)
            let readedToggle = commentInfo.objectForKey("readToggle") as? Int
            if readedToggle == 0 {
                //未読
                cell.backgroundColor = ColorManager.sharedSingleton.noReadColor()
                updateReadToggle(commentInfo, cell: cell)
            }else {
                //既読
                print("このセルは既読済み", indexPath)
                cell.backgroundColor = UIColor.whiteColor()
            }
            cell.postLabel.text = ""
            cell.userImageView.image = UIImage(named: "noprofile")
            cell.agoTimeLabel.text = agoTime
            cell.userImageView.layer.cornerRadius = cell.userImageView.frame.width/2
            //"user"情報読み込み
            let keyUser = commentInfo.objectForKey("actionUser") as? NCMBUser
            guard let user = keyUser else { return cell } //この場合、ユーザー情報が載ってないcellがreturnされる。
            cell.userLabel.text = user.objectForKey("userFaceName") as? String
            //一度ロードしたか？
            print("indexPath.row", indexPath.row)
            if let cashProfileImage = cashProfileImageDictionary[indexPath.row] {
                cell.userImageView.image = cashProfileImage
            }else {
                let userImage = NCMBFile.fileWithName(user.objectForKey("userProfileImage") as? String, data: nil) as! NCMBFile
                userImage.getDataInBackgroundWithBlock({ (imageData: NSData?, error: NSError!)-> Void in
                    if let error = error {
                        print("error", error.localizedDescription)
                    } else {
                        cell.userImageView.image = UIImage(data: imageData!)
                        self.cashProfileImageDictionary[indexPath.row] = UIImage(data: imageData!)
                    }
                })
            }
            cell.postLabel.text = commentInfo.objectForKey("postHeader") as? String
            cell.commentLabel.text = commentInfo.objectForKey("commentHeader") as? String
            cell.layoutIfNeeded()
            return cell
            
        default:
            print("default")
            let cell = tableView.dequeueReusableCellWithIdentifier("followdCell", forIndexPath: indexPath) as! NotificationFollowTableViewCell
            return cell
        }

    }

    func updateReadToggle(object : NCMBObject, cell: UITableViewCell) {
        object.setObject(1, forKey: "readToggle")
        object.saveInBackgroundWithBlock { (error) in
            if let error = error {
                print("readToggleをに変更失敗（既読失敗）", error.localizedDescription)
            }else {
                print("readToggleを0→1に変更（既読）")
                cell.backgroundColor = UIColor.whiteColor()
            }
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("何個めのCell選択", indexPath.row)
        self.readedAction(notificationArray[indexPath.row] as! NCMBObject)

        let type = (notificationArray[indexPath.row] as! NCMBObject).objectForKey("type") as! String
        print("選択したCellのtype", type)

        switch type {
        case "follow":
            print("followのCellを選択 → AccountViewControllerに遷移")
            selectedUser = (notificationArray[indexPath.row] as! NCMBObject).objectForKey("actionUser") as! NCMBUser
            performSegueWithIdentifier("toAccountVC", sender: nil)
            
        case "like":
            print("likeのCellを選択 → Post画面に遷移")
            print("followのCellを選択 → PostDetailViewControllerに遷移")
            selectedObject = notificationArray[indexPath.row] as! NCMBObject
            performSegueWithIdentifier("toPostDetailVC", sender: nil)

        case "comment":
            print("commnetのCellを選択 → Post画面に遷移")
            print("followのCellを選択 → PostDetailViewControllerに遷移")
            selectedObject = notificationArray[indexPath.row] as! NCMBObject
            performSegueWithIdentifier("toPostDetailVC", sender: nil)

        default:
            print("その他 ありえないprintなんですよ")
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        switch segue.identifier! as String {
        case "toSubmitVC":
            break

        case "toAccountVC": //followのCell選択時→ユーザー画面に遷移
            guard let accountVC = segue.destinationViewController as? AccountViewController else { return }
            print("selectedUser", selectedUser)
            accountVC.user = selectedUser
        
        case "toPostDetailVC": //like、commentのCell選択時→投稿詳細画面に遷移
            guard let postDetailVC = segue.destinationViewController as? PostDetailViewController else { return }
            print("selectedObject", selectedObject)

            let postRelation = selectedObject.relationforKey("post") as NCMBRelation
            let postQuery = postRelation.query()
            postQuery.orderByAscending("createDate")
            postQuery.includeKey("user")
            do{
                let object = try postQuery.getFirstObject()
                
                postDetailVC.postObject = object as! NCMBObject
                print("投稿object", postDetailVC.postObject)
                print("投稿User", postDetailVC.postObject.objectForKey("user") as! NCMBUser)
                
            }catch let error as NSError{
                print(error.localizedDescription)
            }
            
        default:
            print("そのほかあああ")
        }
    }
}

extension NotificationTableViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    //------------------DZNEmptyDataSet(セルが無い時に表示するViewの設定--------------------

    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let str = "😴まだお知らせはないよ😴"
        let attrs = [NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)]

        return NSAttributedString(string: str, attributes: attrs)
    }

    func descriptionForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let str = "まずは友達をフォローしてみよう"
        let attrs = [NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleBody)]
        return NSAttributedString(string: str, attributes: attrs)
    }

    func emptyDataSetShouldDisplay(scrollView: UIScrollView!) -> Bool {
        return true
    }

    func emptyDataSetShouldAllowTouch(scrollView: UIScrollView!) -> Bool {
        return true
    }

    func emptyDataSetShouldAllowScroll(scrollView: UIScrollView!) -> Bool {
        return true
    }

    func emptyDataSetShouldAnimateImageView(scrollView: UIScrollView!) -> Bool {
        return false
    }

}
