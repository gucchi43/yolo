//
//  PostDetail.swift
//  masterch
//
//  Created by Fumiya Yamanaka on 2016/02/19.
//  Copyright © 2016年 Fumiya Yamanaka. All rights reserved.
//

import UIKit

class PostDetailViewController: UIViewController {
    
    @IBOutlet weak var postDetailTableView: UITableView!
    
    @IBOutlet weak var commentToolView: UIView!
    @IBOutlet var commentTextView: UITextView!
    @IBOutlet var commentTextViewHeight: NSLayoutConstraint!
    @IBOutlet var sendCommentButton: UIButton!

    var postObject: NCMBObject!
    var isLikeToggle: Bool = false
    var likeCounts: Int?
    
    let likeOnImage = UIImage(named: "hartButton_On")
    let likeOffImage = UIImage(named: "hartButton_Off")
    
    var isObserving = false
    
    var commentArray:[AnyObject] = []

    
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

        sendCommentButton.enabled = false // 初期ではコメントできないように

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
    
    //    キーボードが表示された時
    func showKeyboard(notification: NSNotification) {
        // キーボード表示時の動作をここに記述する
        let rect = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        let tabHeight = self.tabBarController?.rotatingFooterView()?.frame.size.height
        let duration:NSTimeInterval = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as! Double
        UIView.animateWithDuration(duration, animations: {
            let transform = CGAffineTransformMakeTranslation(0, -rect.size.height+tabHeight! )
            self.view.transform = transform
            },completion:nil)
//         self.automaticallyAdjustsScrollViewInsets = false
    }
    
    //    キーボード閉じたとき
    func hideKeyboard(notification: NSNotification) {
        // キーボード消滅時の動作をここに記述する
        let duration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as! Double)
        UIView.animateWithDuration(duration, animations:{
            self.view.transform = CGAffineTransformIdentity
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
        } else {
            sendCommentButton.enabled = false
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

//---------------------コメント投稿機能----------------------
extension PostDetailViewController: UITextViewDelegate {
    
    @IBAction func pushSendCommentButton(sender: UIButton) {
        print("コメント投稿ボタン押した")
        sendComment()

        commentTextView.text = ""
        commentTextView.resignFirstResponder()
        self.view.endEditing(true)

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
    }

}

// tableView
extension PostDetailViewController: UITableViewDataSource{

//        cellの数
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentArray.count + 1
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("postDetailCell") as! PostDetailTableViewCell
            cell.postObject = postObject
            cell.setPostDetailCell()
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("commentCell", forIndexPath: indexPath) as! CommentTableViewCell
            cell.setCommentCell(commentArray[indexPath.row-1] as! NCMBObject)

//            コメントの数-1返す
            return cell
        }
    }
    
}
