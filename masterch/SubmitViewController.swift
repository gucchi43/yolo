//
//  SubmitViewController.swift
//  masterch
//
//  Created by Fumiya Yamanaka on 2016/02/09.
//  Copyright © 2016年 Fumiya Yamanaka. All rights reserved.
//

import UIKit
import QBImagePickerController
import NCMB

class SubmitViewController: UIViewController, UITextViewDelegate, QBImagePickerControllerDelegate {
    
    @IBOutlet var postTextView: UITextView!
    @IBOutlet var postTextViewHeight: NSLayoutConstraint!

    var imagePickerController: QBImagePickerController = QBImagePickerController()
    
    
    let notificationCenter = NSNotificationCenter.defaultCenter()
    var isObserving = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        print("SubmitViewController")
        
        self.postTextView.delegate = self
        
    }
    
    // Viewが画面に表示される度に呼ばれるメソッド
    override func viewWillAppear(animated: Bool) {
        if !isObserving {
            // NSNotificationCenterへの登録処理
            let notificationCenter = NSNotificationCenter.defaultCenter()
            notificationCenter.addObserver(self, selector: "showKeyboard:", name: UIKeyboardWillShowNotification, object: nil)
            notificationCenter.addObserver(self, selector: "hideKeyboard:", name: UIKeyboardWillHideNotification, object: nil)
            isObserving = true
        }
    }
    
    // Viewが非表示になるたびに呼び出されるメソッド
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        if isObserving {
            // NSNotificationCenterの解除処理
            let notificationCenter = NSNotificationCenter.defaultCenter()
            notificationCenter.removeObserver(self)
            notificationCenter.removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
            notificationCenter.removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
            isObserving = false
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //画面がタップされた際にキーボードを閉じる処理
    func tapGesture(sender: UITapGestureRecognizer) {
        postTextView.resignFirstResponder()
    }
    
    //キーボードのreturnが押された際にキーボードを閉じる処理
    func textViewShouldReturn(textView: UITextView) -> Bool {
        postTextView.resignFirstResponder()
        self.textViewDidChange(postTextView)
        // itemMemo.resignFirstResponder()
        return true
    }
    
    //textViewを編集する際に行われる処理
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        return true
    }
    
    //キーボードが表示された時
    func showKeyboard(notification: NSNotification) {
        // キーボード表示時の動作をここに記述する
        let rect = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        let duration:NSTimeInterval = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey]as! Double
        UIView.animateWithDuration(duration, animations: {
            let transform = CGAffineTransformMakeTranslation(0, -rect.size.height)
            self.view.transform = transform
            },
            completion:nil)
    }
    func hideKeyboard(notification: NSNotification) {
        // キーボード消滅時の動作をここに記述する
        let duration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as! Double)
        UIView.animateWithDuration(duration, animations:{
            self.view.transform = CGAffineTransformIdentity
            },
            completion:nil)
    }
    // 入力の変更が行わたときの処理
    func textViewDidChange(textView: UITextView) {
        let maxHeight: Float = 80.0  // 入力フィールドの最大サイズ
        if postTextView.frame.size.height.native < maxHeight {
            let size:CGSize = postTextView.sizeThatFits(postTextView.frame.size)
            postTextViewHeight.constant = size.height
        }
    }
    //　カメラボタンをプッシュ
    @IBAction func changePhoto(sender: UIButton) {
        self.presentViewController(self.imagePickerController, animated: true, completion: nil)
        print("カメラボタン押した")
    }
    
    @IBAction func setRange(sender: UIButton) {
        print("公開範囲押した")
    }
    
    // 投稿ボタンプッシュ
    @IBAction func sendButtonTap(sender: UIButton) {
        print("投稿ボタン押した")
    }
    
    

    
}