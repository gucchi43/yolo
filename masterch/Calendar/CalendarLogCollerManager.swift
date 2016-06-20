//
//  CalendarLogCollerManager.swift
//  masterch
//
//  Created by HIroki Taniguti on 2016/06/20.
//  Copyright © 2016年 Fumiya Yamanaka. All rights reserved.
//

import UIKit

class CalendarLogCollerManager: NSObject {
    
    //LogViewの日にちごとの色を決める実行部分２ (week)
    func weekLogColorDate(date: NSDate, range: Int) -> NCMBQuery {
        //クエリの作成
        let logColorQuery: NCMBQuery = NCMBQuery(className: "LogColor") // LogCollerのクエリ
        
        switch range { //絞っていくよーーーーーーーーーーーーー
        case 1:
            //自分のみ
            logColorQuery.whereKey("user", equalTo: NCMBUser.currentUser())
        case 2:
            //フォローのみ
            let relationshipQuery: NCMBQuery = NCMBQuery(className: "Relationship") // 自分がフォローしている人かどうかのクエリ
            relationshipQuery.whereKey("followed", equalTo: NCMBUser.currentUser())
            relationshipQuery.whereKey("follower", matchesKey: "user", inQuery: NCMBQuery(className: "LogColor"))
            logColorQuery.whereKey("user", matchesKey: "follower", inQuery: relationshipQuery)
            logColorQuery.whereKey("user", notEqualTo: NCMBUser.currentUser()) //自分で自分をフォローしていた場合自分を外す
        default:
            //オール
            logColorQuery.whereKey("user", equalTo: NCMBUser.currentUser())
        }
        
        ////共通のクエリの範囲指定、順番と日にちの範囲指定
        logColorQuery.whereKey("logDate", greaterThanOrEqualTo: CalendarManager.getDateWeekOfMin(date))
        logColorQuery.whereKey("logDate", lessThanOrEqualTo: CalendarManager.getDateWeekOfMax(date))
        logColorQuery.orderByAscending("logDate")
        return logColorQuery
    }
    
    
    //LogViewの日にちごとの色を決める実行部分２ (month)
    func monthLogColorDate(date: NSDate, range: Int) -> NCMBQuery {
        //クエリ作成
        let logColorQuery: NCMBQuery = NCMBQuery(className: "LogColor") // LogCollerのクエリ
        
        switch range { //絞っていくよーーーーーーーーーーーーー
        case 1:
            //自分のみ
            logColorQuery.whereKey("user", equalTo: NCMBUser.currentUser())
        case 2:
            //フォローのみ
            let relationshipQuery: NCMBQuery = NCMBQuery(className: "Relationship") // 自分がフォローしている人かどうかのクエリ
            relationshipQuery.whereKey("followed", equalTo: NCMBUser.currentUser())
            relationshipQuery.whereKey("follower", matchesKey: "user", inQuery: NCMBQuery(className: "LogColor"))
            logColorQuery.whereKey("user", matchesKey: "follower", inQuery: relationshipQuery)
            logColorQuery.whereKey("user", notEqualTo: NCMBUser.currentUser()) //自分で自分をフォローしていた場合自分を外す
        default:
            //オール
            logColorQuery.whereKey("user", equalTo: NCMBUser.currentUser())
        }
        
        //共通のクエリの範囲指定、順番と日にちの範囲指定
        logColorQuery.whereKey("logYearAndMonth", equalTo: CalendarManager.getDateYearAndMonth(date))
        logColorQuery.orderByAscending("logDate")
        return logColorQuery
        
    }

}
