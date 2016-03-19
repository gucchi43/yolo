//
//  SubmitViewController.swift
//  masterch
//
//  Created by Fumiya Yamanaka on 2016/02/09.
//  Copyright © 2016年 Fumiya Yamanaka. All rights reserved.
//

import UIKit
//import NCMB

class SubmitViewController: UIViewController, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet var postTextView: UITextView!
    @IBOutlet var postTextViewHeight: NSLayoutConstraint!
    
    let notificationCenter = NSNotificationCenter.defaultCenter()
    var isObserving = false
    
    @IBOutlet var submitPostImageView: UIImageView!
    var postImage1: UIImage? = nil
    
    @IBOutlet var postDateTextField: UITextField!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        print("SubmitViewController")
        
        self.postTextView.delegate = self
        
//        テキストフィールドにDatePickerを表示する
        let postDatePicker = UIDatePicker()
        postDateTextField.inputView = postDatePicker
//        日本の日付表示形式にする
        postDatePicker.timeZone = NSTimeZone.localTimeZone()
        
//        UIDatePickerにイベントを設定。
        postDatePicker.addTarget(self, action: "onDidChangeDate:", forControlEvents: .ValueChanged)
        
//        NSDate()で現在時刻をあらかじめ表示する。
        setDate(NSDate())
    }
    
//     Viewが画面に表示される度に呼ばれるメソッド
    override func viewWillAppear(animated: Bool) {
        if !isObserving {
//             NSNotificationCenterへの登録処理
            let notificationCenter = NSNotificationCenter.defaultCenter()
            notificationCenter.addObserver(self, selector: "showKeyboard:", name: UIKeyboardWillShowNotification, object: nil)
            notificationCenter.addObserver(self, selector: "hideKeyboard:", name: UIKeyboardWillHideNotification, object: nil)
            isObserving = true
        }
    }
    
//     Viewが非表示になるたびに呼び出されるメソッド
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        if isObserving {
//             NSNotificationCenterの解除処理
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
    
//    キーボードのreturnが押された際にキーボードを閉じる処理
    func textViewShouldReturn(textView: UITextView) -> Bool {
        postTextView.resignFirstResponder()
        self.textViewDidChange(postTextView)
//         itemMemo.resignFirstResponder() <- これ何か後で調べる
        return true
    }
    
//    textViewを編集する際に行われる処理
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        return true
    }
    
//    キーボードが表示された時
    func showKeyboard(notification: NSNotification) {
//         キーボード表示時の動作をここに記述する
        let rect = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        let duration:NSTimeInterval = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey]as! Double
        UIView.animateWithDuration(duration, animations: {
            let transform = CGAffineTransformMakeTranslation(0, -rect.size.height)
            self.view.transform = transform
            },
            completion:nil)
    }
    
    func hideKeyboard(notification: NSNotification) {
//         キーボード消滅時の動作をここに記述する
        let duration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as! Double)
        UIView.animateWithDuration(duration, animations:{
            self.view.transform = CGAffineTransformIdentity
            },
            completion:nil)
    }
    
    
//     入力の変更が行わたときの処理
    func textViewDidChange(textView: UITextView) {
        let maxHeight: Float = 80.0  // 入力フィールドの最大サイズ
//        if postTextView.frame.size.height.native < maxHeight {
//            let size:CGSize = postTextView.sizeThatFits(postTextView.frame.size)
//            postTextViewHeight.constant = size.height
//        }
    }
    
//     投稿ボタンプッシュ
    @IBAction func postButtonTap(sender: UIButton) {
        print("投稿ボタン押した")
        self.addPost()
        
//        self.dismissViewControllerAnimated(true, completion: nil)
//        上の方法で今戻れないから、ひとまずstoryboardからunwindSegueで戻るように実装している。
        
    }
    
//     投稿機能メソッド
    func addPost() {
//        object作成
        let postObject = NCMBObject(className: "Post")
        
        postObject.setObject(self.postTextView.text, forKey: "text")
        
//        保存対象の画像ファイルを作成する
        if postImage1 != nil {
            let imageData = UIImagePNGRepresentation(self.postImage1!)! as NSData
            let imageFile: NCMBFile = NCMBFile.fileWithData(imageData) as! NCMBFile

            postObject.setObject(imageFile.name, forKey: "image1")
            
//            ファイルはバックグラウンド実行をする
            imageFile.saveInBackgroundWithBlock({ (error: NSError!) -> Void in
                if error == nil {
                    print("画像データ保存完了: \(imageFile.name)")
                } else {
                    print("アップロード中にエラーが発生しました: \(error)")
                }
                }, progressBlock: { (percentDone: Int32) -> Void in
//                    進捗状況を取得します。保存完了まで何度も呼ばれます
                    print("進捗状況: \(percentDone)% アップロード済み")
            })
            
        }
        
        postObject.setObject(postDateTextField.text, forKey: "postDate")
        
        postObject.saveInBackgroundWithBlock({(error) in
            if error != nil {print("Save error : ",error)}
        })
    }
    
    //　カメラボタンをプッシュ
    @IBAction func setPhoto(sender: UIButton) {
//        self.presentViewController(self.imagePickerController, animated: true, completion: nil)
        print("カメラボタン押した")
        
        if !UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
            UIAlertView(title: "警告", message: "Photoライブラリにアクセス出来ません", delegate: nil, cancelButtonTitle: "OK").show()
        } else {
            // アルバムから写真を取得
            self.pickImageFromLibrary()
        }
    }
    
    // ライブラリから写真を選択する
    func pickImageFromLibrary() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
//            インスタンス生成
            let imagePickerController = UIImagePickerController()
//            フォトライブラリから選択
            imagePickerController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
//            編集OFFに設定, trueにすると写真選択時、写真編集画面に移る
            imagePickerController.allowsEditing = false
//            デリゲート設定
            imagePickerController.delegate = self
//            選択画面起動
            self.presentViewController(imagePickerController,animated:true ,completion:nil)
        }
    }
    
    //　写真を選択した時に呼ばれるメソッド
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if info[UIImagePickerControllerOriginalImage] != nil {
            let image = info[UIImagePickerControllerOriginalImage] as! UIImage
            self.postImage1 = image
            self.submitPostImageView.image = image
        }
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //    画像選択がキャンセルされた時に呼ばれる.
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        // モーダルビューを閉じる
        self.dismissViewControllerAnimated(true, completion: nil)
        print("カメラキャンセル")
    }
    
    @IBAction func setRange(sender: UIButton) {
        print("公開範囲を押した")
    }

//    postDatePickerが選ばれた際に呼ばれる.
    func onDidChangeDate(sender: UIDatePicker) {
        setDate(sender.date)
    }
//    postDateのための共通のメソッド
    func setDate(date: NSDate) {
//        フォーマットを生成.
        let postDateFormatter: NSDateFormatter = NSDateFormatter()
        postDateFormatter.dateFormat = "yyyy/MM/dd hh:mm"
//        日付をフォーマットに則って取得.
        let postSelectedDate: NSString = postDateFormatter.stringFromDate(date)
        postDateTextField.text = postSelectedDate as String
    }
    
    
    
}