//
//  LogViewController.swift
//  masterch
//
//  Created by Fumiya Yamanaka on 2016/02/09.
//  Copyright © 2016年 Fumiya Yamanaka. All rights reserved.
//

import UIKit
import DropdownMenu

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
    
    var selectedRow: Int = 0
    var Dropitems: [DropdownItem]!
    var logNumber: Int = 0
    
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
    
    let likeOnImage = UIImage(named: "hartButton_On")
    let likeOffImage = UIImage(named: "hartButton_Off")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        print("LogViewController")
        
        tableView.estimatedRowHeight = 370
        tableView.rowHeight = UITableViewAutomaticDimension
        let label = UILabel()
        label.text = "ログ"
        label.sizeToFit()
        
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(self.tapped(_:)))
        label.addGestureRecognizer(gesture)
        label.userInteractionEnabled = true
        navigationItem.titleView = label
        
//        viewdidloadでは呼ばないでいい
//        monthLabel.text! = CalendarManager.selectLabel()
    }
    
    override func viewWillAppear(animated: Bool) {
//        self.navigationController?.setToolbarHidden(true, animated: true) // ViewWillAppearは表示の度に呼ばれるので何度も消してくれる

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LogViewController.didSelectDayView(_:)), name: "didSelectDayView", object: nil)
        if let indexPathForSelectedRow = tableView.indexPathForSelectedRow {
            tableView.deselectRowAtIndexPath(indexPathForSelectedRow, animated: true)
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
        print("LogViewController viewDidDisappear")
    }
    
    //関数で受け取った時のアクションを定義
    func didSelectDayView(notification: NSNotification) {
//        let loadItemsManager = LoadItemsManager()
//        loadItemsManager.loadItems(0)
        loadItemsFinish(logNumber)
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
//            let loadItemsManager = LoadItemsManager()
//            loadItemsManager.loadItems(0)
            loadItemsFinish(logNumber)
            monthLabel.text = CalendarManager.selectLabel()
        }
    }
    
    //NavigationTitleをタップ
    func tapped(tapGestureRecognizer: UITapGestureRecognizer) {
        print("ナビゲーションタイトルをタップ")
        let item1 = DropdownItem(title: "オール")
        let item2 = DropdownItem(title: "自分")
        let item3 = DropdownItem(title: "フォロー")
//        let item2 = DropdownItem(image: UIImage(named: "takigutihikari")!, title: "File")
//        let item3 = DropdownItem(image: UIImage(named: "takigutihikari")!, title: "Post", style: .Highlight)
//        let item4 = DropdownItem(image: UIImage(named: "takigutihikari")!, title: "Event", style: .Highlight, accessoryImage: UIImage(named: "accessory")!)
        
        Dropitems = [item1, item2,item3]
        let menuView = DropdownMenu(navigationController: navigationController!, items: Dropitems, selectedRow: selectedRow)
        menuView.delegate = self
        menuView.showMenu(onNavigaitionView: true)
    }
    

    //投稿画面から戻った時にリロード
        func postDetailDismissionAction() {
        print("postDetailDismissionAction")
        tableView.reloadData()
    }
    
//    func loadItems(range: Int) {
//        var postQuery: NCMBQuery = NCMBQuery(className: "Post")
//        switch range {
//        case 1:
//            postQuery.whereKey("user", equalTo: NCMBUser.currentUser())
//            postQuery.orderByDescending("postDate") // cellの並べ方
//            postQuery.whereKey("postDate", greaterThanOrEqualTo: CalendarManager.FilterDateStart())
//            postQuery.whereKey("postDate", lessThanOrEqualTo: CalendarManager.FilterDateEnd())
//            postQuery.includeKey("user")
//            
//            
//        case 2:
//            let relationshipQuery: NCMBQuery = NCMBQuery(className: "Relationship") // 自分がフォローしている人かどうかのクエリ
//            relationshipQuery.whereKey("followed", equalTo: NCMBUser.currentUser())
//            relationshipQuery.whereKey("follower", matchesKey: "user", inQuery: NCMBQuery(className: "Post"))
//            postQuery.whereKey("user", matchesKey: "follower", inQuery: relationshipQuery)// 自分がフォローしている人の投稿クエリ
//            postQuery.whereKey("secretKey", notEqualTo: true) // secretKeyがtrueではないもの(鍵が付いていないもの)を表示(nil, false)
//            postQuery.whereKey("user", notEqualTo: NCMBUser.currentUser())//自分がフォロワーに含まれてたら自分は表示しない
//            postQuery.orderByDescending("postDate") // cellの並べ方
//            postQuery.whereKey("postDate", greaterThanOrEqualTo: CalendarManager.FilterDateStart())
//            postQuery.whereKey("postDate", lessThanOrEqualTo: CalendarManager.FilterDateEnd())
//            postQuery.includeKey("user")
//            
//            
//        default:
//            let myPostQuery: NCMBQuery = NCMBQuery(className: "Post") // 自分の投稿クエリ
//            myPostQuery.whereKey("user", equalTo: NCMBUser.currentUser())
//            
//            let relationshipQuery: NCMBQuery = NCMBQuery(className: "Relationship") // 自分がフォローしている人かどうかのクエリ
//            relationshipQuery.whereKey("followed", equalTo: NCMBUser.currentUser())
//            relationshipQuery.whereKey("follower", matchesKey: "user", inQuery: NCMBQuery(className: "Post"))
//            
//            let followingQuery: NCMBQuery = NCMBQuery(className: "Post") // 自分がフォローしている人の投稿クエリ
//            followingQuery.whereKey("user", matchesKey: "follower", inQuery: relationshipQuery)
//            followingQuery.whereKey("secretKey", notEqualTo: true) // secretKeyがtrueではないもの(鍵が付いていないもの)を表示(nil, false)
//            
//            postQuery = NCMBQuery.orQueryWithSubqueries([myPostQuery, followingQuery]) // クエリの合成
//            postQuery.orderByDescending("postDate") // cellの並べ方
//            postQuery.whereKey("postDate", greaterThanOrEqualTo: CalendarManager.FilterDateStart())
//            postQuery.whereKey("postDate", lessThanOrEqualTo: CalendarManager.FilterDateEnd())
//            postQuery.includeKey("user")
//            
//        }
//        
//        postQuery.findObjectsInBackgroundWithBlock({(objects, error) in
//            if let error = error {
//                print(error.localizedDescription)
//            } else {
//                print("投稿数", objects.count)
//                if objects.count > 0 {
//                    self.postArray = objects
//                } else {
//                    self.postArray = []
//                }
//                self.tableView.reloadData()
//            }
//        })
//    }
    
    func loadItemsFinish(range: Int){
        let loadItemsManager = LoadItemsManager()
        let postQuery: NCMBQuery = loadItemsManager.loadItems(range)
        postQuery.findObjectsInBackgroundWithBlock({(objects, error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                print("投稿数", objects.count)
                if objects.count > 0 {
                    self.postArray = objects
                } else {
                    self.postArray = []
                }
                self.tableView.reloadData()
            }
        })
        
    }

    
    
//    func loadItems(range: Int) {
//        var postQuery: NCMBQuery = NCMBQuery(className: "Post")
//        switch range {
//        case 1:
//            postQuery.whereKey("user", equalTo: NCMBUser.currentUser())
//            postQuery.orderByDescending("postDate") // cellの並べ方
//            postQuery.whereKey("postDate", greaterThanOrEqualTo: CalendarManager.FilterDateStart())
//            postQuery.whereKey("postDate", lessThanOrEqualTo: CalendarManager.FilterDateEnd())
//            postQuery.includeKey("user")
//
//
//        case 2:
//            let relationshipQuery: NCMBQuery = NCMBQuery(className: "Relationship") // 自分がフォローしている人かどうかのクエリ
//            relationshipQuery.whereKey("followed", equalTo: NCMBUser.currentUser())
//            relationshipQuery.whereKey("follower", matchesKey: "user", inQuery: NCMBQuery(className: "Post"))
//            postQuery.whereKey("user", matchesKey: "follower", inQuery: relationshipQuery)// 自分がフォローしている人の投稿クエリ
//            postQuery.whereKey("secretKey", notEqualTo: true) // secretKeyがtrueではないもの(鍵が付いていないもの)を表示(nil, false)
//            postQuery.whereKey("user", notEqualTo: NCMBUser.currentUser())//自分がフォロワーに含まれてたら自分は表示しない
//            postQuery.orderByDescending("postDate") // cellの並べ方
//            postQuery.whereKey("postDate", greaterThanOrEqualTo: CalendarManager.FilterDateStart())
//            postQuery.whereKey("postDate", lessThanOrEqualTo: CalendarManager.FilterDateEnd())
//            postQuery.includeKey("user")
//
//
//        default:
//            let myPostQuery: NCMBQuery = NCMBQuery(className: "Post") // 自分の投稿クエリ
//            myPostQuery.whereKey("user", equalTo: NCMBUser.currentUser())
//            
//            let relationshipQuery: NCMBQuery = NCMBQuery(className: "Relationship") // 自分がフォローしている人かどうかのクエリ
//            relationshipQuery.whereKey("followed", equalTo: NCMBUser.currentUser())
//            relationshipQuery.whereKey("follower", matchesKey: "user", inQuery: NCMBQuery(className: "Post"))
//            
//            let followingQuery: NCMBQuery = NCMBQuery(className: "Post") // 自分がフォローしている人の投稿クエリ
//            followingQuery.whereKey("user", matchesKey: "follower", inQuery: relationshipQuery)
//            followingQuery.whereKey("secretKey", notEqualTo: true) // secretKeyがtrueではないもの(鍵が付いていないもの)を表示(nil, false)
//            
//            postQuery = NCMBQuery.orQueryWithSubqueries([myPostQuery, followingQuery]) // クエリの合成
//            postQuery.orderByDescending("postDate") // cellの並べ方
//            postQuery.whereKey("postDate", greaterThanOrEqualTo: CalendarManager.FilterDateStart())
//            postQuery.whereKey("postDate", lessThanOrEqualTo: CalendarManager.FilterDateEnd())
//            postQuery.includeKey("user")
//
//        }
//        postQuery.findObjectsInBackgroundWithBlock({(objects, error) in
//            if let error = error {
//                print(error.localizedDescription)
//            } else {
//                print("投稿数", objects.count)
//                if objects.count > 0 {
//                    self.postArray = objects
//                } else {
//                    self.postArray = []
//                }
//                self.tableView.reloadData()
//            }
//        })
//    }
    
    
    
//    func loadItems() {
//        
//        let myPostQuery: NCMBQuery = NCMBQuery(className: "Post") // 自分の投稿クエリ
//        myPostQuery.whereKey("user", equalTo: NCMBUser.currentUser())
//        
//        let relationshipQuery: NCMBQuery = NCMBQuery(className: "Relationship") // 自分がフォローしている人かどうかのクエリ
//        relationshipQuery.whereKey("followed", equalTo: NCMBUser.currentUser())
//        relationshipQuery.whereKey("follower", matchesKey: "user", inQuery: NCMBQuery(className: "Post"))
//        
//        let followingQuery: NCMBQuery = NCMBQuery(className: "Post") // 自分がフォローしている人の投稿クエリ
//        followingQuery.whereKey("user", matchesKey: "follower", inQuery: relationshipQuery)
//        followingQuery.whereKey("secretKey", notEqualTo: true) // secretKeyがtrueではないもの(鍵が付いていないもの)を表示(nil, false)
//
//        let postQuery: NCMBQuery = NCMBQuery.orQueryWithSubqueries([myPostQuery, followingQuery]) // クエリの合成
//        postQuery.orderByDescending("postDate") // cellの並べ方
//        postQuery.whereKey("postDate", greaterThanOrEqualTo: CalendarManager.FilterDateStart())
//        postQuery.whereKey("postDate", lessThanOrEqualTo: CalendarManager.FilterDateEnd())
//        postQuery.includeKey("user")
//        
//
//        postQuery.findObjectsInBackgroundWithBlock({(objects, error) in
//            if let error = error {
//                print(error.localizedDescription)
//            } else {
//                if objects.count > 0 {
//                    self.postArray = objects
//                } else {
//                    self.postArray = []
//                }
//                self.tableView.reloadData()
//            }
//        })
//    }
    
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
        if segue.identifier == "toPostDetailViewController" {
            let postDetailVC: PostDetailViewController = segue.destinationViewController as! PostDetailViewController
//            postDetailVC.hidesBottomBarWhenPushed = true // trueならtabBar隠す
            postDetailVC.postObject = self.selectedPostObject
            postDetailVC.delegate = self
            if let sender = sender {
                postDetailVC.isSelectedCommentButton = sender as! Bool
            }
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
        self.exchangeCalendarView()
    }
    
    private func exchangeCalendarView() {
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


extension LogViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellId = "TimelineCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellId, forIndexPath: indexPath) as! TimelineCell
        // 各値をセルに入れる
        let postData = postArray[indexPath.row]
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
                    likedManager.sharedSingleton.isLikedToggle = true
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
        performSegueWithIdentifier("toPostDetailViewController", sender: nil)
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
        if likedManager.sharedSingleton.isLikedToggle == true{
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
                likedManager.sharedSingleton.isLikedToggle = true
                
                //いいねしたことを通知画面のDBに保存
                let auther = postData.objectForKey("user") as! NCMBUser
                let notificationManager = NotificationManager()
                notificationManager.likeNotification(auther, post: postData)
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
        
        postData.removeObject(NCMBUser.currentUser().objectId, forKey: "likeUser")
        postData.saveEventually ({ (error) -> Void in
            if let error = error{
                print(error.localizedDescription)
            }else {
                print("save成功 いいね取り消し")
                likedManager.sharedSingleton.isLikedToggle = false
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

        performSegueWithIdentifier("toPostDetailViewController", sender: true)
    }

}

//DropdownMenuDelegateのDelegate
extension LogViewController: DropdownMenuDelegate {
    func dropdownMenu(dropdownMenu: DropdownMenu, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("DropdownMenu didselect \(indexPath.row) text:\(Dropitems[indexPath.row].title)")
        if indexPath.row != Dropitems.count - 1 {
            self.selectedRow = indexPath.row
        }
        logNumber = indexPath.row
        print("logNumber", logNumber, Dropitems[indexPath.row].title)
        loadItemsFinish(logNumber)
//        
//        switch indexPath.row {
//        case 0:
//            print("0", Dropitems[indexPath.row].title)
////            let loadItemsManager = LoadItemsManager()
////            loadItemsManager.loadItems(0)
//            loadItemsFinish(0)
//        case 1:
//            print("1", Dropitems[indexPath.row].title)
////            let loadItemsManager = LoadItemsManager()
////            loadItemsManager.loadItems(1)
//            loadItemsFinish(1)
//        case 2:
//            print("2", Dropitems[indexPath.row].title)
////            let loadItemsManager = LoadItemsManager()
////            loadItemsManager.loadItems(2)
//            loadItemsFinish(2)
//        default:
//            print("default", Dropitems[indexPath.row].title)
////            let loadItemsManager = LoadItemsManager()
////            loadItemsManager.loadItems(0)
//            loadItemsFinish(0)
//        }
        
//        
//        let alertConroller = UIAlertController(title: "Nice", message: "You choose \(Dropitems[indexPath.row].title)", preferredStyle: .Alert)
//        let okAction = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
//        alertConroller.addAction(okAction)
//        presentViewController(alertConroller, animated: true) {
//            print("Display success")
//        }
    }
}