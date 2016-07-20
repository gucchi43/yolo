//
//  LogViewController.swift
//  masterch
//
//  Created by Fumiya Yamanaka on 2016/02/09.
//  Copyright © 2016年 Fumiya Yamanaka. All rights reserved.
//

import UIKit
import DropdownMenu
import SwiftDate
import DZNEmptyDataSet

protocol LogViewControlloerDelegate {
    func updateLogView()
}


class LogViewController: UIViewController, addPostDetailDelegate {
    
    var toggleWeek: Bool = false
    var postArray: NSArray = NSArray()
    
    @IBOutlet weak var calendarBaseView: UIView!
    @IBOutlet weak var calendarWeekView: UIView!
    
    @IBOutlet weak var tableView: UITableView!

    var calendarView: CalendarView?
    var calendarAnotherView: CalendarAnotherView?
    
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var monthLabel: UILabel!
    
    @IBOutlet weak var changeWeekOrMonthToggle: UIButton!
    
    @IBOutlet weak var progressBar: LogPostedProgressBar!
    
    var selectedRow: Int = 0
    var Dropitems: [DropdownItem]!
    //    var user: NCMBUser = NCMBUser.currentUser()
    
    var userName: String?
    
    //    セル選択時の変数
    var selectedPostObject: NCMBObject!
    
    //    それぞれを変数にして渡す場合に使用。その方が早いけど、何故かずれたりする原因がわからないのでNMCBObjectをそのまま渡している
    //    var selectedPostUserFaceName: String!
    //    var selectedPostUserName: String!
    //    var selectedPostUserProfileImage: UIImage!
    //    var selectedPostText: String!
    //    var selectedPostDate: String!
    //    var selectedPostImage: UIImage!
    
    var animationFinished = true
    
    let toWeekImage = UIImage(named: "toWeek")
    let toMonthImage = UIImage(named: "toMonth")
    
    let likeOnImage = UIImage(named: "hartON")
    let likeOffImage = UIImage(named: "hartOFF")
    
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
        //        self.navigationController?.setToolbarHidden(true, animated: true) // ViewWillAppearは表示の度に呼ばれるので何度も消してくれる
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LogViewController.didSelectDayView(_:)), name: "didSelectDayView", object: nil)
        if let indexPathForSelectedRow = tableView.indexPathForSelectedRow {
            tableView.deselectRowAtIndexPath(indexPathForSelectedRow, animated: true)
        }
        
        //NavigationBarのタイトルになる配列を読み込む
        //（今は定数のためViewDidLoadに書いている）
        //        let userName = user.userName
        //        let logUser = logManager.sharedSingleton.logUser
        //        let userName = logUser.userName
        let userName = NCMBUser.currentUser().userName
        let item1 = DropdownItem(title: userName)
        let item2 = DropdownItem(title: "フォロー")
        Dropitems = [item1, item2]
        //        if let userName = userName{
        //            let item3 = DropdownItem(title: userName)
        //            Dropitems = [item1, item2, item3]
        //        }else {
        //            Dropitems = [item1, item2]
        //        }
        changeTitle(logManager.sharedSingleton.logNumber)
        
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
        print("LogViewController viewDidDisappear")
    }
    
    //関数で受け取った時のアクションを定義
    func didSelectDayView(notification: NSNotification) {
        let logNumber = logManager.sharedSingleton.logNumber
        loadQuery(logNumber)
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
            let logNumber = logManager.sharedSingleton.logNumber
            loadQuery(logNumber)
            monthLabel.text = CalendarManager.selectLabel()
        }
    }
    
    
    //    NavigationTitleをタップ
    func tapped(tapGestureRecognizer: UITapGestureRecognizer) {
        print("ナビゲーションタイトルをタップ")
        let menuView = DropdownMenu(navigationController: navigationController!, items: Dropitems, selectedRow: selectedRow)
        menuView.delegate = self
        menuView.showMenu(onNavigaitionView: true)
    }
    
    func openSubmitViewController(){
        print("openSubmitViewController")
        let submitVC = SubmitViewController()
        submitVC.delegate = self
    }
    
    
    
    //投稿画面から戻った時にリロード
    func postDetailDismissionAction() {
        print("postDetailDismissionAction")
        tableView.reloadData()
    }
    
    //tableViewに表示するその日の投稿のQueryから取ってくる
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
                    self.tableView.emptyDataSetSource = nil
                    self.tableView.emptyDataSetDelegate = nil
                } else {
                    print("その日に投稿がないパターン")
                    self.postArray = []
                    self.tableView.emptyDataSetSource = self
                    self.tableView.emptyDataSetDelegate = self
                }
                self.tableView.reloadData()
            }
        })
    }
    
    
    // スクロール感知用の変数
    var scrollBeginingPoint: CGPoint!
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        scrollBeginingPoint = scrollView.contentOffset;
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let currentPoint = scrollView.contentOffset
        print(currentPoint)
        
        if toggleWeek == false {
            if 20 < currentPoint.y {
                print("scrollBeginingPoint \(scrollBeginingPoint) ")
                print("currentPoint \(currentPoint) ")
                self.exchangeCalendarView()
            }
        } else if toggleWeek == true {
            if -20 > currentPoint.y {
                print(currentPoint)
                self.exchangeCalendarView()
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
            submitVC.delegate = self
            print("これはどうなる")
            submitVC.postDate = CalendarManager.currentDate
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
        if toggleWeek {
            calendarAnotherView?.resetWeekView()
            changeWeekOrMonthToggle.setImage(toMonthImage, forState: UIControlState.Normal)
        } else {
            calendarView?.resetMonthView()
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

        switch logManager.sharedSingleton.logNumber {
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

    func descriptionForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        switch logManager.sharedSingleton.logNumber {
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

//    func imageForEmptyDataSet(scrollView: UIScrollView!) -> UIImage! {
//        return UIImage(named: "logGood")
//    }

    func backgroundColorForEmptyDataSet(scrollView: UIScrollView!) -> UIColor! {
        return UIColor.lightGrayColor()
    }

//    func buttonTitleForEmptyDataSet(scrollView: UIScrollView!, forState state: UIControlState) -> NSAttributedString! {
//        let str = "∨"
//        let attrs = [NSFontAttributeName: UIFont.boldSystemFontOfSize(20.0), NSForegroundColorAttributeName: UIColor.whiteColor()]
//        return NSAttributedString(string: str, attributes: attrs)
//    }

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

extension LogViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellId = "TimelineCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellId, forIndexPath: indexPath) as! TimelineCell
        
        //ImageViewの初期化的な
        cell.userProfileImageView.image = UIImage(named: "noprofile")
        cell.postImageView.image = nil
        
        // 各値をセルに入れる
        let postData = postArray[indexPath.row] as! NCMBObject
        print("postData", postData)
        // postTextLabelには(key: "text")の値を入れる
        cell.postTextLabel.text = postData.objectForKey("text") as? String
        print("投稿内容", cell.postTextLabel.text)
        // postDateLabelには(key: "postDate")の値を、NSDateからstringに変換して入れる
        let date = postData.objectForKey("postDate") as? NSDate
        print("NSDateの内容", date)
        let postDateFormatter: NSDateFormatter = NSDateFormatter()
        postDateFormatter.dateFormat = "yyyy/MM/dd HH:mm"
        cell.postDateLabel.text = postDateFormatter.stringFromDate(date!)
        
        cell.commentButton.addTarget(self, action: #selector(LogViewController.pushCommentButton(_:)), forControlEvents: .TouchUpInside)
        
        //プロフィール写真の形を円形にする
        cell.userProfileImageView.layer.cornerRadius = cell.userProfileImageView.frame.width/2
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
            cell.imageViewHeightConstraint.constant = 150.0
            let postImageData = NCMBFile.fileWithName(postImageName, data: nil) as! NCMBFile
            postImageData.getDataInBackgroundWithBlock({ (imageData: NSData?, error: NSError!) -> Void in
                if let error = error {
                    print("写真の取得失敗： ", error)
                } else {
                    cell.postImageView.image = UIImage(data: imageData!)
                    cell.postImageView.layer.cornerRadius = 5.0
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
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("セルの選択: \(indexPath.row)")
        selectedPostObject = self.postArray[indexPath.row] as! NCMBObject
        performSegueWithIdentifier("toPostDetailVC", sender: nil)
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
        let postData = postArray[row!] as! NCMBObject
        
        //いいねアクション実行
        if cell.isLikeToggle == true{
            disLike(postData, cell: cell)
        } else {
            like(postData, cell: cell)
        }
    }
    
    func like(postData: NCMBObject, cell: TimelineCell) {
        //いいねONボタン
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
                notificationManager.likeNotification(auther, post: postData, postHeader: postHeader!)
            }
        })
        
    }
    
    
    func disLike(postData: NCMBObject, cell: TimelineCell) {
        //いいねOFFボタン
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
            }else {
                print("save成功 いいね取り消し")
                cell.isLikeToggle = false
                let notificationManager = NotificationManager()
                notificationManager.deletelikeNotification(auther, post: postData)
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
        selectedPostObject = self.postArray[row!] as! NCMBObject
        
        performSegueWithIdentifier("toPostDetailVC", sender: true)
    }
    
}

//--------------NavigatoinBarの管理 (DropdownMenuDelegateのDelegate)----------------------------
extension LogViewController: DropdownMenuDelegate {
    func dropdownMenu(dropdownMenu: DropdownMenu, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("DropdownMenu didselect \(indexPath.row) text:\(Dropitems[indexPath.row].title)")
        
        self.selectedRow = indexPath.row
        
        if indexPath.row != Dropitems.count - 1 {
            //一番上選んだ時
            self.selectedRow = indexPath.row
        }else {
            //それ意外
            self.selectedRow = indexPath.row
        }
        logManager.sharedSingleton.logNumber = indexPath.row
        let logNumber = logManager.sharedSingleton.logNumber
        print("logNumber", logNumber, Dropitems[indexPath.row].title)
        
        changeTitle(logManager.sharedSingleton.logNumber)
        
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
    
    //NavigatoinBarのタイトルを設定
    func changeTitle(logNumber: Int) {
        //スタックビューを作成
        let stackView = UIStackView()
        stackView.axis = .Vertical
        stackView.alignment = .Center
        stackView.frame = CGRectMake(0,0,100,40)
        
        //タイトルのラベルを作成する。
        let testLabel1 = UILabel(frame:CGRectMake(0,0,100,28))
        testLabel1.textColor = UIColor.whiteColor()
        testLabel1.text = "ログ"
        
        //サブタイトルを作成する。
        let testLabel2 = UILabel(frame:CGRectMake(0,0,100,12))
        testLabel2.textColor = UIColor.whiteColor()
        let logNumber = logManager.sharedSingleton.logNumber
        testLabel2.text = Dropitems[selectedRow].title
        
        //        if selectedRow == logNumber {
        //            testLabel2.text = Dropitems[selectedRow].title
        //        }
        
        //        switch logNumber {
        //        case 0:
        //            testLabel2.text = Dropitems[0].title
        //        case 1:
        //            testLabel2.text = Dropitems[1].title
        //        case 2:
        //            testLabel2.text = "logNumber = 2"
        //        default:
        //            testLabel2.text = "その他"
        //        }
        
        //スタックビューに追加する。
        stackView.addArrangedSubview(testLabel1)
        stackView.addArrangedSubview(testLabel2)
        //タッチできるようにする
        let gesture = UITapGestureRecognizer(target: self, action: #selector(self.tapped(_:)))
        stackView.addGestureRecognizer(gesture)
        stackView.userInteractionEnabled = true
        //ナビゲーションバーのタイトルに設定する。
        //        if logNumber != 2{
        //            navigationController!.navigationBar.topItem!.titleView = stackView
        //        }
        //        if logManager.sharedSingleton.logNumber == 0 && logManager.sharedSingleton.logUser  == NCMBUser.currentUser() && maintabBarVC.selectedIndex as Int == 0{
        //            navigationController!.navigationBar.topItem!.titleView = stackView
        //        }
        //        if maintabBarVC.selectedIndex as Int == 0 {
        //        }
        if logManager.sharedSingleton.logTitleToggle == true{
            print("logManager.sharedSingleton.logTitleToggle", logManager.sharedSingleton.logTitleToggle)
            navigationController!.navigationBar.topItem!.titleView = stackView
            print("logTitleToggleがtrueなので、ログ範囲のタイトルを表示する")
        }else {
            print("logManager.sharedSingleton.logTitleToggle", logManager.sharedSingleton.logTitleToggle)
            print("logTitleToggleがfalseなので、ログ範囲のタイトルを表示しない")
        }
        
        
    }
}

extension LogViewController: SubmitViewControllerDelegate {
    func submitFinish() {
        print("submitFinish")
        let logNumber = logManager.sharedSingleton.logNumber
        switch toggleWeek {
        case false:
            print("month表示")
            if let calendarView = calendarView {
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
