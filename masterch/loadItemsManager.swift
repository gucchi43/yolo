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
            //自分のみ
            postQuery.whereKey("user", equalTo: NCMBUser.currentUser())
            postQuery.orderByDescending("postDate") // cellの並べ方
            postQuery.whereKey("postDate", greaterThanOrEqualTo: CalendarManager.FilterDateStart())
            postQuery.whereKey("postDate", lessThanOrEqualTo: CalendarManager.FilterDateEnd())
            postQuery.includeKey("user")
            
            
        case 2:
            //フォローのみ
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
            //オール
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
    }

    

}
