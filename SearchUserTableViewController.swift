//
//  SearchUserTableViewController.swift
//  masterch
//
//  Created by HIroki Taniguti on 2016/05/15.
//  Copyright © 2016年 Fumiya Yamanaka. All rights reserved.
//

import UIKit

class SearchUserTableViewController: UITableViewController {
    
    var userArray: NSArray = NSArray()

    override func viewDidLoad() {
        super.viewDidLoad()
        print("SearchUserTableViewController viewDidload")
//        loadAllUser()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        loadAllUser()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func unwindToTop(segue: UIStoryboardSegue) {
        print("back to SearchView")
    }
    
    func loadAllUser(){
//        let userListQuery: NCMBQuery = NCMBUser.query()
        let userListQuery: NCMBQuery = NCMBQuery(className: "user")
//        userListQuery.orderByAscending("userName")
        userListQuery.findObjectsInBackgroundWithBlock({(NSArray objects, NSError error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                if objects.count > 0 {
                    self.userArray = objects
                    print(self.userArray)
                } else {
                    self.userArray = []
                }
                self.tableView.reloadData()
            }
        })
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userArray.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("userCell", forIndexPath: indexPath) as! SearchUserTableViewCell
        let userData = userArray[indexPath.row]
        
        cell.userFaceNameLabel.text = userData.objectForKey("userFaceName") as? String
        cell.userName.text = userData.objectForKey("userName") as? String
        cell.userImageView.layer.cornerRadius = cell.userImageView.frame.width/2
        let userImageData = NCMBFile.fileWithName("userImageProfile", data: nil) as! NCMBFile
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
