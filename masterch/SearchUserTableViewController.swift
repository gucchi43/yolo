//
//  SearchUserTableViewController.swift
//  masterch
//
//  Created by HIroki Taniguti on 2016/05/15.
//  Copyright © 2016年 Fumiya Yamanaka. All rights reserved.
//

import UIKit
import SVProgressHUD
import NCMB
import DZNEmptyDataSet

class SearchUserTableViewController: UITableViewController {
    
    var userArray: NSArray = NSArray()
    var userNameArray = [String]()
    var userFaceNameArray = [String]()
    var filterUsers: NSArray = NSArray()
    let searchController = UISearchController(searchResultsController: nil)

    var selectedUser: NCMBUser!

    func filterContextSearchText(searchText: String, scope: String = "All"){
        
        print("searchText", searchText)
        filterUsers = userArray.filter{ userArray in
            print("return結果", userArray.objectForKey("userName")!.lowercaseString.containsString(searchText.lowercaseString))
            
            print("filterUsers.count", filterUsers.count)
            return userArray.objectForKey("userName")!.lowercaseString.containsString(searchText.lowercaseString) || userArray.objectForKey("userFaceName")!.lowercaseString.containsString(searchText.lowercaseString)
        }
        tableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        print("SearchUserTableViewController viewDidload")
                
        let nib = UINib(nibName: "UserListTableViewCell", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: "userCell")
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        tableView.tableFooterView = UIView()
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self

    }
    
    override func viewWillAppear(animated: Bool) {
        loadAllUser()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func loadAllUser(){
        let userListQuery: NCMBQuery = NCMBQuery(className: "user")
        userListQuery.orderByAscending("updateDate")
        userListQuery.findObjectsInBackgroundWithBlock({(objects, error) in
            SVProgressHUD.show()
            if let error = error {
                print(error.localizedDescription)
                SVProgressHUD.dismiss()
            } else {
                if objects.count > 0 {
                    self.userArray = objects
                    print(self.userArray)
                } else {
                    self.userArray = []
                }
                SVProgressHUD.dismiss()
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
        if searchController.active && searchController.searchBar.text != "" {
            return filterUsers.count
        }else {
            return filterUsers.count
            //こっちの場合は最初に全ユーザー表示
//            return userArray.count
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("userCell", forIndexPath: indexPath) as! UserListTableViewCell
        let userData: AnyObject?
        
        if searchController.active && searchController.searchBar.text != "" {
            userData = filterUsers[indexPath.row]
            tableView.emptyDataSetSource = self
            tableView.emptyDataSetDelegate = self
        }else {
            userData = filterUsers[indexPath.row]
            tableView.emptyDataSetSource = self
            tableView.emptyDataSetDelegate = self
            //こっちの場合は最初に全ユーザー表示
//            userData = userArray[indexPath.row]
        }
        
        let userFaceName = userData!.objectForKey("userFaceName") as? String
        let userName = userData!.objectForKey("userName") as? String
        cell.userFaceNameLabel.text = userFaceName!
        cell.userNameLabel.text = "@" + userName!
//        userFaceNameArray.append(userFaceName!)
//        userNameArray.append(userName!)
//        
//        print("userNameArray", userNameArray, "userFaceName", userFaceNameArray, "userArray", userArray)

        cell.userImageView.layer.cornerRadius = cell.userImageView.frame.width/2
        let userImageData = NCMBFile.fileWithName(userData!.objectForKey("userProfileImage") as? String, data: nil) as! NCMBFile
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

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("セルの選択: \(indexPath.row)")

        selectedUser = self.filterUsers[indexPath.row] as! NCMBUser
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

extension SearchUserTableViewController: UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filterContextSearchText(searchController.searchBar.text!)
    }
    
}

extension SearchUserTableViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate{
    //------------------DZNEmptyDataSet(セルが無い時に表示するViewの設定--------------------

    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let str = "😎新しい友だちを見つけよう😎"
        let attrs = [NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)]
        return NSAttributedString(string: str, attributes: attrs)
    }

    func descriptionForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let str = "一致するユーザーがいないっす…"
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
