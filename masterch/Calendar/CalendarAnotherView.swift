//
//  CalendarAnotherView.swift
//  masterch
//
//  Created by HIroki Taniguti on 2016/02/28.
//  Copyright © 2016年 Fumiya Yamanaka. All rights reserved.
//

import UIKit
import SwiftDate

class CalendarAnotherView : UIView, UIScrollViewDelegate {
    
    var horizontalScrollView: UIScrollView!
    
    var currentWeekView: CalendarWeekView!
    var prevWeekView: CalendarWeekView!
    var nextWeekView: CalendarWeekView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    func commonInit(){
        print("commonInit")
        
        print(self.frame)
        horizontalScrollView = UIScrollView(frame: frame)
        
        horizontalScrollView.delegate = self
        
        horizontalScrollView.showsHorizontalScrollIndicator = false
        
        
        // horizontalにaddする
        currentWeekView = CalendarWeekView(frame: CGRect(origin:CGPoint (x: CGRectGetWidth(frame), y: 0), size: frame.size), date: CalendarManager.currentDate - (CalendarManager.currentDate.weekday - 1).days)
        
        prevWeekView = CalendarWeekView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: frame.size), date: CalendarManager.currentDate - (CalendarManager.currentDate.weekday - 1).days - 7.days)
        
        nextWeekView = CalendarWeekView(frame: CGRect(origin: CGPoint(x: CGRectGetWidth(frame) * 2, y: 0), size: frame.size),  date: CalendarManager.currentDate - (CalendarManager.currentDate.weekday - 1).days + 7.days)
        
        self.addSubview(horizontalScrollView)
        
        horizontalScrollView.addSubview(currentWeekView)
        horizontalScrollView.addSubview(prevWeekView)
        horizontalScrollView.addSubview(nextWeekView)
        
        // scrollViewの設定
        horizontalScrollView.pagingEnabled = true
        horizontalScrollView.contentSize = CGSize(width: CGRectGetWidth(frame) * 3, height: CGRectGetHeight(frame))
        horizontalScrollView.contentOffset = CGPoint(x: CGRectGetWidth(frame), y: 0)
        
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let pos: CGFloat  = scrollView.contentOffset.x / scrollView.bounds.size.width
        let deff: CGFloat = pos - 1.0
        if fabs(deff) >= 1.0 {
            if (deff > 0) {
                self.showNextWeekView()
            } else {
                self.showPrevWeekView()
            }
        }
    }
    
    func showNextWeekView (){
        CalendarManager.currentDate = CalendarManager.currentDate + 7.days
        resetWeekView()
        self.resetContentOffSet(horizontalScrollView)
    }
    
    func showPrevWeekView () {
        CalendarManager.currentDate = CalendarManager.currentDate - 7.days
        resetWeekView()
        self.resetContentOffSet(horizontalScrollView)
    }
    
    func resetWeekView(array: [AnyObject] = []) {
        currentWeekView.startSetUpDays(CalendarManager.currentDate - (CalendarManager.currentDate.weekday - 1).days)
        prevWeekView.setUpDays(CalendarManager.currentDate - (CalendarManager.currentDate.weekday - 1).days - 7.days)
        nextWeekView.setUpDays(CalendarManager.currentDate - (CalendarManager.currentDate.weekday - 1).days + 7.days)
        var userInfo = [String : AnyObject]()
        if array.isEmpty{
            let n = NSNotification(name: "didSelectDayView", object: self, userInfo: nil)
            NSNotificationCenter.defaultCenter().postNotification(n)
        }else {
            userInfo = ["today": array]
            let n = NSNotification(name: "didSelectDayView", object: self, userInfo: userInfo)
            NSNotificationCenter.defaultCenter().postNotification(n)
        }
    }
    
    func resetContentOffSet (scrollView: UIScrollView) {
        print("resetContentOffSet")
        let scrollViewDelegate:UIScrollViewDelegate = scrollView.delegate!
        scrollView.delegate = nil
        
        // scrollViewDidScrollを呼ばないため
        horizontalScrollView.contentOffset = CGPoint(x: CGRectGetWidth(frame), y: 0)
        scrollView.delegate = scrollViewDelegate
    }
    
    func getNow (){
        let today = NSDate()
        CalendarManager.currentDate = today
        resetWeekView()
    }
    
}

