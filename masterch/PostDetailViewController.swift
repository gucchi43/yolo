//
//  PostDetail.swift
//  masterch
//
//  Created by Fumiya Yamanaka on 2016/02/19.
//  Copyright © 2016年 Fumiya Yamanaka. All rights reserved.
//

import UIKit
import NCMB
import SwiftDate
import IDMPhotoBrowser

protocol addPostDetailDelegate {
    func postDetailDismissionAction()
}

class PostDetailViewController: UIViewController {
    
    @IBOutlet weak var postDetailTableView: UITableView!
    
    @IBOutlet weak var commentView: UIView!
    @IBOutlet var commentTextView: UITextView!
    @IBOutlet var commentTextViewHeight: NSLayoutConstraint!
    @IBOutlet var sendCommentButton: UIButton!

    var postObject: NCMBObject!
    var postImage: UIImage?
    var likeCounts: Int?
    var isSelectedCommentButton: Bool = false
    
    let likeOnImage = UIImage(named: "hartON")
    let likeOffImage = UIImage(named: "hartOFF")
    
    var isObserving = false
    
    var commentArray:[AnyObject] = []
    var otherUser: NCMBUser!

    var loadPostDetailCelltoken: dispatch_once_t = 0
    
    var delegate: addPostDetailDelegate?

    
    deinit {
        //        notificationCenterの初期化, 必須
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        print("PostDetailViewController ViewDidLoad")

        postDetailTableView.estimatedRowHeight = 370
        postDetailTableView.rowHeight = UITableViewAutomaticDimension
        
        let postNib = UINib(nibName: "PostDetailTableViewCell", bundle: nil)
        postDetailTableView.registerNib(postNib, forCellReuseIdentifier: "postDetailCell")
        
        let commentNib = UINib(nibName: "CommentTableViewCell", bundle: nil)
        postDetailTableView.registerNib(commentNib, forCellReuseIdentifier: "commentCell")
        
        self.loadComments()
        
        let clearView: UIView = UIView(frame: CGRectZero)
        clearView.backgroundColor = UIColor.clearColor()
        postDetailTableView.tableFooterView = clearView // 上下の余計なセル消し

        sendCommentButton.enabled = false // 初期ではコメントできないように
        sendCommentButton.tintColor = UIColor.darkGrayColor()

        if isSelectedCommentButton {
            commentTextView.becomeFirstResponder()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        print("postDetailViewController viewWillAppear")

        if !isObserving {
            let notificationCenter = NSNotificationCenter.defaultCenter()
            notificationCenter.addObserver(self, selector: #selector(PostDetailViewController.showKeyboard), name: UIKeyboardWillShowNotification, object: nil)
            notificationCenter.addObserver(self, selector: #selector(PostDetailViewController.hideKeyboard), name: UIKeyboardWillHideNotification, object: nil)
            isObserving = true
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        // Viewの表示時にキーボード表示・非表示時を監視していたObserverを解放する
        super.viewWillDisappear(animated)
        if isObserving {
            let notification = NSNotificationCenter.defaultCenter()
            notification.removeObserver(self)
            notification.removeObserver(self
                , name: UIKeyboardWillShowNotification, object: nil)
            notification.removeObserver(self
                , name: UIKeyboardWillHideNotification, object: nil)
            isObserving = false
        }
    }
    
    override func didMoveToParentViewController(parent: UIViewController?) {
        super.willMoveToParentViewController(parent)
        print("parent", parent)
        if parent == nil {
            print("ログに戻る")
            self.delegate?.postDetailDismissionAction()
            if postObject == nil {
                print("ログに戻る（削除したパターン）")
                let n = NSNotification(name: "submitFinish", object: self, userInfo: nil)
                NSNotificationCenter.defaultCenter().postNotification(n)
            }
        }
    }
    
    //    キーボードが表示された時
    func showKeyboard(notification: NSNotification) {
        // キーボード表示時の動作をここに記述する
        let rect = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        let tabHeight = self.tabBarController?.rotatingFooterView()?.frame.size.height
        let duration:NSTimeInterval = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as! Double
        UIView.animateWithDuration(duration, animations: {
            let transform = CGAffineTransformMakeTranslation(0, -rect.size.height+tabHeight! )
            self.commentView.transform = transform
            },completion:nil)
    }
    
    //    キーボード閉じたとき
    func hideKeyboard(notification: NSNotification) {
        // キーボード消滅時の動作をここに記述する
        commentTextView.frame.size.height = 30
        commentTextViewHeight.constant = 30
        let duration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as! Double)
        UIView.animateWithDuration(duration, animations:{
            self.commentView.transform = CGAffineTransformIdentity
            },completion:nil)
    }
    
    
    //    commentTextViewのキーボードを表示するメソッド
    func textViewDidChange(textView: UITextView) {
        if(commentTextView.frame.size.height < 80) {
            let size:CGSize = commentTextView.sizeThatFits(commentTextView.frame.size)
            commentTextViewHeight.constant = size.height
        }
        
        if textView.hasText() {
            sendCommentButton.enabled = true
            sendCommentButton.titleLabel!.font = UIFont.boldSystemFontOfSize(15)
            sendCommentButton.tintColor = ColorManager.sharedSingleton.mainColor()
        } else {
            sendCommentButton.enabled = false
            sendCommentButton.titleLabel!.font = UIFont.systemFontOfSize(15)
        }
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        //        カーソルの位置へスクロールさせる
        textView.scrollRangeToVisible(textView.selectedRange)
        return true
    }

    func loadComments() {
        let commentRelation = postObject.relationforKey("comments") as NCMBRelation
        let commentQuery = commentRelation.query()
        commentQuery.orderByAscending("createDate")
        commentQuery.includeKey("user")
        commentQuery.findObjectsInBackgroundWithBlock({(objects, error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                if let commentObjects = objects as? [NCMBObject] {
                    for commentObject in commentObjects {
                        let commentItem = commentObject
                        self.commentArray.append(commentItem)
                    }
                }
                self.postDetailTableView.reloadData()
            }
        })
        
    }
}

//---------------------投稿&コメントユーザー経遷移機能----------------------
extension PostDetailViewController {
    //投稿ユーザーへの遷移
    func segueToPostAccount(){
        otherUser = postObject.objectForKey("user") as! NCMBUser
        performSegueWithIdentifier("toAccountVC", sender: nil)
    }
    
    //コメントユーザーへの遷移
    func segueToCommentAccount(commentObject: NCMBObject){
        otherUser = commentObject.objectForKey("user") as! NCMBUser
        performSegueWithIdentifier("toAccountVC", sender: nil)
    }
    
    //ユーザー情報を遷移先に受け渡し
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toAccountVC" {
            guard let accountVC = segue.destinationViewController as? AccountViewController else { return }
            accountVC.user = otherUser
        }
    }
}


//---------------------コメント投稿機能----------------------
extension PostDetailViewController: UITextViewDelegate {
    
    @IBAction func pushSendCommentButton(sender: UIButton) {
        print("コメント投稿ボタン押した")
        sendComment()

        commentTextView.text = ""
        commentTextView.resignFirstResponder()
        self.view.endEditing(true)
        commentTextViewHeight.constant = 30
        sendCommentButton.titleLabel!.font = UIFont.systemFontOfSize(15)
        sendCommentButton.tintColor = ColorManager.sharedSingleton.mainColor()

        commentArray.removeAll()
        loadComments()
    }
    
    func sendComment() {
//        実質コメント投稿機能
        let commentObject = NCMBObject(className: "Comment")
        commentObject.setObject(NCMBUser.currentUser(), forKey: "user")
        commentObject.setObject(commentTextView.text, forKey: "text")
        commentObject.save(nil)
        
        // commentsフィールドにNCMBRelationを作成
        let relation = NCMBRelation(className: postObject, key: "comments")
        
        relation.addObject(commentObject)
        postObject.save(nil)
        print("コメント保存完了 \(commentObject)")
        
        //コメントしたことを通知画面のDBに保存
        let auther = postObject.objectForKey("user") as! NCMBUser
        let allPostText = postObject.objectForKey("text") as! String
        let allPostTextCount = allPostText.characters.count
        let postHeader: String?
        if allPostTextCount > 100{
            postHeader = allPostText.substringToIndex(allPostText.startIndex.advancedBy(100))
        }else {
            postHeader = allPostText
        }
        print("Notificatoinに保存する最初の５０文字", postHeader!)
        let allCommentText = commentTextView.text
        let allCommentTextCount = allCommentText.characters.count
        let commentHeader: String?
        if allCommentTextCount > 100{
            commentHeader = allCommentText.substringToIndex(allCommentText.startIndex.advancedBy(100))
        }else {
            commentHeader = allCommentText
        }

        let notificationManager = NotificationManager()
        notificationManager.commentNotification(auther, post: postObject, postHeader: postHeader!, commentHeader: commentHeader!)
    }

}

// tableView
extension PostDetailViewController: UITableViewDataSource{

//        cellの数
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentArray.count + 1
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if postObject == nil {
            print("さくじょかんりょう！！！")
            let cell = tableView.dequeueReusableCellWithIdentifier("postDetailCell") as! PostDetailTableViewCell
            cell.userNameIDLabel.text = ""
            cell.userProfileNameLabel.text = ""
            cell.userProfileImageView.image = UIImage(named: "noprofile")
            cell.postDateLabel.text = ""
            cell.postTextLabel.text = "削除されました"

            return cell
        }else {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCellWithIdentifier("postDetailCell") as! PostDetailTableViewCell
                cell.delegate = self
                cell.postObject = postObject
                if postImage != nil {
                    cell.postImage = postImage
                }
                cell.auther = otherUser
                dispatch_once(&loadPostDetailCelltoken){
                    cell.setPostDetailCell()
                }
                return cell
            } else {
                let cell = tableView.dequeueReusableCellWithIdentifier("commentCell", forIndexPath: indexPath) as! CommentTableViewCell
                cell.delegate = self
                cell.commentObject = commentArray[indexPath.row - 1] as? NCMBObject
                cell.setCommentCell()

                //            コメントの数-1返す
                return cell
            }
        }
    }
}

//PostDetailTableViewCellDelegateの受け取って実行
extension PostDetailViewController: PostDetailTableViewCellDelegate, IDMPhotoBrowserDelegate {
    func didSelectCommentButton() {
        commentTextView.becomeFirstResponder()
    }

    func didselectOtherButton(object : NCMBObject) {
        if (object.objectForKey("user") as! NCMBUser).userName == NCMBUser.currentUser().userName {
            let alert: UIAlertController = UIAlertController(title: nil,
                                                             message: nil,

                                                             preferredStyle:  UIAlertControllerStyle.ActionSheet)
            // 編集ボタン
            let remakeAction: UIAlertAction = UIAlertAction(title: "ログを編集する", style: UIAlertActionStyle.Default, handler:{
                // ボタンが押された時の処理を書く（クロージャ実装）
                (action: UIAlertAction!) -> Void in
                print("編集")
            })

            // 削除ボタン
            let defaultAction: UIAlertAction = UIAlertAction(title: "ログを削除する", style: UIAlertActionStyle.Default, handler:{
                // ボタンが押された時の処理を書く（クロージャ実装）
                (action: UIAlertAction!) -> Void in
                print("削除")
                self.deleteAlert(object)
            })
            // キャンセルボタン
            let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertActionStyle.Cancel, handler:{
                // ボタンが押された時の処理を書く（クロージャ実装）
                (action: UIAlertAction!) -> Void in
                print("Cancel")
            })
            //ひとまず編集はなし
//            alert.addAction(remakeAction)
            alert.addAction(cancelAction)
            alert.addAction(defaultAction)
            presentViewController(alert, animated: true, completion: nil)
        }else {
            print("自分以外のため削除出来ない")
        }
    }

    func deleteAlert(object: NCMBObject) {
        //「本当に削除しますか？」アラート呼び出し
        let alert: UIAlertController = UIAlertController(title: "⚠️ログを削除⚠️",
                                                         message: "本当にこのログを削除しますか？",
                                                         preferredStyle:  UIAlertControllerStyle.Alert)
        // OKボタン
        let defaultAction: UIAlertAction = UIAlertAction(title: "削除", style: UIAlertActionStyle.Default, handler:{
            // ボタンが押された時の処理を書く（クロージャ実装）
            (action: UIAlertAction!) -> Void in
            print("削除")
            self.deletePost(object)
        })
        // キャンセルボタン
        let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertActionStyle.Cancel, handler:{
            // ボタンが押された時の処理を書く（クロージャ実装）
            (action: UIAlertAction!) -> Void in
            print("Cancel")
        })
        alert.addAction(cancelAction)
        alert.addAction(defaultAction)
        presentViewController(alert, animated: true, completion: nil)
    }

    func deletePost(object : NCMBObject) {
        print("削除する投稿内容", object)
        object.deleteEventually { (error) in
            if let error = error {
                print(error.localizedDescription)
            }else {
                self.postObject = nil
                self.postDetailTableView.reloadData()
                self.deleteTodayLogColor()
            }
        }
    }

    //消した投稿でその日の投稿が最後か判断
    func deleteTodayLogColor() {
        let logQueryManager = LogQueryManager()
        logQueryManager.loadItems(0).countObjectsInBackgroundWithBlock { (count, error) in
            if let error = error {
                print(error.localizedDescription)
            }else {
                if count == 0 {
                    print("投稿何もない")
                    self.findTodayMonthColorObject()
                    self.findTodayWeekColorObject()
                }else {
                    print("まだ投稿ある")
                }
            }
        }
    }

    //その日のmonthLogColorを取ってくる
    func findTodayMonthColorObject() {
        let logDateTag = CalendarManager.currentDate.toString(DateFormat.Custom("yyyyMMdd"))!
        let logYearAndMonth = CalendarManager.currentDate.toString(DateFormat.Custom("yyyy/MM"))!
        let logColorArrayQuery: NCMBQuery = NCMBQuery(className: "TestColorDic")
        logColorArrayQuery.whereKey("user", equalTo: NCMBUser.currentUser())
        logColorArrayQuery.whereKey("logYearAndMonth", equalTo: logYearAndMonth)
        logColorArrayQuery.getFirstObjectInBackgroundWithBlock { (object, error) in
            if let error = error {
                print(error.localizedDescription)
            }else {
                if object == nil {
                    //その月の投稿がまだなにもない
                }else {
                    print("object", object)
                    let dayColorArrayObject = object.objectForKey("logDateTag") as! [String]
                    let oldLogDateTagInfoArray = dayColorArrayObject.filter { $0.containsString(String(logDateTag))}
                    print("oldLogDateTagInfoArray", oldLogDateTagInfoArray)
                    if oldLogDateTagInfoArray == [] {
                        //その日の投稿はまだ無い
                        print("今月の投稿はあるけどその日の投稿はまだないから追加")
                    }else {
                        //その日はもう投稿している
                        print("その日既に投稿してある要素を置換")
                        let oldLogDateTagInfo = oldLogDateTagInfoArray[0]
                        print("oldLogDateTagInfo", oldLogDateTagInfo)
                        self.removePostedMonthLogColorCache()
                        self.updateLogColorArray(object, logDateTag: Int(logDateTag)!, oldLogDateTagInfo: oldLogDateTagInfo)
                    }
                }
            }
        }
    }


    //その日のweekLogColorを取ってくる
    func findTodayWeekColorObject() {
//        self.removePostedWeekLogColorCache()
        let yearAndWeekNumberArray = CalendarManager.getWeekNumber(CalendarManager.currentDate!)
        let year = yearAndWeekNumberArray[0]
        let weekOfYear = yearAndWeekNumberArray[1]
        let logDateTag = CalendarManager.currentDate.toString(DateFormat.Custom("yyyyMMdd"))! // "yyyy/MM/dd" → "yyyyMMdd"
        let logColorArrayQuery: NCMBQuery = NCMBQuery(className: "TestWeekColorDic")
        logColorArrayQuery.whereKey("user", equalTo: NCMBUser.currentUser())
        logColorArrayQuery.whereKey("year", equalTo: year)
        logColorArrayQuery.whereKey("weekOfYear", equalTo: weekOfYear)
        logColorArrayQuery.getFirstObjectInBackgroundWithBlock { (object, error) in
            if let error = error {
                print(error.localizedDescription)
            }else {
                if object == nil {
                    //その月の投稿がまだなにもない時
                }else {
                    print("object", object)
                    let dayColorArrayObject = object.objectForKey("logDateTag") as! [String]
                    let oldLogDateTagInfoArray = dayColorArrayObject.filter { $0.containsString(String(logDateTag))}
                    print("oldLogDateTagInfoArray", oldLogDateTagInfoArray)
                    if oldLogDateTagInfoArray == [] {
                        //その日の投稿はまだ無い
                        print("今月の投稿はあるけどその日の投稿はまだないから追加")
                    }else {
                        //その日はもう投稿している
                        print("その日既に投稿してある要素を置換")
                        let oldLogDateTagInfo = oldLogDateTagInfoArray[0]
                        print("oldLogDateTagInfo", oldLogDateTagInfo)
                        self.removePostedWeekLogColorCache()
                        self.updateWeekLogColorArray(object, logDateTag: Int(logDateTag)!, oldLogDateTagInfo: oldLogDateTagInfo)
                    }
                }
            }
        }
    }

    //monthlogColorCaheの、投稿があった月の部分を消す(投稿なので自分のみ)
    //このあと、サーバーに保存されたものをもう一度取りに行き、cacheは更新される
    func removePostedMonthLogColorCache () {
        let monthKey = CalendarManager.getDateYearAndMonth(CalendarManager.currentDate)
        let key = String(0) + NCMBUser.currentUser().userName + monthKey
        print("monthのkey", key)
        CalendarLogColorCache.sharedSingleton.myMonthLogColorCache.removeObjectForKey(key)
    }

    //weeklogColorCaheの、投稿があった週の部分を消す(投稿なので自分のみ)
    //このあと、サーバーに保存されたものをもう一度取りに行き、cacheは更新される
    func removePostedWeekLogColorCache() {
        let weekKeyArray = CalendarManager.getWeekNumber(CalendarManager.currentDate)
        let weekKey = String(weekKeyArray[0]) + String(weekKeyArray[1])
        let key = String(0) + NCMBUser.currentUser().userName + weekKey
        print("weekのkey", key)
        CalendarLogColorCache.sharedSingleton.myWeekLogColorCache.removeObjectForKey(key)
    }

    //その日の週のlogColorを削除する
    func updateWeekLogColorArray(object: NCMBObject, logDateTag: Int, oldLogDateTagInfo: String) {
        object.removeObject(oldLogDateTagInfo, forKey: "logDateTag")
        object.saveInBackgroundWithBlock { (error) -> Void in
            if let error = error {
                print(error.localizedDescription)
            }else {
                print("削除成功")
            }
        }
    }

    //その日の月のlogColorを削除する
    func updateLogColorArray(object: NCMBObject, logDateTag: Int, oldLogDateTagInfo: String){
        object.removeObject(oldLogDateTagInfo, forKey: "logDateTag")
        object.saveInBackgroundWithBlock { (error) -> Void in
            if let error = error {
                print(error.localizedDescription)
            }else {
                print("削除成功")
            }
        }
    }

    func didSelectPostProfileImageView() {
        segueToPostAccount()
    }

    func didSelectPostImageView(postImage: UIImage, postText: String) {
        let photo = IDMPhoto(image: postImage)
        photo.caption = postText
        let photos: NSArray = [photo]
        let browser = IDMPhotoBrowser.init(photos: photos as [AnyObject])
        browser.delegate = self
        self.presentViewController(browser,animated:true ,completion:nil)

    }
}

////CommentTableViewCellDelegateの受け取って実行
extension PostDetailViewController: CommentTableViewCellDelegate {
    func didSelectCommentProfileImageView(commentObject: NCMBObject!){
        segueToCommentAccount(commentObject)
    }
}
