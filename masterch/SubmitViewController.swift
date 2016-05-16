//
//  SubmitViewController.swift
//  masterch
//
//  Created by Fumiya Yamanaka on 2016/02/09.
//  Copyright © 2016年 Fumiya Yamanaka. All rights reserved.
//

import UIKit
import TwitterKit
import Fabric

class SubmitViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet var postTextView: UITextView!
    @IBOutlet var postDateTextField: UITextField!
    
    
    @IBOutlet weak var shareTwitterButton: UIButton!
    @IBOutlet weak var shareFacebookButton: UIButton!
    @IBOutlet weak var directinonSecretButton: UIButton!
    
    @IBOutlet weak var twitterButton: UIButton!
    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var secretButton: UIButton!
    
    @IBOutlet weak var twitterBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var facebookBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var secretBottomConstraint: NSLayoutConstraint!
    
    let imgTwitterOn = UIImage(named: "twitter_logo_640*480_origin")
    let imgTwitterOff = UIImage(named: "twitter_logo_640*480_gray")
    let imgFacebookOn = UIImage(named: "facebook_logo_640*480_origin")
    let imgFacebookOff = UIImage(named: "facebook_logo_640*480_gray")
    
    var postImage1: UIImage? = nil
    var toolBar: UIToolbar!
    var postPickerDate: NSDate = NSDate()
    let postTextCharactersLabel: UILabel = UILabel()
    let notificationCenter = NSNotificationCenter.defaultCenter()
    
    let postImageView = UIImageView()
    
    var twitterToggle: Bool = false
    var facebookToggle: Bool = false
    var secretToggle:Bool = false
    
    let user = NCMBUser.currentUser()
    
    var logDate: String?
    var dateColor: String?
    
    var testUserID: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        print("SubmitViewController")
        
        self.setToolBar()
        
        self.postTextView.delegate = self
        
        self.postTextView.text = ""
        self.postTextView.textContainerInset = UIEdgeInsetsMake(5,5,5,5) //postTExtViewに5pxのpaddingを設定する
        self.postTextView.becomeFirstResponder() // 最初からキーボードを表示させる
        self.postTextView.inputAccessoryView = toolBar // キーボード上にツールバーを表示
        
        //NSDate()で現在時刻をあらかじめ表示する。
        setDate(NSDate())
        
        //テキストフィールドにDatePickerを表示する
        let postDatePicker = UIDatePicker()
        self.postDateTextField.inputView = postDatePicker
        //        日本の日付表示形式にする
        postDatePicker.timeZone = NSTimeZone.localTimeZone()
        //        UIDatePickerにイベントを設定。
        postDatePicker.addTarget(self, action: "onDidChangeDate:", forControlEvents: .ValueChanged)
        
        self.postDateTextField.inputAccessoryView = toolBar
        
//        twitterButton.setImage(imgTwitterOff, forState: .Normal)
//        facebookButton.setImage(imgFacebookOff, forState: .Normal)
        
    }
    
//     Viewが画面に表示される度に呼ばれるメソッド
    override func viewWillAppear(animated: Bool) {
//             NSNotificationCenterへの登録処理
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: "showKeyboard:", name: UIKeyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: "hideKeyboard:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewDidLayoutSubviews() {
        if postImage1 != nil {
            //        非表示領域の設定 & imageViewの表示位置
            let exclusionRect = CGRectMake(self.postTextView.contentSize.width/2, 10, self.postTextView.contentSize.width/2, self.postTextView.contentSize.width/2)
            let path = UIBezierPath(rect: exclusionRect)
            self.postTextView.textContainer.exclusionPaths = [path]
            self.postImageView.frame = exclusionRect // 画像の表示する座標を指定する.
            self.postImageView.contentMode = UIViewContentMode.ScaleAspectFit
            self.postTextView.addSubview(postImageView)
        }
    }
    
    deinit {
//        notificationCenterの初期化, 必須
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

//    キーボードが表示された時
    func showKeyboard(notification: NSNotification) {
        let userInfo = notification.userInfo ?? [:]
        let keyboardHeight = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).CGRectValue().size.height //キーボードサイズの取得
        
        self.postTextView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight+40, right: 0) // 下からの高さ(+60は、30がシェアアイコンのサイズの高さでプラス10余裕持っている)
        
        
        
        self.postTextView.scrollIndicatorInsets = self.postTextView.contentInset // キーボードがある時は、一番下の部分をキーボードのしたから10の位置に指定
        let duration : NSTimeInterval = userInfo[UIKeyboardAnimationDurationUserInfoKey]! as! NSTimeInterval
        self.twitterBottomConstraint.constant = keyboardHeight + 5
        self.facebookBottomConstraint.constant = keyboardHeight + 5
        self.secretBottomConstraint.constant = keyboardHeight + 5
        UIView.animateWithDuration(duration, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
    }
//    キーボード閉じたとき
    func hideKeyboard(notification: NSNotification) {
        let userInfo = notification.userInfo ?? [:]
        self.postTextView.contentInset = UIEdgeInsetsZero
        self.postTextView.scrollIndicatorInsets = UIEdgeInsetsZero
        
        self.twitterBottomConstraint.constant = 5
        self.facebookBottomConstraint.constant = 5
        self.secretBottomConstraint.constant = 5
        
        let duration : NSTimeInterval = userInfo[UIKeyboardAnimationDurationUserInfoKey]! as! NSTimeInterval
        UIView.animateWithDuration(duration, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
        
    }

    @IBAction func selectCancelButton(sender: AnyObject) {
        print("キャンセルボタンを押した")
        postTextView.resignFirstResponder() // 先にキーボードを下ろす
        dismissViewControllerAnimated(true, completion: nil)
    }
}
// テキストビュー周り
extension SubmitViewController {
    // テキストビューからフォーカスが失われた
    func textViewShouldEndEditing(textView: UITextView) -> Bool {
        return true
    }

    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {

        let string: NSMutableString = NSMutableString(string: textView.text)
        string.replaceCharactersInRange(range, withString: text)
        
        postTextCharactersLabel.text = String(141-string.length)
        
        if string.length > 140 {
            let alert: UIAlertController = UIAlertController(title: "文字数制限", message: "140文字までで入力してください。", preferredStyle: .Alert)
            let okAction = UIAlertAction(title: "OK", style: .Default) { (action) -> Void in
                print("OK button tapped.")
            }
            
            alert.addAction(okAction)
            presentViewController(alert, animated: true, completion: nil)
            return false
        }
        return true
    }
    
    func textViewDidChange(textView: UITextView) {
    }
}

//SNSシェアセレクトボタン
extension SubmitViewController {
    //Twitterシェア
        @IBAction func selectShareTwitter(sender: AnyObject) {
        print("twitterボタン押した")
        print("初期状態だぞおおおおお", twitterToggle)
        //Twitterと連携しているか？
        if let userID = user.objectForKey("twitterID") {
            if userID.isKindOfClass(NSNull) != true {//「userID」がnullじゃないか？
                if let userLink = Twitter.sharedInstance().sessionStore.sessionForUserID(userID as! String){
                    print("Twitter連携済 userID:", userLink.userID)//Twitter連携している
                    twitterToggle = !twitterToggle //連携済みの場合の切り替えToggle
                    if twitterToggle == true{
                        twitterButton.setImage(imgTwitterOn, forState: .Normal)
                        //ツイッターシェアはtrue
                        print("シェアする", twitterToggle)
                    }else {
                        twitterButton.setImage(imgTwitterOff, forState: .Normal)
                        //ツイッターシェアはtrue
                        print("シェアしない" , twitterToggle)
                    }
                }else {
                    print("ありえないはず: twitterIDは登録してるのにTwitterSessionがsaveできていない")
                    self.postTextView.endEditing(true)
                    let containerSnsViewController = ContainerSnsViewController()
                    containerSnsViewController.addSnsToTwitter(user)
//                                        twitterToggle = !twitterToggle //未連携の場合の切り替えToggle → ON
//                                        shareTwitterButton.setImage(imgTwitterOn, forState: .Normal)
//                                        print("シェアする", twitterToggle)
                }
            }else {
                print("Twitter未連携（外した状態） userID", userID)//Twitter連携をはずして、空っぽの状態
                //Twitter未連携
                self.postTextView.endEditing(true)
                let containerSnsViewController = ContainerSnsViewController()
                containerSnsViewController.addSnsToTwitter(user)
                //                twitterToggle = !twitterToggle //未連携の場合の切り替えToggle → ON
                //                shareTwitterButton.setImage(imgTwitterOn, forState: .Normal)
                //                print("シェアする", twitterToggle)
            }
        }else {
            print("Twitter未連携")//Twitter連携は今まで一度もしていない
            //Twitter未連携
            self.postTextView.endEditing(true)
            let containerSnsViewController = ContainerSnsViewController()
            containerSnsViewController.addSnsToTwitter(user)
            //            twitterToggle = !twitterToggle //未連携の場合の切り替えToggle → ON
            //            shareTwitterButton.setImage(imgTwitterOn, forState: .Normal)
            //            print("シェアする", twitterToggle)
        }
    }
    
    //Facebookシェア
    @IBAction func selectShareFacebook(sender: AnyObject) {
        print("Facebookボタン押した")
        facebookToggle = !facebookToggle
        if facebookToggle == true{
            facebookButton.setImage(imgFacebookOn, forState: .Normal)
            print(facebookToggle)
        }else {
            facebookButton.setImage(imgFacebookOff, forState: .Normal)
            print(facebookToggle)
        }
    }
    
    
    //secret切り替え
    @IBAction func selectSeacret(sender: AnyObject) {
        secretToggle = !secretToggle
        if secretToggle == true {
            print("Secret投稿")
        }else {
            print("Secret投稿無し")
        }

    }
    
}

// toolBar
extension SubmitViewController {
    func setToolBar() {
        // UIToolBarの設定
        toolBar = UIToolbar(frame: CGRectMake(0, self.view.frame.size.height/6, self.view.frame.size.width, 35.0))
        toolBar.layer.position = CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height-20.0)
        toolBar.barStyle = .Default
        //        toolBar.tintColor = UIColor.whiteColor()
        //        toolBar.backgroundColor = UIColor.blackColor()
        let toolBarCameraButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Camera, target: self, action: "selectToolBarCameraButton:")
//        let toolBarDateSelectButton = UIBarButtonItem(title: "日付", style: .Plain, target: self, action: "selectToolBarDateSelectButton:") 一旦なし
        let toolBarPencilButton = UIBarButtonItem(title: "テキスト", style: .Plain, target: self, action: "selectToolBarPencilButton:")
        let toolBarRangeButton = UIBarButtonItem(title: "公開範囲", style: .Plain, target: self, action: "selectToolBarRangeButton:")
        let toolBarPostButton = UIBarButtonItem(title: "完了", style: .Done, target: self, action: "selectToolBarDoneButton:")

        postTextCharactersLabel.frame = CGRectMake(0, 0, 30, 35)
        postTextCharactersLabel.text = "140"
        postTextCharactersLabel.textColor = UIColor.lightGrayColor()
        let toolBarPostTextcharacterLabelItem = UIBarButtonItem(customView: postTextCharactersLabel)
        // Flexible Space Bar Button Item
        let flexibleItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        
        toolBar.items = [toolBarCameraButton, toolBarPencilButton, toolBarRangeButton, flexibleItem, toolBarPostTextcharacterLabelItem, toolBarPostButton]
    }
}

// カメラ周り
extension SubmitViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    
    func selectToolBarCameraButton(sender: UIBarButtonItem) {
        print("カメラボタン押した")
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
//             アルバムから写真を取得
            self.pickImageFromLibrary()
//        } else if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
//            self.pickImageFromCamera()
        } else {
            UIAlertView(title: "警告", message: "Photoライブラリにアクセス出来ません", delegate: nil, cancelButtonTitle: "OK").show()
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
//    写真を撮影
    func pickImageFromCamera() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            let controller = UIImagePickerController()
            controller.delegate = self
            controller.sourceType = UIImagePickerControllerSourceType.Camera
            self.presentViewController(controller, animated: true, completion: nil)
        }
    }
    
    //　写真を選択した時に呼ばれるメソッド
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if info[UIImagePickerControllerOriginalImage] != nil {
            var image = info[UIImagePickerControllerOriginalImage] as! UIImage
            
            // 画像をリサイズしてUIImageViewにセット
            let resizeImage = resize(image, width: 480, height: 320)
            image = resizeImage
            
            self.postImage1 = image
            self.postImageView.image = image
            self.postTextView.endOfDocument

        }
        picker.dismissViewControllerAnimated(true, completion: nil)
        self.postTextView.becomeFirstResponder()
    }
    
    //    画像選択がキャンセルされた時に呼ばれる.
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        // モーダルビューを閉じる
        self.dismissViewControllerAnimated(true, completion: nil)
        self.postTextView.becomeFirstResponder()
        print("カメラキャンセル")
    }
    
    // 画像リサイズメソッド
    func resize(image: UIImage, width: Int, height: Int) -> UIImage {
        let size: CGSize = CGSize(width: width, height: height)
        UIGraphicsBeginImageContext(size)
        image.drawInRect(CGRectMake(0, 0, size.width, size.height))
        
        let resizeImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizeImage
    }
}

// 日付選択
extension SubmitViewController {
    func selectToolBarDateSelectButton(sender: UIBarButtonItem) {
        print("日付選択を押した")
        
        //        テキストフィールドにDatePickerを表示する
        let postDatePicker = UIDatePicker()
        postDateTextField.inputView = postDatePicker
        postDateTextField.inputAccessoryView = toolBar
        
        //        日本の日付表示形式にする
        postDatePicker.timeZone = NSTimeZone.localTimeZone()
        
        //        UIDatePickerにイベントを設定。
        postDatePicker.addTarget(self, action: "onDidChangeDate:", forControlEvents: .ValueChanged)
//        self.view.addSubview(postDatePicker)
    }
    
    //    postDatePickerが選ばれた際に呼ばれる.
    func onDidChangeDate(sender: UIDatePicker) {
        setDate(sender.date)
        postPickerDate = sender.date
    }
    //    postDateのための共通のメソッド
    func setDate(date: NSDate) {
        //        フォーマットを生成.
        let postDateFormatter: NSDateFormatter = NSDateFormatter()
        postDateFormatter.dateFormat = "yyyy/MM/dd HH:mm"
        //        日付をフォーマットに則って取得.
        postDateTextField.text = postDateFormatter.stringFromDate(date)
    }
}

// 公開範囲
extension SubmitViewController {
    func selectToolBarRangeButton(sender:UIBarButtonItem) {
        print("公開範囲ボタンを押した")
        let snsKeyboardview:UIView = UINib(nibName: "SnsKeyboard", bundle: nil).instantiateWithOwner(self, options: nil)[0] as! UIView
        self.postTextView.inputView = snsKeyboardview
        self.postTextView.reloadInputViews()
    }
    
    @IBAction func pushShareTwitter(sender: AnyObject) {
    }
    //TODO: 途中の状態（見た目だけは動く）
    @IBAction func pushShareFacebook(sender: AnyObject) {
    }
    
    @IBAction func pushDidectionSecret(sender: AnyObject) {
    }
}


// テキストボタン
extension SubmitViewController {
    func selectToolBarPencilButton(sender: UIBarButtonItem) {
        print("テキストボタン押した")
//        let snsKeyboardview:UIView = UINib(nibName: "SnsKeyboard", bundle: nil).instantiateWithOwner(self, options: nil)[0] as! UIView
        self.postTextView.inputView = nil
        self.postTextView.reloadInputViews()
    }
}


// 投稿アクション周り
extension SubmitViewController {
//    投稿ボタンプッシュ, 投稿機能メソッド
    @IBAction func selectPostButton(sender: AnyObject) {
        print("投稿ボタン押した")
        //        object作成
        let postObject = NCMBObject(className: "Post")
//         ユーザーを関連づけ
        postObject.setObject(NCMBUser.currentUser(), forKey: "user")
        
        postObject.setObject(self.postTextView.text, forKey: "text")
        postObject.setObject(postPickerDate, forKey: "postDate")
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
        self.setLogColor() //"logColor"クラスへのセット
        
//        非同期通信の保存処理
        postObject.saveInBackgroundWithBlock({(error) in
            if error != nil {print("Save error : ",error)}
        })

        postTextView.resignFirstResponder() // 先にキーボードを下ろす
        self.dismissViewControllerAnimated(true, completion: nil)
        print("投稿完了")
        
        
        //Twitterシェアかの判断
        if twitterToggle == true {
            if self.postImage1 != nil{
                shareTwitterMedia()
                print("twitterシェア完了 メディアあり")
            }else {
                shareTwitterPost()
                print("twitterシェア完了 メディアなし")
            }
        }else {
            print("Twitterシェア無し")
        }
        
        //Facebookシェアかの判断
//        if twitterToggle == true {
//            shareFacebookPost()
//            print("twitterシェア完了")
//        }else {
//            print("twitterシェアなし")
//        }
        
        //Secretモードかの判断
        if secretToggle == false {
            print("Secret投稿")
        }else {
            print("Secret投稿無し")
        }
    }
}



//Twitterシェア
extension SubmitViewController {
    func shareTwitterPost(mediaID: String? = nil){//mediaIDの初期値をnilに（複数にすると多分Arrayになる）
        if let userID = Twitter.sharedInstance().sessionStore.session()?.userID{
            let client = TWTRAPIClient(userID: userID)
            print("userID", userID)
            
            let statusesShowEndpoint = "https://api.twitter.com/1.1/statuses/update.json"
            let tweetText = self.postTextView.text
            print("tweetText", tweetText)
            var params = ["status": tweetText]
            
            //写真の添付があればparamsの配列に"media_ids"のキーと値を追加
            if mediaID != nil {
                params["media_ids"] = mediaID
            }
            print("params ここが変わるはず", params)
            
            var clientError : NSError?
            
            let request = client.URLRequestWithMethod("POST", URL: statusesShowEndpoint, parameters: params, error: &clientError)
            
            client.sendTwitterRequest(request) { (response, data, connectionError) -> Void in
                if connectionError != nil {
                    print("Error: \(connectionError)")
                }
                
                do {
                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options: [])
                    print("json: \(json)")
                } catch let jsonError as NSError {
                    print("json error: \(jsonError.localizedDescription)")
                }
            }
        }
    }
    
    //twitterメディア添付シェア
    func shareTwitterMedia(){
        if let userID = Twitter.sharedInstance().sessionStore.session()?.userID{
            let client = TWTRAPIClient(userID: userID)
            print("userID", userID)
            
            let statusesShowEndpoint = "https://upload.twitter.com/1.1/media/upload.json"
            let imageData = UIImagePNGRepresentation(self.postImage1!)
            let media = imageData!.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.EncodingEndLineWithLineFeed)
            let params = ["media": media]
            
            var clientError : NSError?
            
            let request = client.URLRequestWithMethod("POST", URL: statusesShowEndpoint, parameters: params, error: &clientError)
            
            client.sendTwitterRequest(request) { (response, data, connectionError) -> Void in
                if connectionError != nil {
                    print("Error: \(connectionError)")
                }
                
                do {
                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)
                    let mediaID = json["media_id_string"] as! String
                    print("mediaID", mediaID)
                    self.shareTwitterPost(mediaID)
                    //                    self.shareTwitterPost()
                } catch let jsonError as NSError {
                    print("json error: \(jsonError.localizedDescription)")
                }
            }
        }
    }

}

//Facebookシェア
extension SubmitViewController {
    func shareFacebookPost(){
    }
}


//Secretモード
extension SubmitViewController {
    func secretPost(){
    }
}

extension SubmitViewController {
    func setLogColor(){
        self.dateColor = "red"
        let longLogDate = postDateTextField.text //投稿画面に表示されている投稿する日時（PostDateのString版）
        let logDate = longLogDate!.substringToIndex((longLogDate?.startIndex.advancedBy(10))!) // "yyyy/MM/dd HH:mm" → "yyyy/MM/dd"
        print("logDate", logDate)
        let myLogColorQuery: NCMBQuery = NCMBQuery(className: "LogColor") // 自分の投稿クエリ
        myLogColorQuery.whereKey("user", equalTo: user)
        myLogColorQuery.whereKey("logDate", equalTo: logDate)
        myLogColorQuery.getFirstObjectInBackgroundWithBlock { (object, error) -> Void in
            if let error = error {
                print(error.localizedDescription)
            }else {
                if object == nil {
                    //今日の投稿はまだない
                    self.firstSetLogColor(logDate)
                }else {
                    //２度目以降の投稿
                    self.updateLogColor()
                }
            }
        }
    }
    
    //今日初めての投稿
    func firstSetLogColor(logDate: String){
        let logColorObject = NCMBObject(className: "LogColor")
        logColorObject.setObject(user, forKey: "user")
        logColorObject.setObject(logDate, forKey: "logDate")
        logColorObject.setObject(self.dateColor, forKey: "dateColor")
        logColorObject.incrementKey("postCount")
        
        logColorObject.saveInBackgroundWithBlock { (error) -> Void in
            if error != nil {
                print("error", error)
            }else {
                print("logColor 今日初めての投稿 save成功")
            }
        }
    }
    
    
    //今日２回目以降の投稿
    func updateLogColor(){
        
    }
    
}


// 完了ボタン
extension SubmitViewController {
    func selectToolBarDoneButton(sender: UIBarButtonItem) {
        print("完了ボタン押した")
        self.view.endEditing(true)
    }
}
