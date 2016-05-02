//
//  LogViewController.swift
//  masterch
//
//  Created by Fumiya Yamanaka on 2016/02/09.
//  Copyright © 2016年 Fumiya Yamanaka. All rights reserved.
//

import UIKit


class LogViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var toggleWeek: Bool = false
    var items: NSArray = NSArray()
    
    @IBOutlet weak var calendarBaseView: UIView!
    @IBOutlet weak var calendarWeekView: UIView!
    
    @IBOutlet weak var tableView: UITableView!
    
    var calendarView: CalendarView?
    var calendarAnotherView: CalendarAnotherView?

    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var monthLabel: UILabel!
    
//    セル選択時の変数
    var selectedPostObject: NCMBObject!
    
    var selectedPostUserFaceName: String!
    var selectedPostUserName: String!
    var selectedPostUserProfileImage: UIImage!
    var selectedPostText: String!
    var selectedPostDate: String!
    var selectedPostImage: UIImage!
    
    var animationFinished = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        print("LogViewController")
        
        tableView.estimatedRowHeight = 370
        tableView.rowHeight = UITableViewAutomaticDimension
//        viewdidloadでは呼ばないでいい
//        monthLabel.text! = CalendarManager.selectLabel()
    }
    
    override func viewWillAppear(animated: Bool) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didSelectDayView:", name: "didSelectDayView", object: nil)
        if let indexPathForSelectedRow = tableView.indexPathForSelectedRow {
            tableView.deselectRowAtIndexPath(indexPathForSelectedRow, animated: true)
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    //関数で受け取った時のアクションを定義
    func didSelectDayView(notification: NSNotification) {
        loadItems()
        monthLabel.text = CalendarManager.selectLabel()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        if calendarView == nil {
            calendarView = CalendarView(frame: calendarBaseView.bounds)
            calendarAnotherView = CalendarAnotherView(frame: calendarWeekView.bounds)
            if let calendarView = calendarView {
                calendarBaseView.addSubview(calendarView)
            }
            loadItems()
            monthLabel.text = CalendarManager.selectLabel()
        }
    }
    
    func loadItems() {
        let myselfQuery: NCMBQuery = NCMBQuery(className: "Post") // 自分の投稿クエリ
        myselfQuery.whereKey("user", equalTo: NCMBUser.currentUser())
        
        let relationshipQuery: NCMBQuery = NCMBQuery(className: "Relation") // 自分がフォローしている人のクエリ
        relationshipQuery.whereKey("followed", equalTo: NCMBUser.currentUser())
        relationshipQuery.whereKey("follower", matchesKey: "user", inQuery: NCMBQuery(className: "Post"))
        
        let followingQuery: NCMBQuery = NCMBQuery(className: "Post") // 自分がフォローしている人の投稿クエリ
        followingQuery.whereKey("user", matchesKey: "follower", inQuery: relationshipQuery)

        let postQuery: NCMBQuery = NCMBQuery.orQueryWithSubqueries([myselfQuery, followingQuery]) // クエリの合成
        postQuery.orderByDescending("postDate") // cellの並べ方
        postQuery.whereKey("createDate", greaterThanOrEqualTo: CalendarManager.FilterDateStart())
        postQuery.whereKey("createDate", lessThanOrEqualTo: CalendarManager.FilterDateEnd())
        postQuery.includeKey("user")

//        自分の投稿だけを表示するQueryを発行
        let myPostQuery: NCMBQuery = NCMBQuery(className: "Post")
        myPostQuery.whereKey("user", equalTo: NCMBUser.currentUser())
        myPostQuery.orderByDescending("postDate") // cellの並べ方

//        TODO: createDate を postDateに変更する
        myPostQuery.whereKey("postDate", greaterThanOrEqualTo: CalendarManager.FilterDateStart())
        myPostQuery.whereKey("postDate", lessThanOrEqualTo: CalendarManager.FilterDateEnd())
        myPostQuery.includeKey("user")

        myPostQuery.findObjectsInBackgroundWithBlock({(NSArray objects, NSError error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                if objects.count > 0 {
                    self.items = objects
                } else {
                    self.items = []
                }
                self.tableView.reloadData()
            }
        })
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellId = "TimelineCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellId, forIndexPath: indexPath) as! TimelineCell
        // 各値をセルに入れる
        let postData = items[indexPath.row]
        // postTextLabelには(key: "text")の値を入れる
        cell.postTextLabel.text = postData.objectForKey("text") as? String
        // postDateLabelには(key: "postDate")の値を、NSDateからstringに変換して入れる
        let date = postData.objectForKey("postDate") as? NSDate
        let postDateFormatter: NSDateFormatter = NSDateFormatter()
        postDateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        cell.postDateLabel.text = postDateFormatter.stringFromDate(date!)
        
//        cell.postImageView.layer.cornerRadius = 5.0
        let author = postData.objectForKey("user") as? NCMBUser
        if let author = author {
            cell.userNameLabel.text = author.objectForKey("userFaceName") as? String
            let postImageData = NCMBFile.fileWithName(author.objectForKey("userProfileImage") as? String, data: nil) as! NCMBFile
            postImageData.getDataInBackgroundWithBlock({ (imageData: NSData?, error: NSError!) -> Void in
                if let error = error {
                    print("プロフィール画像の取得失敗： ", error)
                    cell.userProfileImageView.image = UIImage(named: "noprofile")
                } else {
                    cell.userProfileImageView.image = UIImage(data: imageData!)
                }
            })
        } else {
            cell.userNameLabel.text = "username"
            cell.userProfileImageView.image = UIImage(named: "noprofile")
        }
        
        //画像データの取得
       if let postImageName = postData.objectForKey("image1") as? String {
            cell.imageViewHeightConstraint.constant = 150.0;
            let postImageData = NCMBFile.fileWithName(postImageName, data: nil) as! NCMBFile
            postImageData.getDataInBackgroundWithBlock({ (imageData: NSData?, error: NSError!) -> Void in
                if let error = error {
                    print("写真の取得失敗： ", error)
                } else {
                    cell.postImageView.image = UIImage(data: imageData!)
                }
            })
        } else {
            cell.postImageView.image = nil
            cell.imageViewHeightConstraint.constant = 0.0;
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("セルの選択: \(indexPath.row)")
        selectedPostObject = self.items[indexPath.row] as! NCMBObject
        
        performSegueWithIdentifier("toPostDetailViewController", sender: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toPostDetailViewController" {
            let postDetailVC: PostDetailViewController = segue.destinationViewController as! PostDetailViewController
            
            postDetailVC.postObject = self.selectedPostObject
        }
    }
    
    //月週の切り替わりのアウトレイアウトの紐付け
    @IBOutlet weak var weekConstraint: NSLayoutConstraint!
    @IBOutlet weak var monthConstraint: NSLayoutConstraint!
    
    
    //todayボタンアクション
    @IBAction func backToToday(sender: AnyObject) {
        if (self.calendarBaseView != nil){
            calendarView?.getNow()
        }
            calendarAnotherView?.getNow()
    }
    
    @IBAction func toggle(sender: AnyObject) {
        print("toggle", toggleWeek)
        toggleWeek = !toggleWeek
        //ここが何やってるか不明
        if let calendarView = calendarAnotherView {
            calendarWeekView.addSubview(calendarView)
        }
        
        if toggleWeek {
            calendarAnotherView?.resetWeekView()
        } else {
            calendarView?.resetMonthView()
        }
        
        monthConstraint.priority = toggleWeek ? UILayoutPriorityDefaultLow : UILayoutPriorityDefaultHigh
        weekConstraint.priority = toggleWeek ? UILayoutPriorityDefaultHigh : UILayoutPriorityDefaultLow
        UIView.animateWithDuration(0.5) { () -> Void in
            self.calendarBaseView.alpha = self.toggleWeek ? 0.0 : 1.0
            self.view.layoutIfNeeded()
        }
    }
}

