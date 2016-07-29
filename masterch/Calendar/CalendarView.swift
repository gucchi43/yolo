//
//  CalendarView.swift
//  CrossCalendarSample
//
//  Created by Eisuke Sato on 2016/02/19.
//  Copyright © 2016年 Eisuke Sato. All rights reserved.
//

import UIKit
import SwiftDate

class CalendarView: UIView, UIScrollViewDelegate {
    var horizontalScrollView: UIScrollView!
    var verticalScrollView: UIScrollView!
    
    var currentMonthView: CalendarMonthView!
    var prevMonthView: CalendarMonthView!
    var nextMonthView: CalendarMonthView!
    var lastYearMonthView: CalendarMonthView!
    var nextYearMonthView: CalendarMonthView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    func commonInit() {
        print(self.frame)
        CalendarManager.setCurrentDate()
        horizontalScrollView = UIScrollView(frame: frame)
        verticalScrollView = UIScrollView(frame: CGRect(origin: CGPoint(x: CGRectGetWidth(frame), y: 0), size: frame.size))
        
        horizontalScrollView.delegate = self
        verticalScrollView.delegate = self
        
        horizontalScrollView.showsHorizontalScrollIndicator = false
        verticalScrollView.showsVerticalScrollIndicator = false
        
        // horizontalにaddする
        
        //翌月
        prevMonthView = CalendarMonthView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: frame.size), date: CalendarManager.currentDate - (CalendarManager.currentDate.day - 1).days - 1.months)
        nextMonthView = CalendarMonthView(frame: CGRect(origin: CGPoint(x: CGRectGetWidth(frame) * 2, y: 0), size: frame.size), date: CalendarManager.currentDate - (CalendarManager.currentDate.day - 1).days + 1.months)
        
        // verticalにaddするviews
        lastYearMonthView = CalendarMonthView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: frame.size), date: CalendarManager.currentDate - (CalendarManager.currentDate.day - 1).days - 1.years)
        currentMonthView  = CalendarMonthView(frame: CGRect(origin: CGPoint(x: 0, y: CGRectGetHeight(frame)), size: frame.size), date: CalendarManager.currentDate - (CalendarManager.currentDate.day - 1).days)
        nextYearMonthView = CalendarMonthView(frame: CGRect(origin: CGPoint(x: 0, y: CGRectGetHeight(frame) * 2), size: frame.size), date: CalendarManager.currentDate - (CalendarManager.currentDate.day - 1).days + 1.years)
        
        self.addSubview(horizontalScrollView)
        
        horizontalScrollView.addSubview(prevMonthView)
        horizontalScrollView .addSubview(verticalScrollView)
        horizontalScrollView.addSubview(nextMonthView)
        
        verticalScrollView.addSubview(lastYearMonthView)
        verticalScrollView.addSubview(currentMonthView)
        verticalScrollView.addSubview(nextYearMonthView)
        
        // scrollViewの設定
        horizontalScrollView.pagingEnabled = true
        horizontalScrollView.contentSize = CGSize(width: CGRectGetWidth(frame) * 3, height: CGRectGetHeight(frame))
        horizontalScrollView.contentOffset = CGPoint(x: CGRectGetWidth(frame), y: 0)
        
        verticalScrollView.pagingEnabled = true
        verticalScrollView.contentSize = CGSize(width: CGRectGetWidth(frame), height: CGRectGetHeight(frame) * 3)
        verticalScrollView.contentOffset = CGPoint(x: 0, y: CGRectGetHeight(frame))
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.isEqual(verticalScrollView) {
            let pos: CGFloat  = scrollView.contentOffset.y / scrollView.bounds.size.height
            let deff: CGFloat = pos - 1.0
            if fabs(deff) >= 1.0 {
                if (deff > 0) {
                    self.showNextYearView()
                } else {
                    self.showPrevYearView()
                }
            }
        } else if scrollView.isEqual(horizontalScrollView) {
            let pos: CGFloat  = scrollView.contentOffset.x / scrollView.bounds.size.width
            let deff: CGFloat = pos - 1.0
            if fabs(deff) >= 1.0 {
                if (deff > 0) {
                    self.showNextMonthView()
                } else {
                    self.showPrevMonthView()
                }
            }
        }
    }
    
    func showNextMonthView (){
        CalendarManager.currentDate = CalendarManager.currentDate + 1.months
        resetMonthView()
        self.resetContentOffSet(horizontalScrollView)
    }
    
    func showPrevMonthView () {
        CalendarManager.currentDate = CalendarManager.currentDate - 1.months
        resetMonthView()
        self.resetContentOffSet(horizontalScrollView)
    }
    
    func showNextYearView (){
        CalendarManager.currentDate = CalendarManager.currentDate + 1.years
        resetMonthView()
        self.resetContentOffSet(verticalScrollView)
    }
    
    func showPrevYearView () {
        CalendarManager.currentDate = CalendarManager.currentDate - 1.years
        resetMonthView()
        self.resetContentOffSet(verticalScrollView)
    }
    
    func resetMonthView() {
        print("カレントデイト", CalendarManager.currentDate)
        currentMonthView.startSetUpDays(CalendarManager.currentDate - (CalendarManager.currentDate.day - 1).days)
        prevMonthView.setUpDays(CalendarManager.currentDate - (CalendarManager.currentDate.day - 1).days - 1.months)
        nextMonthView.setUpDays(CalendarManager.currentDate - (CalendarManager.currentDate.day - 1).days + 1.months)
        nextYearMonthView.setUpDays(CalendarManager.currentDate - (CalendarManager.currentDate.day - 1).days + 1.years)
        lastYearMonthView.setUpDays(CalendarManager.currentDate - (CalendarManager.currentDate.day - 1).days - 1.years)
        
        let n = NSNotification(name: "didSelectDayView", object: self, userInfo: nil)
        NSNotificationCenter.defaultCenter().postNotification(n)
    }
    
    func resetContentOffSet (scrollView: UIScrollView) {
        lastYearMonthView.frame = CGRect(origin: CGPointZero, size: frame.size)
        currentMonthView.frame = CGRect(origin: CGPoint(x: 0, y: CGRectGetHeight(frame)), size: frame.size)
        nextYearMonthView.frame = CGRect(origin: CGPoint(x: 0, y: CGRectGetHeight(frame) * 2), size: frame.size)
        
        let scrollViewDelegate:UIScrollViewDelegate = scrollView.delegate!
        scrollView.delegate = nil
        
        // scrollViewDidScrollを呼ばないため
        horizontalScrollView.contentOffset = CGPoint(x: CGRectGetWidth(frame), y: 0)
        verticalScrollView.contentOffset = CGPoint(x: 0, y: CGRectGetHeight(frame))
        scrollView.delegate = scrollViewDelegate
    }
    
    func getNow (){
        let today = NSDate()
        CalendarManager.currentDate = today
        resetMonthView()

    }
}
