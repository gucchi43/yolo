//
//  LogQueryManager.swift
//  masterch
//
//  Created by HIroki Taniguti on 2016/06/21.
//  Copyright © 2016年 Fumiya Yamanaka. All rights reserved.
//

import UIKit


final class logManager {
    private init() {
    }
    static let sharedSingleton = logManager()
    var logNumber: Int = 0
    var tabLogNumber: Int = 0
    var logUser: NCMBUser = NCMBUser.currentUser()
    var logTitleToggle: Bool = true

    func resetSharedSingleton() {
        logNumber = 0
        tabLogNumber = 0
        logUser = NCMBUser.currentUser()
        logTitleToggle = true
    }
}




class LogQueryManager: NSObject {
    
    func loadItems(logNumber: Int, user: NCMBUser = NCMBUser.currentUser()) -> NCMBQuery {
        print("LogQueryManager: userName", user.userName)
        print("LogQueryManager: logNumber", logNumber)

        //クエリの作成
        var postQuery: NCMBQuery = NCMBQuery(className: "Post")
        switch logNumber { //絞っていくよーーーーーーーーーーーーー
        case 0:
            //自分のみ
            postQuery.whereKey("user", equalTo: NCMBUser.currentUser())
            postQuery.orderByDescending("postDate") // cellの並べ方
            postQuery.whereKey("postDate", greaterThanOrEqualTo: CalendarManager.FilterDateStart())
            postQuery.whereKey("postDate", lessThanOrEqualTo: CalendarManager.FilterDateEnd())
            postQuery.includeKey("user")
            
            
        case 1:
            //フォローのみ
            let relationshipQuery: NCMBQuery = NCMBQuery(className: "Relationship") // 自分がフォローしている人かどうかのクエリ
            relationshipQuery.whereKey("followed", equalTo: NCMBUser.currentUser())
            //これはなに」？
//            relationshipQuery.whereKey("follower", matchesKey: "user", inQuery: NCMBQuery(className: "Post"))
            postQuery.whereKey("user", matchesKey: "follower", inQuery: relationshipQuery)// 自分がフォローしている人の投稿クエリ
            postQuery.whereKey("secretKey", notEqualTo: true) // secretKeyがtrueではないもの(鍵が付いていないもの)を表示(nil, false)
            postQuery.whereKey("user", notEqualTo: NCMBUser.currentUser())//自分がフォロワーに含まれてたら自分は表示しない
            postQuery.orderByDescending("postDate") // cellの並べ方
            postQuery.whereKey("postDate", greaterThanOrEqualTo: CalendarManager.FilterDateStart())
            postQuery.whereKey("postDate", lessThanOrEqualTo: CalendarManager.FilterDateEnd())
            postQuery.includeKey("user")

        case 2:
            //特定のアカウントのみ
            postQuery.whereKey("user", equalTo: user)
            postQuery.whereKey("secretKey", notEqualTo: true) // secretKeyがtrueではないもの(鍵が付いていないもの)を表示(nil, false)
            postQuery.orderByDescending("postDate") // cellの並べ方
            postQuery.whereKey("postDate", greaterThanOrEqualTo: CalendarManager.FilterDateStart())
            postQuery.whereKey("postDate", lessThanOrEqualTo: CalendarManager.FilterDateEnd())
            postQuery.includeKey("user")


        default:
            //オール(自分＆フォローしているユーザー)
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
        
        //共通のクエリの範囲指定、順番と日にちの範囲指定とincludeKey
        //        postQuery.orderByDescending("postDate") // cellの並べ方
        //        postQuery.whereKey("postDate", greaterThanOrEqualTo: CalendarManager.FilterDateStart())
        //        postQuery.whereKey("postDate", lessThanOrEqualTo: CalendarManager.FilterDateEnd())
        //        postQuery.includeKey("user")
        return postQuery
    }
    
    
    
}
