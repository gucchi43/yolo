//
//
//  masterch
//
//  Created by Fumiya Yamanaka on 2016/02/09.
//  Copyright © 2016年 Fumiya Yamanaka. All rights reserved.
//

import UIKit
import NCMB
import SwiftDate
import DZNEmptyDataSet
import TTTAttributedLabel
import BTNavigationDropdownMenu
import SDWebImage
import IDMPhotoBrowser
import MapKit
import CoreLocation
import Photos
import SVProgressHUD

protocol LogViewControlloerDelegate {
    func updateLogView()
}


class LogViewController: UIViewController, addPostDetailDelegate {

    var scrollInfoNumber: Int = 0
    var toggleWeek: Bool = false
    var postArray: NSArray = NSArray()
    var totalArray = [AnyObject]()
    
    @IBOutlet weak var calendarBaseView: UIView!
    @IBOutlet weak var calendarWeekView: UIView!
    
    @IBOutlet weak var tableView: UITableView!

    var calendarView: CalendarView?
    var calendarAnotherView: CalendarAnotherView?
    
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var monthLabel: UILabel!
    
    @IBOutlet weak var changeWeekOrMonthToggle: UIButton!
    
    @IBOutlet weak var progressBar: LogPostedProgressBar!

    //    セル選択時の変数
    var selectedPostObject: NCMBObject!

    var animationFinished = true
    
    let toWeekImage = UIImage(named: "toWeek")
    let toMonthImage = UIImage(named: "toMonth")
    
    let likeOnImage = UIImage(named: "hartON")
    let likeOffImage = UIImage(named: "hartOFF")

    var navigationBarView: BTNavigationDropdownMenu!
    var dropdownNumber: Int = 0
    var dayLoadingToggle = false

    var shareCameraRollDate: NSDate?
    var shareCameraRollImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        print("LogViewController")

        tableView.estimatedRowHeight = 370
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView()
        
        if toggleWeek == false {
            changeWeekOrMonthToggle.setImage(toWeekImage, forState: UIControlState.Normal)
        }else {
            changeWeekOrMonthToggle.setImage(toMonthImage, forState: UIControlState.Normal)
        }
        
        let logPostPB = LogPostedProgressBar()
        logPostPB.setProgressBar()

    }

    override func viewWillAppear(animated: Bool) {
        navigationTitleToggle()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LogViewController.didSelectDayView(_:)), name: "didSelectDayView", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LogViewController.submitFinish(_:)), name: "submitFinish", object: nil)
        if let indexPathForSelectedRow = tableView.indexPathForSelectedRow {
            tableView.deselectRowAtIndexPath(indexPathForSelectedRow, animated: true)
        }
        //Viewの階層で１(１階層,１番上,タブがログで先頭)の時だけ、logTitleToggleをtrueにする
        let viewCount = self.navigationController?.viewControllers.count
        print("viewCount", viewCount)
        if viewCount == 1{
            logManager.sharedSingleton.logTitleToggle = true
        }else {
            logManager.sharedSingleton.logTitleToggle = false
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
        print("LogViewController viewDidDisappear")
    }

    //関数で受け取った時のアクションを定義
    func didSelectDayView(notification: NSNotification) {

        if let parms = notification.userInfo{
            self.tableView.reloadData()
        }else {
            //tableViewのとこに読み込み画面入れる
            self.dayLoadingToggle = true
            self.totalArray = []
            //        self.postArray = []
            self.tableView.emptyDataSetSource = self
            self.tableView.emptyDataSetDelegate = self
            self.tableView.reloadData()

            let logNumber: Int
            if logManager.sharedSingleton.logTitleToggle == true{
                logNumber = logManager.sharedSingleton.tabLogNumber
            }else {
                logNumber = logManager.sharedSingleton.logNumber
            }

            loadQuery(logNumber)

            //カメラロール取得
            if logNumber == 0 {
                let logCameraRollManager = LogGetOneDayCameraRollManager()
                logCameraRollManager.getOnePicData(CalendarManager.currentDate)
            }
            monthLabel.text = CalendarManager.selectLabel()
        }

    }

    func submitFinish(notification: NSNotification) {
        print("submitFinish呼び出し")
        let logNumber : Int
        if logManager.sharedSingleton.logTitleToggle == true {
            logNumber = logManager.sharedSingleton.tabLogNumber
        }else {
            logNumber = logManager.sharedSingleton.logNumber
        }

        //カメラロール取得
        if logNumber == 0 {
            let logCameraRollManager = LogGetOneDayCameraRollManager()
            logCameraRollManager.getOnePicData(CalendarManager.currentDate)
        }

        switch toggleWeek {
        case false:
            print("month表示")
            if let calendarView = calendarView {
                calendarView.submitetResetMonthView()
                                calendarView.resetMonthView()
                loadQuery(logNumber)
            }else {
                print("calendarAnotherViewがないだって!?")
                calendarView?.resetMonthView()
                loadQuery(logNumber)
            }
        default:
            print("week表示")
            if let calendarAnotherView = calendarAnotherView {
                calendarAnotherView.resetWeekView()
                loadQuery(logNumber)
            }else {
                print("calendarAnotherViewがないだって!?")
                calendarAnotherView?.resetWeekView()
                loadQuery(logNumber)
            }
        }
        tableView.reloadData()
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
            let logNumber: Int
            if logManager.sharedSingleton.logTitleToggle == true{
                logNumber = logManager.sharedSingleton.tabLogNumber
            }else {
                logNumber = logManager.sharedSingleton.logNumber
            }

            //カメラロール取得
            if logNumber == 0 {
                let logCameraRollManager = LogGetOneDayCameraRollManager()
                logCameraRollManager.getOnePicData(CalendarManager.currentDate)
            }

            loadQuery(logNumber)
            monthLabel.text = CalendarManager.selectLabel()
        }
    }

    deinit{
        //ここで解放処理
        print("LogVC deinit!!!!")
    }

    func getFollowUserList() {
        let user = NCMBUser.currentUser()
        let relationshipQuery = NCMBQuery(className: "Relationship")
        relationshipQuery.whereKey("followed", equalTo: user)
        relationshipQuery.includeKey("follower")
        relationshipQuery.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if error == nil {
                guard let relationships = objects as? [NCMBObject] else { return }
                UserListManager.sharedSingleton.followArray.removeAll()
                for relationship in relationships{
                    UserListManager.sharedSingleton.followArray.append(relationship.objectForKey("follower") as! NCMBUser)
                }
                self.prepareNavigationDropdownMenu()
            } else {
//                SVProgressHUD.showErrorWithStatus("読み込みに失敗しました")
            }
        }
    }

    //NavigatiaonDropMenuの生成
    func prepareNavigationDropdownMenu() {
//        let userNameArray = getDropdownMenuitems()
        let mineUserName = NCMBUser.currentUser().userName
        var items = [mineUserName, "Follow User"]
        let number = UserListManager.sharedSingleton.followArray.count
         var i = 0
        while i < number {
            let userName = UserListManager.sharedSingleton.followArray[i].userName as String
            items.append(userName)
            i += 1
        }

        print("items", items)
        self.navigationController?.navigationBar.translucent = false
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]

        navigationBarView = BTNavigationDropdownMenu(navigationController: self.navigationController, containerView: self.navigationController!.view, title: items[dropdownNumber], items: items)
        navigationBarView.cellHeight = 50
        let selectColor = ColorManager.sharedSingleton.accsentColor().colorWithAlphaComponent(1.0)
        let otherColor = ColorManager.sharedSingleton.accsentColor().colorWithAlphaComponent(0.5)
        navigationBarView.cellBackgroundColor = otherColor
        navigationBarView.cellSelectionColor = selectColor
        navigationBarView.shouldKeepSelectedCellColor = true
        navigationBarView.cellTextLabelColor = UIColor.whiteColor()
        navigationBarView.cellTextLabelFont = UIFont(name: "Avenir-Heavy", size: 17)
        navigationBarView.cellTextLabelAlignment = .Left // .Center // .Right // .Left
        navigationBarView.arrowPadding = 15
        navigationBarView.animationDuration = 0.5
        navigationBarView.maskBackgroundColor = UIColor.blackColor()
        navigationBarView.maskBackgroundOpacity = 0.3
        navigationBarView.didSelectItemAtIndexHandler = {(indexPath: Int) -> () in
            print("Did select item at index: \(indexPath)")
            print("選択範囲:", items[indexPath])
            self.dropdownNumber = indexPath
            self.selectedDropdownMenu(indexPath, rangeTitle: items[indexPath])
        }

        self.navigationItem.titleView = navigationBarView
    }

    //NavigationBarをログの時だけ、Dropdownになるように切り替える
    func navigationTitleToggle(){

        //        ナビゲーションバーのタイトルに設定する。
        if logManager.sharedSingleton.logTitleToggle == true{
            print("logManager.sharedSingleton.logTitleToggle", logManager.sharedSingleton.logTitleToggle)
            getFollowUserList()
            print("logTitleToggleがtrueなので、ログ範囲のタイトルを表示する")
        }else {
            print("logManager.sharedSingleton.logTitleToggle", logManager.sharedSingleton.logTitleToggle)
            if logManager.sharedSingleton.logNumber == 0 {
                self.navigationItem.title = NCMBUser.currentUser().userName
            }else {
                self.navigationItem.title = logManager.sharedSingleton.logUser.userName
            }

            print("logTitleToggleがfalseなので、ログ範囲のタイトルを表示しない")
        }

    }

    //DropMenuを選択する
    //["Mine", "Follow"] + userNameArray
    func selectedDropdownMenu(indexPath: Int, rangeTitle: String) {
        print("userName : indexPath", rangeTitle, indexPath)

        switch indexPath {
        case 0:
            //範囲は自分のみ
            logManager.sharedSingleton.tabLogNumber = indexPath
        case 1:
            //範囲はフォローユーザー全員
            logManager.sharedSingleton.tabLogNumber = indexPath
        default:
            //範囲は特定のユーザー１人
            logManager.sharedSingleton.tabLogNumber = 2
            logManager.sharedSingleton.logUser = UserListManager.sharedSingleton.followArray[indexPath - 2]
        }
        let logNumber = logManager.sharedSingleton.tabLogNumber
        print("logNumber", logNumber, rangeTitle)

        //カメラロール取得
        if logNumber == 0 {
            let logCameraRollManager = LogGetOneDayCameraRollManager()
            logCameraRollManager.getOnePicData(CalendarManager.currentDate)
        }

        switch toggleWeek {
        case false:
            print("week表示")
            if let calendarView = calendarView {
                calendarView.resetMonthView()
                loadQuery(logNumber)
            }
        default:
            print("month表示")
            if let calendarAnotherView = calendarAnotherView {
                calendarAnotherView.resetWeekView()
                loadQuery(logNumber)
            }
        }
    }

    //投稿画面から戻った時にリロード
    func postDetailDismissionAction() {
        print("postDetailDismissionAction")
        tableView.reloadData()
    }
    
    //tableViewに表示するその日の投稿をQueryから取ってくる
    func loadQuery(logNumber: Int){

        let logQueryManager = LogQueryManager()
        let postQuery: NCMBQuery
        
        let logUser = logManager.sharedSingleton.logUser
        if logUser == NCMBUser.currentUser(){
            print("user情報", logUser.userName)
            //loadItemsuserはuserを引数に取らない場合userにはNCMBUser.currentUser()が自動で入る
            postQuery = logQueryManager.loadItems(logNumber)
        }else {
            print("user情報", logUser.userName)
            postQuery = logQueryManager.loadItems(logNumber, user: logUser)
        }
        
        postQuery.findObjectsInBackgroundWithBlock({(objects, error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                if objects.count > 0 {
                    print("その日に投稿があるパターン")
                    print("投稿数", objects.count)
                    self.postArray = objects
                    self.dayLoadingToggle = false
                    self.tableView.emptyDataSetSource = nil
                    self.tableView.emptyDataSetDelegate = nil
                } else {
                    print("その日に投稿がないパターン")
                    self.dayLoadingToggle = false
                    self.postArray = []
                    self.tableView.emptyDataSetSource = self
                    self.tableView.emptyDataSetDelegate = self
                }
                self.connectArray(logNumber)
                self.tableView.reloadData()
            }
        })
    }

    //NCMBデータとカメラロールの配列を結合
    func connectArray(logNumaber : Int) {
        if logNumaber == 0 {
            totalArray.removeAll()
            var ncmbArray: [AnyObject] = postArray as [AnyObject]
            var cameraRollArray = DeviceDataManager.sharedSingleton.PicOneDayAssetArray
            print("スタート時、postArray.count : ", ncmbArray.count)
            print("スタート時cameraRollArray : ", cameraRollArray.count)

            while ncmbArray.isEmpty == false || cameraRollArray.isEmpty == false {
                var ncmbDate : NSDate?
                var cameraRollDate : NSDate?

                if let ncmbFirstObject = ncmbArray.first {
                    ncmbDate = (ncmbFirstObject as! NCMBObject).objectForKey("postDate") as! NSDate
                }else {
                    ncmbDate = nil
                }

                if let cameraRollFirstObject = cameraRollArray.first{
                    cameraRollDate = cameraRollFirstObject.creationDate
                }else {
                    cameraRollDate = nil
                }

                if ncmbDate != nil && cameraRollDate != nil {

                    let reslt = ncmbDate!.compare(cameraRollDate!)
                    switch reslt {
                    case NSComparisonResult.OrderedAscending:
                        //NCMBデータが入った
                        totalArray.append(ncmbArray.first!)
                        ncmbArray.removeFirst()
                    case NSComparisonResult.OrderedDescending:
                        //カメラロールデータが入った
                        totalArray.append(cameraRollArray.first!)
                        cameraRollArray.removeFirst()
                    default:
                        totalArray.append(ncmbArray.first!)
                        ncmbArray.removeFirst()
                    }
                }else if ncmbDate != nil {
                    totalArray.append(ncmbArray.first!)
                    ncmbArray.removeFirst()
                }else if cameraRollDate != nil {
                    totalArray.append(cameraRollArray.first!)
                    cameraRollArray.removeFirst()
                }
                print("ループ中、postArray.count : ", ncmbArray.count)
                print("ループ中、cameraRollArray.count : ", cameraRollArray.count)
                print("ループ中、totalArray.count : ", totalArray.count)
                print("ループ中、totalArray : ", totalArray)
            }
        }else {
            totalArray = postArray as [AnyObject]
        }
    }    
    // スクロール感知用の変数
    var scrollBeginingPoint: CGPoint!
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        scrollBeginingPoint = scrollView.contentOffset;
        //スクロールはじめに0に初期化して、0の時しかカレンダー更新を通らない
        //カレンダー更新後は１追加して、通らないようにする
        scrollInfoNumber = 0
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        print("scrollInfoNumber", scrollInfoNumber)
        let currentPoint = scrollView.contentOffset
        print(currentPoint)
        print("toggleWeek : ", toggleWeek)
        
        if toggleWeek == false {
            if 70 < currentPoint.y {
                if scrollInfoNumber == 0 {
                    //月→週、上スクロール
                    scrollInfoNumber += 1
                    self.exchangeCalendarView()
                }else {
                    print("下スクロール中の余韻")
                }
            }else {
                print("下スクロール中の余韻")
            }
        } else{
            if -70 > currentPoint.y {
                if scrollInfoNumber == 0 {
                    //週→月、下スクロール
                    print(currentPoint)
                    scrollInfoNumber += 1
                    self.exchangeCalendarView()
                }else {
                    print("上スクロール中の余韻")
                }
            }else {
                print("上スクロール中の余韻")
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toPostDetailVC" {
            let postDetailVC: PostDetailViewController = segue.destinationViewController as! PostDetailViewController
            //            postDetailVC.hidesBottomBarWhenPushed = true // trueならtabBar隠す
            postDetailVC.postObject = self.selectedPostObject
            postDetailVC.delegate = self
            if let sender = sender {
                postDetailVC.isSelectedCommentButton = sender as! Bool
            }
        }
        if segue.identifier == "toSubmitVC" {
            let submitVC: SubmitViewController = segue.destinationViewController as! SubmitViewController
            print("これはどうなる")
            if toggleWeek == false {
                submitVC.weekToggle = false
            }else {
                submitVC.weekToggle = true
            }
            submitVC.postDate = CalendarManager.currentDate
        }
        if segue.identifier == "toSubmitVCfromPic" {
            let submitVC: SubmitViewController = segue.destinationViewController as! SubmitViewController
            if toggleWeek == false {
                submitVC.weekToggle = false
            }else {
                submitVC.weekToggle = true
            }
            print("shareCameraRollDate", shareCameraRollDate)
            submitVC.postDate = shareCameraRollDate
            submitVC.postImage1 = shareCameraRollImage
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
        
        if toggleWeek == false {
            changeWeekOrMonthToggle.setImage(toMonthImage, forState: UIControlState.Normal)
        }else {
            changeWeekOrMonthToggle.setImage(toWeekImage, forState: UIControlState.Normal)
        }
        
        self.exchangeCalendarView()
    }
    
    private func exchangeCalendarView() {
        toggleWeek = !toggleWeek
        //ここが何やってるか不明
        if let calendarView = calendarAnotherView {
            calendarWeekView.addSubview(calendarView)
        }
        
        //ここをいじれば切替時にAPI節約できるかも・・・
        if toggleWeek == true {
            calendarAnotherView?.resetWeekView(totalArray)
            changeWeekOrMonthToggle.setImage(toMonthImage, forState: UIControlState.Normal)
        } else {
            calendarView?.resetMonthView(totalArray)
            changeWeekOrMonthToggle.setImage(toWeekImage, forState: UIControlState.Normal)
        }
        
        monthConstraint.priority = toggleWeek ? UILayoutPriorityDefaultLow : UILayoutPriorityDefaultHigh
        weekConstraint.priority = toggleWeek ? UILayoutPriorityDefaultHigh : UILayoutPriorityDefaultLow
        UIView.animateWithDuration(0.5) { () -> Void in
            self.calendarBaseView.alpha = self.toggleWeek ? 0.0 : 1.0
            self.view.layoutIfNeeded()
        }
    }
}

extension LogViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate{
    //------------------DZNEmptyDataSet(セルが無い時に表示するViewの設定--------------------
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        if self.dayLoadingToggle == true {
            let postDateFormatter: NSDateFormatter = NSDateFormatter()
            postDateFormatter.dateFormat = "dd"
            let dayString = postDateFormatter.stringFromDate(CalendarManager.currentDate)
            let str = "😴 " + dayString + "日" + " 😴"
            let attrs = [NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleTitle1) , NSForegroundColorAttributeName:  UIColor.whiteColor()]
            return NSAttributedString(string: str, attributes: attrs)
        }else {
            let logNumber: Int
            if logManager.sharedSingleton.logTitleToggle == true{
                logNumber = logManager.sharedSingleton.tabLogNumber
            }else {
                logNumber = logManager.sharedSingleton.logNumber
            }
            switch logNumber {
            case 0: //自分の時
                let str = "😝その日のログはまだないよ😝"
                let attrs = [NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline), NSForegroundColorAttributeName: UIColor.whiteColor()]
                return NSAttributedString(string: str, attributes: attrs)
            default: //自分ではない時
                let str = "😝その日のログはまだないよ😝"
                let attrs = [NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline), NSForegroundColorAttributeName: UIColor.whiteColor()]
                return NSAttributedString(string: str, attributes: attrs)
            }
        }
    }

    func descriptionForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        if self.dayLoadingToggle == true {
            let str = "読み込み中..."
            let attrs = [NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleBody), NSForegroundColorAttributeName: UIColor.whiteColor()]
            return NSAttributedString(string: str, attributes: attrs)
        }else {
            let logNumber: Int
            if logManager.sharedSingleton.logTitleToggle == true{
                logNumber = logManager.sharedSingleton.tabLogNumber
            }else {
                logNumber = logManager.sharedSingleton.logNumber
            }
            switch logNumber {
            case 0: //自分の時
                let str = "今すぐログっちゃおう"
                let attrs = [NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleBody), NSForegroundColorAttributeName: UIColor.whiteColor()]
                return NSAttributedString(string: str, attributes: attrs)
            default: //自分ではない時
                let str = "ヒマだよねー"
                let attrs = [NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleBody), NSForegroundColorAttributeName: UIColor.whiteColor()]
                return NSAttributedString(string: str, attributes: attrs)
            }

        }
    }

    func backgroundColorForEmptyDataSet(scrollView: UIScrollView!) -> UIColor! {
        return UIColor.lightGrayColor()
    }

    func emptyDataSetShouldDisplay(scrollView: UIScrollView!) -> Bool {
        return true
    }

    func emptyDataSetShouldAllowTouch(scrollView: UIScrollView!) -> Bool {
        return false
    }

    func emptyDataSetShouldAllowScroll(scrollView: UIScrollView!) -> Bool {
        return false
    }

    func emptyDataSetShouldAnimateImageView(scrollView: UIScrollView!) -> Bool {
        return false
    }

}

extension LogViewController: UITableViewDelegate, UITableViewDataSource, TTTAttributedLabelDelegate, IDMPhotoBrowserDelegate, CLLocationManagerDelegate {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return totalArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        if totalArray[indexPath.row] is NCMBObject {
            let cellId = "TimelineCell"
            let cell = tableView.dequeueReusableCellWithIdentifier(cellId, forIndexPath: indexPath) as! TimelineCell
            let postData = totalArray[indexPath.row] as! NCMBObject
            print("indexPath.row", indexPath.row)
            print("postData", postData)

        //userNameLabel
        //userProfileImageView
        cell.userProfileImageView.layer.cornerRadius = cell.userProfileImageView.frame.width/2
        if let author = postData.objectForKey("user") as? NCMBUser {
            cell.userNameLabel.text = author.objectForKey("userFaceName") as? String
            if let profileImageName = author.objectForKey("userProfileImage") as? String{
                let profileImageFile = NCMBFile.fileWithName(profileImageName, data: nil) as! NCMBFile
                SDWebImageManager.sharedManager().imageCache.queryDiskCacheForKey(profileImageFile.name, done: { (image, SDImageCacheType) in
                    if let image = image {
                        cell.userProfileImageView.image = image
                    }else {
                        profileImageFile.getDataInBackgroundWithBlock({ (imageData: NSData?, error: NSError!) -> Void in
                            if let error = error {
                                print("profileImageの取得失敗： ", error)
                                cell.userProfileImageView.image = UIImage(named: "noprofile")
                            } else {
                                cell.userProfileImageView.image = UIImage(data: imageData!)
                                SDWebImageManager.sharedManager().imageCache.storeImage(UIImage(data: imageData!), forKey: profileImageFile.name)
                            }
                        })
                    }
                })
            }else {
                cell.userProfileImageView.image = UIImage(named: "noprofile")
            }
        } else {
            cell.userNameLabel.text = "username"
            cell.userProfileImageView.image = UIImage(named: "noprofile")
        }

        // postTextLabel
        // urlをリンクにする設定
        cell.postTextLabel.delegate = self
        let linkColor = ColorManager.sharedSingleton.mainColor()
        let linkActiveColor = ColorManager.sharedSingleton.mainColor().darken(0.25)
        cell.postTextLabel.linkAttributes = [kCTForegroundColorAttributeName : linkColor]
        cell.postTextLabel.activeLinkAttributes = [kCTForegroundColorAttributeName : linkActiveColor]
        cell.postTextLabel.enabledTextCheckingTypes = NSTextCheckingType.Link.rawValue
        cell.postTextLabel.text = postData.objectForKey("text") as? String
        print("投稿内容", cell.postTextLabel.text)

        // postDateLabel
        let date = postData.objectForKey("postDate") as? NSDate
        print("NSDateの内容", date)
        let postDateFormatter: NSDateFormatter = NSDateFormatter()
        postDateFormatter.dateFormat = "yyyy/MM/dd HH:mm"
        cell.postDateLabel.text = postDateFormatter.stringFromDate(date!)

        //commentButton
        cell.commentButton.addTarget(self, action: #selector(LogViewController.pushCommentButton(_:)), forControlEvents: .TouchUpInside)

        //postImageView
        cell.postImageView.image = nil
        if let postImageName = postData.objectForKey("image1") as? String {
            cell.imageViewHeightConstraint.constant = 150.0
            cell.postImageView.layer.cornerRadius = 5.0
            let postImageFile = NCMBFile.fileWithName(postImageName, data: nil) as! NCMBFile
            SDWebImageManager.sharedManager().imageCache.queryDiskCacheForKey(postImageFile.name, done: { (image, SDImageCacheType) in
                if let image = image {
                    cell.postImageView.image = image
                }else {
                    postImageFile.getDataInBackgroundWithBlock({ (imageData: NSData?, error: NSError!) -> Void in
                        if let error = error {
                            print("postImageの取得失敗： ", error)
                        } else {
                            cell.postImageView.image = UIImage(data: imageData!)
                            SDWebImageManager.sharedManager().imageCache.storeImage(UIImage(data: imageData!), forKey: postImageFile.name)
                        }
                    })
                }
            })
        } else {
            cell.postImageView.image = nil
            cell.imageViewHeightConstraint.constant = 0.0
        }
        
        //いいね
        if postData.objectForKey("likeUser") != nil{
            //今までで、消されたかもだけど、必ずいいねされたことはある
            let postLikeUserString = postData.objectForKey("likeUser")
            //StringをNSArrayに変換
            let postLikeUserArray = postLikeUserString as! NSArray
            let postLikeUserCount = postLikeUserArray.count
            if postLikeUserCount > 0 {
                //いいねをしたユーザーが１人以上いる
                cell.likeCounts = postLikeUserCount
                if postLikeUserArray.containsObject(NCMBUser.currentUser().objectId) == true{
                    //自分がいいねしている
                    print("私はすでにいいねをおしている")
                    cell.likeButton.setImage(likeOnImage, forState: .Normal)
                    cell.likeNumberButton.setTitle(String(cell.likeCounts!), forState: .Normal)
                    cell.isLikeToggle = true
                }else{
                    //いいねはあるけど、自分がいいねしていない
                    cell.likeButton.setImage(likeOffImage, forState: .Normal)
                    cell.likeNumberButton.setTitle(String(cell.likeCounts!), forState: .Normal)
                }
            }else{
                //いいねしたユーザーはいない
                cell.likeButton.setImage(likeOffImage, forState: .Normal)
                cell.likeNumberButton.setTitle("", forState: .Normal)
            }
        }else{
            //今まで一度もいいねされたことはない
            cell.likeButton.setImage(likeOffImage, forState: .Normal)
            cell.likeNumberButton.setTitle("", forState: .Normal)
            }
            return cell
        }else{
            let cellId = "CameraRollCell"
            let cell = tableView.dequeueReusableCellWithIdentifier(cellId, forIndexPath: indexPath) as! CameraRollCell
            let postData = totalArray[indexPath.row] as! PHAsset
            print("indexPath.row", indexPath.row)
            print("postData", postData)

            //userNameLabel
            //userProfileImageView
            cell.userProfileImageView.layer.cornerRadius = cell.userProfileImageView.frame.width/2
            if let user = NCMBUser.currentUser(){
                if let profileImageName = user.objectForKey("userProfileImage") as? String{
                    let profileImageFile = NCMBFile.fileWithName(profileImageName, data: nil) as! NCMBFile
                    SDWebImageManager.sharedManager().imageCache.queryDiskCacheForKey(profileImageFile.name, done: { (image, SDImageCacheType) in
                        if let image = image {
                            cell.userProfileImageView.image = image
                        }else {
                            profileImageFile.getDataInBackgroundWithBlock({ (imageData: NSData?, error: NSError!) -> Void in
                                if let error = error {
                                    print("profileImageの取得失敗： ", error)
                                    cell.userProfileImageView.image = UIImage(named: "noprofile")
                                } else {
                                    cell.userProfileImageView.image = UIImage(data: imageData!)
                                    SDWebImageManager.sharedManager().imageCache.storeImage(UIImage(data: imageData!), forKey: profileImageFile.name)
                                }
                            })
                        }
                    })
                }else {
                    cell.userProfileImageView.image = UIImage(named: "noprofile")
                }
            }
            cell.cameraRollLabel.text = "カメラロール"

            if let location = postData.location{
                //座標を住所に変換する。
                let myGeocoder:CLGeocoder = CLGeocoder()
                myGeocoder.reverseGeocodeLocation(location, completionHandler: {(placemarks, error) in

                    if(error == nil) {
                        for placemark in placemarks! {
                            print("placemark", placemark)
//                            cell.locationLabel.text = "\(placemark.administrativeArea!)\(placemark.locality!)\(placemark.thoroughfare!)"
                            var locationText = ""
                            if let name = placemark.name{
                                locationText += name + " / "
                            }
                            if let administrativeArea = placemark.administrativeArea{
                                locationText += administrativeArea
                            }
                            if let locality = placemark.locality{
                                locationText += locality
                            }
                            if let thoroughfare = placemark.thoroughfare{
                                locationText += thoroughfare
                            }
                            cell.locationLabel.text = locationText
                        }
                    } else {
                        cell.locationLabel.text = "住所不明"
                    }
                })
            }else {
                cell.locationLabel.text = ""
            }



            // postDateLabel
            let date = postData.creationDate!
            let postDateFormatter: NSDateFormatter = NSDateFormatter()
            postDateFormatter.dateFormat = "yyyy/MM/dd HH:mm"

            cell.postDateLabel.text = postDateFormatter.stringFromDate(date)
            cell.imageViewHeightConstraint.constant = 150.0
            cell.camaraRollImageView!.layer.cornerRadius = 5.0
            let manager: PHImageManager = PHImageManager()
            manager.requestImageDataForAsset(postData, options: nil) { (data, title, orientation, dic) in
                cell.camaraRollImageView?.image = UIImage(data: data!)
            }
            return cell
        }
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("セルの選択: \(indexPath.row)")
        if let data = self.totalArray[indexPath.row] as? NCMBObject{
            selectedPostObject = data
            performSegueWithIdentifier("toPostDetailVC", sender: nil)
        }else {
            let asset = self.totalArray[indexPath.row] as? PHAsset
            let manager: PHImageManager = PHImageManager()
            manager.requestImageDataForAsset(asset!, options: nil) { (data, title, orientation, dic) in
                let image = UIImage(data: data!)
                self.tapPostImage(image!)
            }

        }
    }

    //投稿写真タップ
    func tapPostImage(image : UIImage) {
        print("tapPostImage")
        let photo = IDMPhoto(image: image)
        photo.caption = nil
        let photos: NSArray = [photo]
        let browser = IDMPhotoBrowser.init(photos: photos as [AnyObject])
        browser.delegate = self
        self.presentViewController(browser,animated:true ,completion:nil)
    }

//     urlリンクをタップされたときの処理を記述します
    func attributedLabel(label: TTTAttributedLabel!, didSelectLinkWithURL url: NSURL!)
    {
        print(url)
        if UIApplication.sharedApplication().canOpenURL(url!){
            UIApplication.sharedApplication().openURL(url!)
        }
    }
}

//カメラロールシェアアクション
extension LogViewController{
    @IBAction func puahCameraRollShareButton(sender: AnyObject) {
        print("SHAREボタン押した")
        let button = sender as! UIButton
        let cell = button.superview?.superview as! CameraRollCell
        let row = tableView.indexPathForCell(cell)?.row
        let postData = totalArray[row!] as! PHAsset
        if let postDate = postData.creationDate{
            
            shareCameraRollDate = postDate
        }else {
            shareCameraRollDate = CalendarManager.currentDate
        }
        let manager: PHImageManager = PHImageManager()
        manager.requestImageDataForAsset(postData, options: nil) { (data, title, orientation, dic) in
            self.shareCameraRollImage = UIImage(data: data!)
            self.performSegueWithIdentifier("toSubmitVCfromPic", sender: true)
        }
    }
}



//いいねボタンアクション
extension LogViewController{
    @IBAction func pushLikeButton(sender: AnyObject) {
        print("LIKEボタン押した")
        let button = sender as! UIButton
        let cell = button.superview?.superview as! TimelineCell
        print("投稿内容", cell.postTextLabel.text)
        let row = tableView.indexPathForCell(cell)?.row
        let postData = totalArray[row!] as! NCMBObject
        
        //いいねアクション実行
        if cell.isLikeToggle == true{
            disLike(postData, cell: cell)
        } else {
            like(postData, cell: cell)
        }
    }
    
    func like(postData: NCMBObject, cell: TimelineCell) {
        //いいねONボタン
        cell.likeButton.enabled = false
        cell.likeButton.setImage(likeOnImage, forState: .Normal)
        
        if cell.likeCounts != nil{
            //likeCountが追加で変更される時（2回目以降）
            if let oldLinkCounts = Int(cell.likeNumberButton.currentTitle!){
                print("oldLinkCounts", oldLinkCounts)
                //普通にいいねを１追加（2~）
                let newLikeCounts = oldLinkCounts + 1
                cell.likeNumberButton.setTitle(String(newLikeCounts), forState: .Normal)
            }else {
                //oldCountがない場合（以前いいねされたけど、削除されて0になってlikeCountがnullの場合）
                let newLikeCounts = 1
                cell.likeNumberButton.setTitle(String(newLikeCounts), forState: .Normal)
            }
        }else{
            //likeCountが初めて変更される時
            let newLikeCounts = 1
            cell.likeNumberButton.setTitle(String(newLikeCounts), forState: .Normal)
        }
        postData.addUniqueObject(NCMBUser.currentUser().objectId, forKey: "likeUser")
        postData.saveEventually ({ (error) -> Void in
            if let error = error{
                print(error.localizedDescription)
                cell.isLikeToggle = false
                cell.likeButton.enabled = true
            }else {
                print("save成功 いいね保存")
                cell.isLikeToggle = true
                //いいねしたことを通知画面のDBに保存
                let auther = postData.objectForKey("user") as! NCMBUser
                let allPostText = postData.objectForKey("text") as! String
                let allPostTextCount = allPostText.characters.count
                print("allPostTextCount", allPostTextCount)
                let postHeader: String?
                if allPostTextCount > 100{
                    postHeader = allPostText.substringToIndex(allPostText.startIndex.advancedBy(100))
                }else {
                    postHeader = allPostText
                }
                print("Notificatoinに保存する最初の５０文字", postHeader!)
                let notificationManager = NotificationManager()
                notificationManager.likeNotification(auther, post: postData, postHeader: postHeader!, button: cell.likeButton)
            }
        })
        
    }

    func disLike(postData: NCMBObject, cell: TimelineCell) {
        //いいねOFFボタン
        cell.likeButton.enabled = false
        cell.likeButton.setImage(likeOffImage, forState: .Normal)
        cell.likeNumberButton.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
        
        if cell.likeCounts != nil{
            //likeCountがある時（1~）
            let oldLinkCounts = Int(cell.likeNumberButton.currentTitle!)
            print("oldLinkCounts", oldLinkCounts)
            let newLikeCounts = oldLinkCounts! - 1
            if newLikeCounts > 0{
                //変更後のlikeCountが0より上の場合（1~）
                cell.likeNumberButton.setTitle(String(newLikeCounts), forState: .Normal)
            }else {
                //変更後のlikeCountが0を含むそれ以下の場合(~0)
                let newLikeCounts = ""
                cell.likeNumberButton.setTitle(String(newLikeCounts), forState: .Normal)
            }
        }else {
            //likeCountが今までついたことがなかった場合
            let newLikeCounts = ""
            cell.likeNumberButton.setTitle(String(newLikeCounts), forState: .Normal)
        }
        
        let auther = postData.objectForKey("user") as! NCMBUser
        postData.removeObject(NCMBUser.currentUser().objectId, forKey: "likeUser")
        postData.saveEventually ({ (error) -> Void in
            if let error = error{
                print(error.localizedDescription)
                cell.isLikeToggle = true
                cell.likeButton.enabled = true
            }else {
                print("save成功 いいね取り消し")
                cell.isLikeToggle = false
                let notificationManager = NotificationManager()
                notificationManager.deletelikeNotification(auther, post: postData, button: cell.likeButton)
            }
        })
        
    }
}

//コメントボタンアクション
extension LogViewController{
    @IBAction func pushCommentButton(sender: UIButton) {
        // 押されたボタンを取得
        let cell = sender.superview?.superview as! TimelineCell
        let row = tableView.indexPathForCell(cell)?.row
        selectedPostObject = self.totalArray[row!] as! NCMBObject
        performSegueWithIdentifier("toPostDetailVC", sender: true)
    }
    
}

extension LogViewController {
    func savePostProgressBar(percentDone: CGFloat) {
        //percentDoneに合わしてprogressBarが動く
        progressBar.setProgress(percentDone, animated: true)
        //100%になったら、progressを消す（0.5秒後に設定）
        if percentDone == CGFloat(1.0){
            let delay = 1.0 * Double(NSEC_PER_SEC)
            let time  = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
            dispatch_after(time, dispatch_get_main_queue(), {
                self.progressBar.setProgress(0.00, animated: false)
            })
        }
    }
}
