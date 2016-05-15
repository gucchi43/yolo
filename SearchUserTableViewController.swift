//
//  SearchUserTableViewController.swift
//  masterch
//
//  Created by HIroki Taniguti on 2016/05/15.
//  Copyright © 2016年 Fumiya Yamanaka. All rights reserved.
//

import UIKit

class SearchUserTableViewController: UITableViewController {
    
    var userInfo: NSArray = NSArray()
    var userArray: NSArray = NSArray()
    var userNameArray = [String]()
    var userFaceNameArray = [String]()
    var aaa = []
    var filterUsers: NSArray = NSArray()
    let searchController = UISearchController(searchResultsController: nil)
    
    
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
    
    @IBAction func unwindToTop(segue: UIStoryboardSegue) {
        print("back to SearchView")
    }

    func loadAllUser(){
//        let userListQuery: NCMBQuery = NCMBUser.query()
        let userListQuery: NCMBQuery = NCMBQuery(className: "user")
        userListQuery.orderByAscending("userName")
        userListQuery.findObjectsInBackgroundWithBlock({(NSArray objects, NSError error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                if objects.count > 0 {
                    self.userInfo = objects

                    self.userArray = self.userInfo
//                    self.filterUsers = self.userInfo
                    
                    print(self.userArray)
                } else {
                    self.userInfo = []
                    
                    self.userArray = self.userInfo
//                    self.filterUsers = self.userInfo
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
            return userArray.count
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("userCell", forIndexPath: indexPath) as! SearchUserTableViewCell
        let userData: AnyObject?
        
        if searchController.active && searchController.searchBar.text != "" {
            userData = filterUsers[indexPath.row]
        }else {
            userData = userArray[indexPath.row]
        }

        cell.userFaceNameLabel.text = userData!.objectForKey("userFaceName") as? String
        cell.userName.text = userData!.objectForKey("userName") as? String
        
        userNameArray.append(cell.userName.text!)
        userFaceNameArray.append(cell.userFaceNameLabel.text!)
        
        print("userNameArray", userNameArray, "userFaceName", userFaceNameArray, "userArray", userArray)
        
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
}

extension SearchUserTableViewController: UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filterContextSearchText(searchController.searchBar.text!)
    }
    
}
