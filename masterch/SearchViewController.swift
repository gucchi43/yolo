////
////  SearchViewController.swift
////  masterch
////
////  Created by Fumiya Yamanaka on 2016/02/09.
////  Copyright © 2016年 Fumiya Yamanaka. All rights reserved.
////
//
//import UIKit
//
//class SearchViewController: UIViewController, UISearchBarDelegate {
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        // Do any additional setup after loading the view, typically from a nib.
//        print("SearchViewController")
//    }
//    
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }
//    @IBAction func unwindToTop(segue: UIStoryboardSegue) {
//        print("back to SearchView")
//    }
//    
//}
//
//extension SearchViewController {
//    
//    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
//        let userName = searchBar.text
//        
//        //nil防止&文字入力確認
//        if userName?.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0 {
//            searchUser(userName!)
//        }
//    }
//    
//    func searchUser(userName: String){
//        let userListQuery: NCMBQuery = NCMBQuery(className: "user")
//        userListQuery.whereKey("userName", equalTo: userName)
//        userListQuery.findObjectsInBackgroundWithBlock { (objectArray, error) -> Void in
//            if let error = error {
//                print(error.localizedDescription)
//            }else {
//                if objectArray.isEmpty == false{ //userがあった
//                    print(objectArray)
//                }else{ //userがなかった
//                    print("userがいません")
//                }
//            }
//        }
//    }
//}