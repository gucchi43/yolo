//
//  CalendarLogCollerManager.swift
//  masterch
//
//  Created by HIroki Taniguti on 2016/06/20.
//  Copyright © 2016年 Fumiya Yamanaka. All rights reserved.
//

import UIKit
import NCMB

//monthの時
class CalendarLogCollerManager: NSObject {

//    var user: NCMBUser? = NCMBUser.currentUser()
    //LogViewの日にちごとの色を決める実行部分２ (month)
    func monthLogColorDate(date: NSDate, logNumber: Int, user: NCMBUser = NCMBUser.currentUser()) -> NCMBQuery {
        print("monthLogColorDate: date", date)
        print("monthLogColorDate: user", user)
        print("monthLogColorDate: logNumber", logNumber)

        //クエリ作成
        let logColorArrayQuery: NCMBQuery = NCMBQuery(className: "TestColorDic")

        switch logNumber { //絞っていくよーーーーーーーーーーーーー
        case 0:
            //自分のみ
            logColorArrayQuery.whereKey("user", equalTo: NCMBUser.currentUser())
            logColorArrayQuery.whereKey("logYearAndMonth", equalTo: CalendarManager.getDateYearAndMonth(date))

            return logColorArrayQuery

        case 1:
            //フォローのみ
            let relationshipQuery: NCMBQuery = NCMBQuery(className: "Relationship") // 自分がフォローしている人かどうかのクエリ
            relationshipQuery.whereKey("followed", equalTo: NCMBUser.currentUser())
            logColorArrayQuery.whereKey("user", matchesKey: "follower", inQuery: relationshipQuery)
            logColorArrayQuery.whereKey("logYearAndMonth", equalTo: CalendarManager.getDateYearAndMonth(date))

            return logColorArrayQuery
        case 2:
            //特定のアカウントのみ
            logColorArrayQuery.whereKey("user", equalTo: user)
            logColorArrayQuery.whereKey("logYearAndMonth", equalTo: CalendarManager.getDateYearAndMonth(date))

            return logColorArrayQuery

        default:
            //オール
            logColorArrayQuery.whereKey("user", equalTo: user)
            logColorArrayQuery.whereKey("logYearAndMonth", equalTo: CalendarManager.getDateYearAndMonth(date))

            return logColorArrayQuery
        }
    }
}


//weekの時
extension CalendarLogCollerManager{
    //LogViewの日にちごとの色を決める実行部分２ (week)
    func weekLogColorDate(date: NSDate, logNumber: Int, user: NCMBUser = NCMBUser.currentUser()) -> NCMBQuery {
        print("weekLogColorDate: date", date)
        print("weekLogColorDate: user", user)
        print("weekLogColorDate: logNumber", logNumber)

        //クエリの作成
        let logColorArrayQuery: NCMBQuery = NCMBQuery(className: "TestWeekColorDic")

        let yearAndWeekNumberArray = CalendarManager.getWeekNumber(date)
        let year = yearAndWeekNumberArray[0]
        let weekOfYear = yearAndWeekNumberArray[1]

        switch logNumber { //絞っていくよーーーーーーーーーーーーー
        case 0:
            //自分のみ
            logColorArrayQuery.whereKey("user", equalTo: NCMBUser.currentUser())
            logColorArrayQuery.whereKey("year", equalTo: year)
            logColorArrayQuery.whereKey("weekOfYear", equalTo: weekOfYear)

            return logColorArrayQuery

        case 1:
            //フォローのみ
            let relationshipQuery: NCMBQuery = NCMBQuery(className: "Relationship") // 自分がフォローしている人かどうかのクエリ
            relationshipQuery.whereKey("followed", equalTo: NCMBUser.currentUser())
            logColorArrayQuery.whereKey("user", matchesKey: "follower", inQuery: relationshipQuery)
            logColorArrayQuery.whereKey("year", equalTo: year)
            logColorArrayQuery.whereKey("weekOfYear", equalTo: weekOfYear)

            return logColorArrayQuery


        case 2:
            //特定のアカウントのみ
            logColorArrayQuery.whereKey("user", equalTo: user)
            logColorArrayQuery.whereKey("year", equalTo: year)
            logColorArrayQuery.whereKey("weekOfYear", equalTo: weekOfYear)

            return logColorArrayQuery

        default:
            //オール
            logColorArrayQuery.whereKey("user", equalTo: NCMBUser.currentUser())
            logColorArrayQuery.whereKey("year", equalTo: year)
            logColorArrayQuery.whereKey("weekOfYear", equalTo: weekOfYear)

            return logColorArrayQuery

        }
    }



}
