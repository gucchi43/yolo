//
//  NotificationTableViewController.swift
//  
//
//  Created by HIroki Taniguti on 2016/06/14.
//
//

import UIKit
import SwiftDate


class NotificationTableViewController: UITableViewController {
    var notificationArray: NSArray = NSArray()
    
    var selectedUser: NCMBUser!
    var selectedObject: NCMBObject!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Cellの高さを可変にする(ストーリーボードのオートレイアウトに合わしている)
        self.tableView.estimatedRowHeight = 200
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
    }
    
    override func viewWillAppear(animated: Bool) {
        loadArray()
//        self.tableView.reloadData()
    }
    
    func loadArray() {
        
        //includeKeyで全部撮ってきたいんねん!!!!
        
//        let userNotifivationQuery: NCMBQuery = NCMBQuery(className: "Notification")
//        userNotifivationQuery.includeKey("actionUser") //actionUserのポインターの中身のデータを取得する
//        let postNotificationQuery: NCMBQuery = NCMBQuery(className: "Notification") // 自分がフォローしている人かどうかのクエリ
//        postNotificationQuery.includeKey("post") //postのポインターの中身のデータを取得する
        
        let notificationQuery: NCMBQuery = NCMBQuery(className: "Notification")
        notificationQuery.whereKey("ownerUser", equalTo: NCMBUser.currentUser())
        notificationQuery.orderByDescending("updateDate") // cellの並べ方
        notificationQuery.includeKey("actionUser")
        notificationQuery.limit = 20 //取ってくるデータ最新から20件
        notificationQuery.findObjectsInBackgroundWithBlock { (objects, error) in
            if let error = error {
                print(error.localizedDescription)
            }else {
                if objects.count > 0 {
                    self.notificationArray = objects
                    print("通知テーブルセルの数", objects.count)
                    self.tableView.reloadData()
                }else {
                    self.notificationArray = []
                    print("通知はまだ0です……")
                }
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
            let followerInfo = notificationArray[indexPath.row]
            print("followerInfo", followerInfo)
            let timeDate = followerInfo.objectForKey("date") as! NSDate
            print("timeDate", timeDate)
            //本当はtimeAgoを使いたい
//            let agoTime = timeDate.timeAgo
//            print("agoTime", agoTime)
            
            //仮で"yyyy MM/dd HH:mm"で表示している
            let dateFormatter: NSDateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy MM/dd HH:mm"
            let agoTime = dateFormatter.stringFromDate(timeDate)
            
            cell.postLabel.text = ""
            cell.userImageView.image = UIImage(named: "noprofile")
            cell.agoTimeLabel.text = agoTime
            cell.userImageView.layer.cornerRadius = cell.userImageView.frame.width/2
            let user = followerInfo.objectForKey("actionUser") as? NCMBUser
            print("userは取れてんの？", user)
            if let user = user {
                print("userFaceName", user.objectForKey("userFaceName") as? String)
                cell.userButton.setTitle(user.objectForKey("userFaceName") as? String, forState: .Normal)
                let userImage = NCMBFile.fileWithName(user.objectForKey("userProfileImage") as? String, data: nil) as! NCMBFile
                userImage.getDataInBackgroundWithBlock({ (imageData: NSData?, error: NSError!)-> Void in
                    if let error = error {
                        print("error", error.localizedDescription)
                    } else {
                        cell.userImageView.image = UIImage(data: imageData!)
                    }
                })
            }
            cell.layoutIfNeeded()
            return cell
            
        case "like": //いいねのCell
            let cell = tableView.dequeueReusableCellWithIdentifier("likedCell", forIndexPath: indexPath) as! NotificationLikeTableViewCell
            let likeInfo = notificationArray[indexPath.row]
            print("likeInfo", likeInfo)
            
            let timeDate = likeInfo.objectForKey("date") as! NSDate
            print("timeDate", timeDate)
            
            //本当はtimeAgoを使いたい
            //            let agoTime = timeDate.timeAgo
            //            print("agoTime", agoTime)
            
            //仮で"yyyy MM/dd HH:mm"で表示している
            let dateFormatter: NSDateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy MM/dd HH:mm"
            let agoTime = dateFormatter.stringFromDate(timeDate)
            
            cell.postLabel.text = ""
            cell.userImageView.image = UIImage(named: "noprofile")
            cell.agoTimeLabel.text = agoTime
            cell.userImageView.layer.cornerRadius = cell.userImageView.frame.width/2
            let user = likeInfo.objectForKey("actionUser") as? NCMBUser
            print("userは取れてんの？", user)
            if let user = user {
                print("userFaceName", user.objectForKey("userFaceName") as? String)
                cell.userButton.setTitle(user.objectForKey("userFaceName") as? String, forState: .Normal)
                let userImage = NCMBFile.fileWithName(user.objectForKey("userProfileImage") as? String, data: nil) as! NCMBFile
                userImage.getDataInBackgroundWithBlock({ (imageData: NSData?, error: NSError!) -> Void in
                    if let error = error {
                        print("error", error.localizedDescription)
                    } else {
                        cell.userImageView.image = UIImage(data: imageData!)
                    }
                })
            }
            let post = likeInfo.objectForKey("post") as? NCMBObject
            if let post = post {
                var postError: NSError?
                post.fetch(&postError)
                if postError == nil {
                    print("postText", post.objectForKey("text") as? String)
                    cell.postLabel.text = post.objectForKey("text") as? String
                }else {
                    print(postError!.localizedDescription)
                }
            }
            cell.layoutIfNeeded()
            return cell

            
        case "comment": //コメントのCell
            let cell = tableView.dequeueReusableCellWithIdentifier("commentedCell", forIndexPath: indexPath) as! NotificationCommentTableViewCell
            let commentInfo = notificationArray[indexPath.row]
            print("likeInfo", commentInfo)
            
            let timeDate = commentInfo.objectForKey("date") as! NSDate
            print("timeDate", timeDate)
            
            //本当はtimeAgoを使いたい
            //            let agoTime = timeDate.timeAgo
            //            print("agoTime", agoTime)
            
            //仮で"yyyy MM/dd HH:mm"で表示している
            let dateFormatter: NSDateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy MM/dd HH:mm"
            let agoTime = dateFormatter.stringFromDate(timeDate)

            cell.postLabel.text = ""
            cell.userImageView.image = UIImage(named: "noprofile")
            cell.agoTimeLabel.text = agoTime
            cell.userImageView.layer.cornerRadius = cell.userImageView.frame.width/2
            let user = commentInfo.objectForKey("actionUser") as? NCMBUser
            print("userは取れてんの？", user)
            if let user = user {
                print("userFaceName", user.objectForKey("userFaceName") as? String)
                cell.userButton.setTitle(user.objectForKey("userFaceName") as? String, forState: .Normal)
                let userImage = NCMBFile.fileWithName(user.objectForKey("userProfileImage") as? String, data: nil) as! NCMBFile
                userImage.getDataInBackgroundWithBlock({ (imageData: NSData?, error: NSError!) -> Void in
                    if let error = error {
                        print("error", error.localizedDescription)
                    } else {
                        cell.userImageView.image = UIImage(data: imageData!)
                    }
                })
            }
            let post = commentInfo.objectForKey("post") as? NCMBObject
            if let post = post {
                var postError: NSError?
                post.fetch(&postError)
                if postError == nil {
                    print("postText", post.objectForKey("text") as? String)
                    cell.postLabel.text = post.objectForKey("text") as? String
                }else {
                    print(postError!.localizedDescription)
                }
            }
            
            cell.layoutIfNeeded()
            return cell
            
        default:
            print("default")
            let cell = tableView.dequeueReusableCellWithIdentifier("followdCell", forIndexPath: indexPath) as! NotificationFollowTableViewCell
            return cell
        }

    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("何個めのCell選択", indexPath.row)
        let type = (notificationArray[indexPath.row] as! NCMBObject).objectForKey("type") as! String
        print("選択したCellのtype", type)
        
        switch type {
        case "follow":
            print("followのCellを選択 → OtherAccountViewControllerに遷移")
            selectedUser = (notificationArray[indexPath.row] as! NCMBObject).objectForKey("actionUser") as! NCMBUser
            performSegueWithIdentifier("toOtherAccountViewController", sender: nil)
            
        case "like":
            print("likeのCellを選択 → Post画面に遷移")
            print("followのCellを選択 → OtherAccountViewControllerに遷移")
            selectedObject = (notificationArray[indexPath.row] as! NCMBObject).objectForKey("post") as! NCMBObject
            performSegueWithIdentifier("toPostDetailViewController", sender: nil)

        case "comment":
            print("commnetのCellを選択 → Post画面に遷移")
            print("followのCellを選択 → OtherAccountViewControllerに遷移")
            selectedObject = (notificationArray[indexPath.row] as! NCMBObject).objectForKey("post") as! NCMBObject
            performSegueWithIdentifier("toPostDetailViewController", sender: nil)

        default:
            print("その他 ありえないprintなんですよ")
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        switch segue.identifier! as String {
        case "toOtherAccountViewController": //followのCell選択時→ユーザー画面に遷移
            guard let otherAccountViewController = segue.destinationViewController as? OtherAccountViewController else { return }
            print("selectedUser", selectedUser)
            otherAccountViewController.user = selectedUser
        
        case "toPostDetailViewController": //like、commentのCell選択時→投稿詳細画面に遷移
            guard let postDetailViewController = segue.destinationViewController as? PostDetailViewController else { return }
            print("selectedObject", selectedObject)
            postDetailViewController.postObject = selectedObject
            let auther = selectedObject.objectForKey("user") as? NCMBUser
            if let auther = auther{
                var autherError: NSError?
                auther.fetch(&autherError)
                if autherError == nil {
                    print("userFaceName", auther.objectForKey("userFaceName") as? String)
                }else {
                    print(autherError!.localizedDescription)
                }
            }
            
            if let sender = sender {
                postDetailViewController.isSelectedCommentButton = sender as! Bool
            }
            
        default:
            print("そのほかあああ")
        }
    }
}
