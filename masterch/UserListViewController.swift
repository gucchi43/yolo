//
//  UserListViewController.swift
//  masterch
//
//  Created by Fumiya Yamanaka on 2016/06/07.
//  Copyright © 2016年 Fumiya Yamanaka. All rights reserved.
//

import UIKit

class UserListViewController: UIViewController {
    
    @IBOutlet var userListTableView: UITableView!

    var userArray = [NCMBUser]()
    var selectedUser: NCMBUser!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("UserListViewController ViewDidLoad")
        
        userListTableView.estimatedRowHeight = 50
        userListTableView.rowHeight = UITableViewAutomaticDimension
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
        performSegueWithIdentifier("toOtherAccountViewController", sender: nil)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toOtherAccountViewController" {
            guard let OtherAccountViewController = segue.destinationViewController as? OtherAccountViewController else { return }
            OtherAccountViewController.user = selectedUser
        }
    }

}
