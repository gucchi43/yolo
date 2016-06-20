//
//  LoadItemsManager.swift
//  masterch
//
//  Created by HIroki Taniguti on 2016/06/20.
//  Copyright © 2016年 Fumiya Yamanaka. All rights reserved.
//

import UIKit

class LoadItemsManager: NSObject {
    
    
    
    func loadItems(range: Int) -> NCMBQuery {
        var postQuery: NCMBQuery = NCMBQuery(className: "Post")
        switch range {
        case 1:
            postQuery.whereKey("user", equalTo: NCMBUser.currentUser())
            postQuery.orderByDescending("postDate") // cellの並べ方
            postQuery.whereKey("postDate", greaterThanOrEqualTo: CalendarManager.FilterDateStart())
            postQuery.whereKey("postDate", lessThanOrEqualTo: CalendarManager.FilterDateEnd())
            postQuery.includeKey("user")
            
            
        case 2:
            let relationshipQuery: NCMBQuery = NCMBQuery(className: "Relationship") // 自分がフォローしている人かどうかのクエリ
            relationshipQuery.whereKey("followed", equalTo: NCMBUser.currentUser())
            relationshipQuery.whereKey("follower", matchesKey: "user", inQuery: NCMBQuery(className: "Post"))
            postQuery.whereKey("user", matchesKey: "follower", inQuery: relationshipQuery)// 自分がフォローしている人の投稿クエリ
            postQuery.whereKey("secretKey", notEqualTo: true) // secretKeyがtrueではないもの(鍵が付いていないもの)を表示(nil, false)
            postQuery.whereKey("user", notEqualTo: NCMBUser.currentUser())//自分がフォロワーに含まれてたら自分は表示しない
            postQuery.orderByDescending("postDate") // cellの並べ方
            postQuery.whereKey("postDate", greaterThanOrEqualTo: CalendarManager.FilterDateStart())
            postQuery.whereKey("postDate", lessThanOrEqualTo: CalendarManager.FilterDateEnd())
            postQuery.includeKey("user")
            
            
        default:
            let myPostQuery: NCMBQuery = NCMBQuery(className: "Post") // 自分の投稿クエリ
            myPostQuery.whereKey("user", equalTo: NCMBUser.currentUser())
            
            let relationshipQuery: NCMBQuery = NCMBQuery(className: "Relationship") // 自分がフォローしている人かどうかのクエリ
            relationshipQuery.whereKey("followed", equalTo: NCMBUser.currentUser())
            relationshipQuery.whereKey("follower", matchesKey: "user", inQuery: NCMBQuery(className: "Post"))
            
            let followingQuery: NCMBQuery = NCMBQuery(className: "Post") // 自分がフォローしている人の投稿クエリ
            followingQuery.whereKey("user", matchesKey: "follower", inQuery: relationshipQuery)
            followingQuery.whereKey("secretKey", notEqualTo: true) // secretKeyがtrueではないもの(鍵が付いていないもの)を表示(nil, false)
            
            postQuery = NCMBQuery.orQueryWithSubqueries([myPostQuery, followingQuery]) // クエリの合成
            postQuery.orderByDescending("postDate") // cellの並べ方
            postQuery.whereKey("postDate", greaterThanOrEqualTo: CalendarManager.FilterDateStart())
            postQuery.whereKey("postDate", lessThanOrEqualTo: CalendarManager.FilterDateEnd())
            postQuery.includeKey("user")
            
        }
        
        return postQuery
        
        
//        postQuery.findObjectsInBackgroundWithBlock({(objects, error) in
//            if let error = error {
//                print(error.localizedDescription)
//            } else {
//                let logViewController = LogViewController()
//                print("投稿数", objects.count)
//                if objects.count > 0 {
//                    logViewController.postArray = objects
////                    self.postArray = objects
//                } else {
//                    logViewController.postArray = []
////                    self.postArray = []
//                }
//                let a = logViewController.tableView
//                a!.reloadData()
////                self.tableView.reloadData()
//            }
//        })
    }

    

}
