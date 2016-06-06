//
//  LogViewController.swift
//  masterch
//
//  Created by Fumiya Yamanaka on 2016/02/09.
//  Copyright © 2016年 Fumiya Yamanaka. All rights reserved.
//

import UIKit

class LogViewController: UIViewController {
    
    var toggleWeek: Bool = false
    var postArray: NSArray = NSArray()
    
    @IBOutlet weak var calendarBaseView: UIView!
    @IBOutlet weak var calendarWeekView: UIView!
    
    @IBOutlet weak var tableView: UITableView!

    var calendarView: CalendarView?
    var calendarAnotherView: CalendarAnotherView?

    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var monthLabel: UILabel!
    
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
    
//    var isLikeToggle: Bool = false
    let likeOnImage = UIImage(named: "hartButton_On")
    let likeOffImage = UIImage(named: "hartButton_Off")
    
//    var likeCount: Int?
    
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
//        self.navigationController?.setToolbarHidden(true, animated: true) // ViewWillAppearは表示の度に呼ばれるので何度も消してくれる

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didSelectDayView:", name: "didSelectDayView", object: nil)
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
        
        let myPostQuery: NCMBQuery = NCMBQuery(className: "Post") // 自分の投稿クエリ
        myPostQuery.whereKey("user", equalTo: NCMBUser.currentUser())
        
        let relationshipQuery: NCMBQuery = NCMBQuery(className: "Relationship") // 自分がフォローしている人かどうかのクエリ
        relationshipQuery.whereKey("followed", equalTo: NCMBUser.currentUser())
        relationshipQuery.whereKey("follower", matchesKey: "user", inQuery: NCMBQuery(className: "Post"))
        
        let followingQuery: NCMBQuery = NCMBQuery(className: "Post") // 自分がフォローしている人の投稿クエリ
        followingQuery.whereKey("user", matchesKey: "follower", inQuery: relationshipQuery)
        followingQuery.whereKey("secretKey", notEqualTo: true) // secretKeyがtrueではないもの(鍵が付いていないもの)を表示(nil, false)

        let postQuery: NCMBQuery = NCMBQuery.orQueryWithSubqueries([myPostQuery, followingQuery]) // クエリの合成
        postQuery.orderByDescending("postDate") // cellの並べ方
        postQuery.whereKey("postDate", greaterThanOrEqualTo: CalendarManager.FilterDateStart())
        postQuery.whereKey("postDate", lessThanOrEqualTo: CalendarManager.FilterDateEnd())
        postQuery.includeKey("user")
        

        postQuery.findObjectsInBackgroundWithBlock({(objects, error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                if objects.count > 0 {
                    self.postArray = objects
                } else {
                    self.postArray = []
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
        if segue.identifier == "toPostDetailViewController" {
            let postDetailVC: PostDetailViewController = segue.destinationViewController as! PostDetailViewController
//            postDetailVC.hidesBottomBarWhenPushed = true // trueならtabBar隠す
            postDetailVC.postObject = self.selectedPostObject
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
        // postTextLabelには(key: "text")の値を入れる
        cell.postTextLabel.text = postData.objectForKey("text") as? String
        // postDateLabelには(key: "postDate")の値を、NSDateからstringに変換して入れる
        let date = postData.objectForKey("postDate") as? NSDate
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
        
//        let likeUser = postData.relationforKey("like")
//        likeUser.query().findObjectsInBackgroundWithBlock{ (objects, error) -> Void in
//            if let error = error{
//                print("error", error.localizedDescription)
//            }else{
//                if objects != nil && objects.isEmpty == false{
//                    let likeUserArray = objects as! [NCMBUser]
//                    let likeCounts = likeUserArray.count
//                    print("投稿の中のぶんしょうううううううううう", cell.postTextLabel.text)
//                    print("likeUserArray & likeCounts", likeUserArray, likeCounts)
//                    
//                    for i in 0 ... likeCounts - 1{
//                        if likeUserArray[i].objectId == NCMBUser.currentUser().objectId{
//                            print("やっっっっっっっっっっっっほおい", likeCounts)
//                            cell.likeButton.setImage(self.likeOnImage, forState: .Normal)
//                            cell.likeCounts = likeCounts
//                            cell.likeNumberButton.setTitle("\(likeCounts)", forState: .Normal)
////                            cell.likeButton.setTitleColor(UIColor.redColor(), forState: .Normal)
//                            self.isLikeToggle = true
//                        }else{
////                            cell.likeButton.setImage(self.likeOffImage, forState: .Normal)
//                            cell.likeCounts = likeCounts
//                            cell.likeNumberButton.setTitle("\(likeCounts)", forState: .Normal)
//                        }
//                    }
//                }else{
//                    print("投稿の中のぶんしょうううううううううう likeがないパターンのヤツ", cell.postTextLabel.text)
//                    print("likeがまだない、またはとりけれされた")
//                }
//            }
//        }
        
        
        if postData.objectForKey("likeUser") != nil{//一度もいいねが来たことがないかも 分岐
            let postLikeUserString = postData.objectForKey("likeUser")
                let cleanLikeUserString = String(postLikeUserString!).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                let superCleanLinkUserString = cleanLikeUserString.stringByReplacingOccurrencesOfString("(\n)", withString: "")
                print("superCleanLinkUserString", superCleanLinkUserString)
            if superCleanLinkUserString.isEmpty == false{//いいねを取り消されて空かも 分岐
                let postLikeUserArray = superCleanLinkUserString.componentsSeparatedByString(",")
                print("postLikeUserArray", postLikeUserArray)
                let postLikeUserCount = postLikeUserArray.count
                print("postLikeUserCount", postLikeUserCount)
                cell.likeCounts = postLikeUserCount
                cell.likeNumberButton.setTitle(String(cell.likeCounts!), forState: .Normal)
                for i in postLikeUserArray{
                    if i.rangeOfString(NCMBUser.currentUser().objectId) != nil{//自分がいいねしている
                        print("私はすでにいいねをおしている")
                        cell.likeButton.setImage(likeOnImage, forState: .Normal)
                        cell.likeNumberButton.setTitleColor(UIColor.redColor(), forState: .Normal)
                        cell.isLikeToggle = true
                    }
                }
            }else {//いいねを取り消されて「空」状態
                cell.likeButton.setImage(likeOffImage, forState: .Normal)
                cell.likeNumberButton.setTitle("", forState: .Normal)
            }
        }else{//一度もいいねが来たことがない
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
        print("row", row)
        let postData = postArray[row!] as! NCMBObject
        
        changeLikeStatus(postData, cell: cell)
        
    }
    
    func changeLikeStatus(postData: NCMBObject, cell: TimelineCell){
        if cell.isLikeToggle == false {//いいねしてない時→いいね
            cell.likeButton.setImage(likeOnImage, forState: .Normal)
            
            if let likeCounts = cell.likeCounts{//likeCountが追加で変更される時（2回目以降）
                if let oldLinkCounts = Int(cell.likeNumberButton.currentTitle!){
                    let newLikeCounts = oldLinkCounts + 1
                    cell.likeNumberButton.setTitle(String(newLikeCounts), forState: .Normal)
                    cell.likeNumberButton.setTitleColor(UIColor.redColor(), forState: .Normal)
                }else {//oldCountがない場合（初めてのいいねじゃないけど、いいね１になる場合）
                    let newLikeCounts = 1
                    cell.likeNumberButton.setTitle(String(newLikeCounts), forState: .Normal)
                    cell.likeNumberButton.setTitleColor(UIColor.redColor(), forState: .Normal)
                }
            }else{//likeCountが初めて変更される時
                let newLikeCounts = 1
                cell.likeNumberButton.setTitle(String(newLikeCounts), forState: .Normal)
                cell.likeNumberButton.setTitleColor(UIColor.redColor(), forState: .Normal)
            }
            
            cell.isLikeToggle = true
            
            postData.addUniqueObject(NCMBUser.currentUser().objectId, forKey: "likeUser")
            postData.saveInBackgroundWithBlock({ (error) -> Void in
                if let error = error{
                    print(error.localizedDescription)
                }else {
                    print("save成功 いいね保存")
                }
            })
            
            
        }else {//いいねしている時→いいねしてない
            cell.likeButton.setImage(likeOffImage, forState: .Normal)
            
            if let likeCounts = cell.likeCounts{
                let oldLinkCounts = Int(cell.likeNumberButton.currentTitle!)
                let newLikeCounts = oldLinkCounts! - 1
                if newLikeCounts > 0{//変更後のlikeCountが0より上の場合（1~）
                    cell.likeNumberButton.setTitle(String(newLikeCounts), forState: .Normal)
                    cell.likeNumberButton.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
                }else {//変更後のlikeCountが0を含むそれ以下の場合(~0)
                    let newLikeCounts = ""
                    cell.likeNumberButton.setTitle(String(newLikeCounts), forState: .Normal)
                    cell.likeNumberButton.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
                }
            }else {//likeCountが今までついたことがなかった場合
                let newLikeCounts = ""
                cell.likeNumberButton.setTitle(String(newLikeCounts), forState: .Normal)
                cell.likeNumberButton.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
            }
            
            cell.isLikeToggle = false
            
            postData.removeObject(NCMBUser.currentUser().objectId, forKey: "likeUser")
            postData.saveInBackgroundWithBlock({ (error) -> Void in
                if let error = error{
                    print(error.localizedDescription)
                }else {
                    print("save成功 いいね取り消し")
                }
            })
            
        }
    }

}

//コメントボタンアクション
extension LogViewController{
    @IBAction func pushCommentButton(sender: UIButton) {
        // 押されたボタンを取得
        let cell = sender.superview?.superview as! TimelineCell
        let row = tableView.indexPathForCell(cell)?.row
        selectedPostObject = self.postArray[row!] as! NCMBObject
        //---------------画面遷移したらキーボードを表示をしていたい--------------
        performSegueWithIdentifier("toPostDetailViewController", sender: true)
    }

}

