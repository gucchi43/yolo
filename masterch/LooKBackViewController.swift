//
//  LooKBackViewController.swift
//  masterch
//
//  Created by HIroki Taniguti on 2016/09/30.
//  Copyright © 2016年 Fumiya Yamanaka. All rights reserved.
//

import UIKit

class LooKBackViewController: UIViewController {
    @IBAction func tapWeekButton(sender: AnyObject) {
        let lookBaclQuwryMG = LookBackQueryManager()
        let query = lookBaclQuwryMG.getOneWeekAgoQuery()
        print("一週間前の投稿", query)
    }

    @IBAction func tapMonthButton(sender: AnyObject) {
        let lookBaclQuwryMG = LookBackQueryManager()
        let query = lookBaclQuwryMG.getOneMonthAgoQuery()
        print("一ヶ月前の投稿", query)
    }

    @IBAction func tapYearButton(sender: AnyObject) {
        let lookBaclQuwryMG = LookBackQueryManager()
        let query = lookBaclQuwryMG.getOneYearAgoQuery()
        print("一年前の投稿", query)
    }


}


