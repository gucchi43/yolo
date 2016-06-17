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
    }
    
    func loadArray() {
        
        //includeKeyで全部撮ってきたいんねん!!!!ほんとのところは！
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
                    print("通知テーブルセルの数", objects.count)
                    self.notificationArray = objects
                    for info in self.notificationArray{
                        let post = info.objectForKey("post") as? NCMBObject
                        if let post = post {
                            var postError: NSError?
                            post.fetch(&postError)
                            if postError == nil{
                                print("postText", post.objectForKey("text") as? String)
                                self.tableView.reloadData()
                            }else {
                                print(postError!.localizedDescription)
                            }
                        }
                    }
                }else {
                    self.notificationArray = []
                    print("通知はまだ0です……")
                    self.tableView.reloadData()
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
            let agoTime = (followerInfo.objectForKey("date") as! NSDate).timeAgo()
            print("agoTime", agoTime)
            
            cell.postLabel.text = ""
            cell.userImageView.image = UIImage(named: "noprofile")
            cell.agoTimeLabel.text = agoTime
            cell.userImageView.layer.cornerRadius = cell.userImageView.frame.width/2
            //"user"情報読み込み
            let keyUser = followerInfo.objectForKey("actionUser") as? NCMBUser
            guard let user = keyUser else { return cell } //この場合、ユーザー情報が載ってないcellがreturnされる。
            print("userFaceName", user.objectForKey("userFaceName") as? String)
            cell.userLabel.text = user.objectForKey("userFaceName") as? String
            let userImage = NCMBFile.fileWithName(user.objectForKey("userProfileImage") as? String, data: nil) as! NCMBFile
            userImage.getDataInBackgroundWithBlock({ (imageData: NSData?, error: NSError!)-> Void in
                if let error = error {
                    print("error", error.localizedDescription)
                } else {
                    cell.userImageView.image = UIImage(data: imageData!)
                }
            })
            cell.layoutIfNeeded()
            return cell
            
        case "like": //いいねのCell
            let cell = tableView.dequeueReusableCellWithIdentifier("likedCell", forIndexPath: indexPath) as! NotificationLikeTableViewCell
            let likeInfo = notificationArray[indexPath.row]
            print("likeInfo", likeInfo)
            let agoTime = (likeInfo.objectForKey("date") as! NSDate).timeAgo()
            print("agoTime", agoTime)
            
            cell.postLabel.text = ""
            cell.userImageView.image = UIImage(named: "noprofile")
            cell.agoTimeLabel.text = agoTime
            cell.userImageView.layer.cornerRadius = cell.userImageView.frame.width/2
            //"user"情報読み込み
            let keyUser = likeInfo.objectForKey("actionUser") as? NCMBUser
            guard let user = keyUser else { return cell } //この場合、ユーザー情報が載ってないcellがreturnされる。
            print("userFaceName", user.objectForKey("userFaceName") as? String)
            cell.userLabel.text = user.objectForKey("userFaceName") as? String
            let userImage = NCMBFile.fileWithName(user.objectForKey("userProfileImage") as? String, data: nil) as! NCMBFile
            userImage.getDataInBackgroundWithBlock({ (imageData: NSData?, error: NSError!)-> Void in
                if let error = error {
                    print("error", error.localizedDescription)
                } else {
                    cell.userImageView.image = UIImage(data: imageData!)
                }
            })
            //"post"情報読み込み
            let keyPost = likeInfo.objectForKey("post") as? NCMBObject
            guard let post = keyPost else { return cell } ////この場合、投稿情報が載ってないcellがreturnされる。
            print("postText", post.objectForKey("text") as? String)
            cell.postLabel.text = post.objectForKey("text") as? String
            cell.layoutIfNeeded()
            return cell

            
        case "comment": //コメントのCell
            let cell = tableView.dequeueReusableCellWithIdentifier("commentedCell", forIndexPath: indexPath) as! NotificationCommentTableViewCell
            let commentInfo = notificationArray[indexPath.row]
            print("likeInfo", commentInfo)
            let agoTime = (commentInfo.objectForKey("date") as! NSDate).timeAgo()
            print("agoTime", agoTime)

            cell.postLabel.text = ""
            cell.userImageView.image = UIImage(named: "noprofile")
            cell.agoTimeLabel.text = agoTime
            cell.userImageView.layer.cornerRadius = cell.userImageView.frame.width/2
            //"user"情報読み込み
            let keyUser = commentInfo.objectForKey("actionUser") as? NCMBUser
            guard let user = keyUser else { return cell } //この場合、ユーザー情報が載ってないcellがreturnされる。
            print("userFaceName", user.objectForKey("userFaceName") as? String)
            cell.userLabel.text = user.objectForKey("userFaceName") as? String
            let userImage = NCMBFile.fileWithName(user.objectForKey("userProfileImage") as? String, data: nil) as! NCMBFile
            userImage.getDataInBackgroundWithBlock({ (imageData: NSData?, error: NSError!)-> Void in
                if let error = error {
                    print("error", error.localizedDescription)
                } else {
                    cell.userImageView.image = UIImage(data: imageData!)
                }
            })
            //"post"情報読み込み
            let keyPost = commentInfo.objectForKey("post") as? NCMBObject
            guard let post = keyPost else { return cell } ////この場合、投稿情報が載ってないcellがreturnされる。
            print("postText", post.objectForKey("text") as? String)
            cell.postLabel.text = post.objectForKey("text") as? String
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
            let keyAuther = selectedObject.objectForKey("user") as? NCMBUser
            guard let auther = keyAuther else { return }
            var autherError: NSError?
            auther.fetch(&autherError)
            if autherError == nil {
                print("userFaceName", auther.objectForKey("userFaceName") as? String)
            }else {
                print(autherError!.localizedDescription)
            }

        default:
            print("そのほかあああ")
        }
    }
}
