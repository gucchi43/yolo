//
//  UserListViewController.swift
//  masterch
//
//  Created by Fumiya Yamanaka on 2016/06/07.
//  Copyright © 2016年 Fumiya Yamanaka. All rights reserved.
//

import UIKit
import SVProgressHUD
import DZNEmptyDataSet

class UserListViewController: UIViewController {
    
    @IBOutlet var userListTableView: UITableView!

    var userArray = [NCMBUser]()
    var selectedUser: NCMBUser!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("UserListViewController ViewDidLoad")
        
        userListTableView.estimatedRowHeight = 50
        userListTableView.rowHeight = UITableViewAutomaticDimension
        userListTableView.tableFooterView = UIView()
        userListTableView.emptyDataSetSource = self
        userListTableView.emptyDataSetDelegate = self

    }
    
    override func viewWillAppear(animated: Bool) {
        let nib = UINib(nibName: "UserListTableViewCell", bundle: nil)
        userListTableView.registerNib(nib, forCellReuseIdentifier: "userCell")
        
        if let indexPathForSelectedRow = userListTableView.indexPathForSelectedRow {
            userListTableView.deselectRowAtIndexPath(indexPathForSelectedRow, animated: true)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension UserListViewController: UITableViewDataSource {
    //        cellの数
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userArray.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("userCell") as! UserListTableViewCell
        
        cell.userNameLabel.text = userArray[indexPath.row].userName
        cell.userFaceNameLabel.text = userArray[indexPath.row].objectForKey("userFaceName") as? String

        let userImageData = NCMBFile.fileWithName(userArray[indexPath.row].objectForKey("userProfileImage") as? String, data: nil) as! NCMBFile
        userImageData.getDataInBackgroundWithBlock({ (imageData: NSData?, error: NSError!) -> Void in
            if let error = error {
                print("プロフィール画像の取得失敗： ", error)
                cell.userImageView.image = UIImage(named: "noprofile")
            } else {
                cell.userImageView.image = UIImage(data: imageData!)
                
            }
        })
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("セルの選択: \(indexPath.row)")

        selectedUser = userArray[indexPath.row]
        print(selectedUser)
        performSegueWithIdentifier("toAccountVC", sender: nil)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toAccountVC" {
            guard let accountVC = segue.destinationViewController as? AccountViewController else { return }
            accountVC.user = selectedUser
        }
    }

}

extension UserListViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate{
    //------------------DZNEmptyDataSet(セルが無い時に表示するViewの設定--------------------

    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let str = "😳ドンマイ！😳"
        let attrs = [NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)]
        return NSAttributedString(string: str, attributes: attrs)
    }

    func descriptionForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let str = "まだユーザーがいないよ"
        let attrs = [NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleBody)]
        return NSAttributedString(string: str, attributes: attrs)
    }
    //
    //        func imageForEmptyDataSet(scrollView: UIScrollView!) -> UIImage! {
    //            return UIImage(named: "noprofile")
    //        }

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

