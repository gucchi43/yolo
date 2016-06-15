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
    var notification2Array = [[String: AnyObject]]()
    var notificationArray: NSArray = NSArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.estimatedRowHeight = 200
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        //仮のデータ（コメントのNotification実装まで残しとく）
        let postObject1 = NCMBObject(className: "Post")
        let postObject2 = NCMBObject(className: "Post")
        postObject1.objectId = "dk5pFHpWntLhWUGm"
        postObject2.objectId = "fFBEVh7HxVW1JxxY"
        print("postObjectだおおおおおおおおおお", postObject1)
        
        notification2Array = [
            ["type": "follow", "user": NCMBUser.currentUser(), "time": NSDate() - 7.days - 10.hours, "post": ""],
            ["type": "like", "user": NCMBUser.currentUser(), "time": NSDate() - 4.hours, "post": postObject1],
            ["type": "comment", "user": NCMBUser.currentUser(), "time": NSDate() - 12.days - 9.hours, "post": postObject2]
        ]
        
    }
    
    override func viewWillAppear(animated: Bool) {
        loadArray()
        self.tableView.reloadData()
    }
    
    func loadArray() {
        
        let notificationQuery: NCMBQuery = NCMBQuery(className: "Notification") // 自分がフォローしている人かどうかのクエリ
        notificationQuery.whereKey("ownerUser", equalTo: NCMBUser.currentUser())
        notificationQuery.orderByDescending("updateDate") // cellの並べ方
        notificationQuery.limit = 20
        do {
            let objects:[AnyObject] = try notificationQuery.findObjects()
            if objects.count > 0{
                self.notificationArray = objects
                print("通知テーブルセルの数", objects.count)
            }else {
                self.notificationArray = []
                print("通知は０だおん…")
            }
        } catch {
            print("多分error")
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
        case "follow":
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
            cell.agoTimeLabel.text = agoTime
            cell.userImageView.layer.cornerRadius = cell.userImageView.frame.width/2
            let user = followerInfo.objectForKey("actionUser") as? NCMBUser
            print("userは取れてんの？", user)
            if let user = user {
                var postError: NSError?
                user.fetch(&postError)
                if postError == nil{
                    print("userFaceName", user.objectForKey("userFaceName") as? String)
                    cell.userButton.setTitle(user.objectForKey("userFaceName") as? String, forState: .Normal)
                    let userImage = NCMBFile.fileWithName(user.objectForKey("userProfileImage") as? String, data: nil) as! NCMBFile
                    userImage.getDataInBackgroundWithBlock({ (imageData: NSData?, error: NSError!)-> Void in
                        if let error = error {
                            print("error", error.localizedDescription)
                            cell.userImageView.image = UIImage(named: "noprofile")
                        } else {
                            cell.userImageView.image = UIImage(data: imageData!)
                        }
                    })
                }else {
                    print(postError!.localizedDescription)
                }
            }
            cell.layoutIfNeeded()
            return cell
            
        case "comment":
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
            cell.agoTimeLabel.text = agoTime
            cell.userImageView.layer.cornerRadius = cell.userImageView.frame.width/2
            let user = commentInfo.objectForKey("actionUser") as? NCMBUser
            print("userは取れてんの？", user)
            if let user = user {
                var postError: NSError?
                user.fetch(&postError)
                if postError == nil{
                    print("userFaceName", user.objectForKey("userFaceName") as? String)
                    cell.userButton.setTitle(user.objectForKey("userFaceName") as? String, forState: .Normal)
                    let userImage = NCMBFile.fileWithName(user.objectForKey("userProfileImage") as? String, data: nil) as! NCMBFile
                    
                    
                    userImage.getDataInBackgroundWithBlock({ (imageData: NSData?, error: NSError!) -> Void in
                        if let error = error {
                            print("error", error.localizedDescription)
                            cell.userImageView.image = UIImage(named: "noprofile")
                        } else {
                            print("ああああああああああああ", imageData!)
                            cell.userImageView.image = UIImage(data: imageData!)
                        }
                    })
                }else {
                    print(postError!.localizedDescription)
                }
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
        
        case "like":
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
            cell.agoTimeLabel.text = agoTime
            cell.userImageView.layer.cornerRadius = cell.userImageView.frame.width/2
            let user = likeInfo.objectForKey("actionUser") as? NCMBUser
            print("userは取れてんの？", user)
            if let user = user {
                var postError: NSError?
                user.fetch(&postError)
                if postError == nil{
                    print("userFaceName", user.objectForKey("userFaceName") as? String)
                    cell.userButton.setTitle(user.objectForKey("userFaceName") as? String, forState: .Normal)
                    let userImage = NCMBFile.fileWithName(user.objectForKey("userProfileImage") as? String, data: nil) as! NCMBFile
                    
                    
                    userImage.getDataInBackgroundWithBlock({ (imageData: NSData?, error: NSError!) -> Void in
                        if let error = error {
                            print("error", error.localizedDescription)
                            cell.userImageView.image = UIImage(named: "noprofile")
                        } else {
                            print("ああああああああああああ", imageData!)
                            cell.userImageView.image = UIImage(data: imageData!)
                        }
                    })
                }else {
                    print(postError!.localizedDescription)
                }
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

            
        default:
            print("default")
            let cell = tableView.dequeueReusableCellWithIdentifier("followdCell", forIndexPath: indexPath) as! NotificationFollowTableViewCell
            return cell
        }

    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("何個めのCell選択", indexPath.row)
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
