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
//        loadAllUser()
        
        
        let nib = UINib(nibName: "UserListTableViewCell", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: "userCell")
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        
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
        }else {
            userData = filterUsers[indexPath.row]
            //こっちの場合は最初に全ユーザー表示
//            userData = userArray[indexPath.row]
        }
        
        let userFaceName = userData!.objectForKey("userFaceName") as? String
        let userName = userData!.objectForKey("userName") as? String
        cell.userFaceNameLabel.text = userFaceName!
        cell.userName.text = "@" + userName!
//        userFaceNameArray.append(userFaceName!)
//        userNameArray.append(userName!)
//        
//        print("userNameArray", userNameArray, "userFaceName", userFaceNameArray, "userArray", userArray)

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

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("セルの選択: \(indexPath.row)")

        selectedUser = self.filterUsers[indexPath.row] as! NCMBUser
        print(selectedUser)
        performSegueWithIdentifier("toOtherAccountViewController", sender: nil)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toOtherAccountViewController" {
            if let OtherAccountViewController = segue.destinationViewController as? OtherAccountViewController{
                OtherAccountViewController.user = selectedUser
            }
        }
    }

}

extension SearchUserTableViewController: UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filterContextSearchText(searchController.searchBar.text!)
    }
    
}
