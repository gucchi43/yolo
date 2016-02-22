//
//  CalendarView.swift
//  CrossCalendarSample
//
//  Created by Eisuke Sato on 2016/02/19.
//  Copyright © 2016年 Eisuke Sato. All rights reserved.
//

import UIKit

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
        CalendarManager.sharedInstance.setCurrentDate()
        horizontalScrollView = UIScrollView(frame: frame)
        verticalScrollView = UIScrollView(frame: CGRect(origin: CGPoint(x: CGRectGetWidth(frame), y: 0), size: frame.size))
        
        horizontalScrollView.delegate = self
        verticalScrollView.delegate = self
        
        // horizontalにaddする
        
        //翌月
        var ret = CalendarManager.getPrevYearAndMonth()
        prevMonthView = CalendarMonthView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: frame.size), year: ret.year, month: ret.month)
        ret = CalendarManager.getNextYearAndMonth()
        nextMonthView = CalendarMonthView(frame: CGRect(origin: CGPoint(x: CGRectGetWidth(frame) * 2, y: 0), size: frame.size), year: ret.year, month: ret.month)
        
        // verticalにaddするviews
        
        ret = CalendarManager.getLastYear()
        lastYearMonthView = CalendarMonthView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: frame.size), year: ret.year, month: ret.month)
        currentMonthView  = CalendarMonthView(frame: CGRect(origin: CGPoint(x: 0, y: CGRectGetHeight(frame)), size: frame.size), year: CalendarManager.sharedInstance.currentYear, month: CalendarManager.sharedInstance.currentMonth)
        ret = CalendarManager.getNextYear()
        nextYearMonthView = CalendarMonthView(frame: CGRect(origin: CGPoint(x: 0, y: CGRectGetHeight(frame) * 2), size: frame.size), year: ret.year, month: ret.month)
        
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
        CalendarManager.sharedInstance.currentMonth++;
        if( CalendarManager.sharedInstance.currentMonth > 12 ){
            CalendarManager.sharedInstance.currentMonth = 1;
            CalendarManager.sharedInstance.currentYear++;
        }
        
        resetMonthView()
        self.resetContentOffSet(horizontalScrollView)
    }
    
    func showPrevMonthView () {
        CalendarManager.sharedInstance.currentMonth--
        if( CalendarManager.sharedInstance.currentMonth == 0 ){
            CalendarManager.sharedInstance.currentMonth = 12
            CalendarManager.sharedInstance.currentYear--
        }

        resetMonthView()
        self.resetContentOffSet(horizontalScrollView)
    }
    
    func resetMonthView() {
        currentMonthView.setUpDays(CalendarManager.sharedInstance.currentYear, month: CalendarManager.sharedInstance.currentMonth)
        var ret = CalendarManager.getPrevYearAndMonth()
        prevMonthView.setUpDays(ret.year, month: ret.month)
        ret = CalendarManager.getNextYearAndMonth()
        nextMonthView.setUpDays(ret.year, month:ret.month)
    }
    
    func showNextYearView (){
        CalendarManager.sharedInstance.currentYear++
        let tmpView = currentMonthView
        currentMonthView = nextYearMonthView
        nextYearMonthView = lastYearMonthView
        lastYearMonthView = tmpView
        
        let ret = CalendarManager.getNextYear()
        nextYearMonthView.setUpDays(ret.year, month:ret.month)
        
        self.resetContentOffSet(verticalScrollView)
    }
    
    func showPrevYearView () {
        CalendarManager.sharedInstance.currentYear--
        let tmpView = currentMonthView
        currentMonthView = lastYearMonthView
        lastYearMonthView    = nextYearMonthView
        nextYearMonthView    = tmpView
        let ret = CalendarManager.getLastYear()
        lastYearMonthView.setUpDays(ret.year, month:ret.month)
        
        //position調整
        self.resetContentOffSet(verticalScrollView)
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
}
