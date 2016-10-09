//
//  SubmitViewController.swift
//  masterch
//
//  Created by Fumiya Yamanaka on 2016/02/09.
//  Copyright © 2016年 Fumiya Yamanaka. All rights reserved.
//

import UIKit
import NCMB
import TwitterKit
import Fabric
import FBSDKLoginKit
import TTTAttributedLabel


protocol SubmitViewControllerDelegate {
    func submitFinish()
    func savePostProgressBar(percentDone: CGFloat)
}

class SubmitViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet var postTextView: UITextView!
    @IBOutlet var postDateTextField: UITextField!
    
    @IBOutlet weak var postDateLabel: UILabel!
    @IBOutlet weak var submitButton: UIBarButtonItem!
    @IBOutlet weak var twitterButton: UIButton!
    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var secretKeyButton: UIButton!
    @IBOutlet weak var currentEmojiLabel: UILabel!

    
    @IBOutlet weak var twitterBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var facebookBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var secretKeyBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var currentEmojiConstraint: NSLayoutConstraint!

    let imgTwitterOn = UIImage(named: "twitterON")
    let imgTwitterOff = UIImage(named: "twitterGray")
    let imgFacebookOn = UIImage(named: "facebookON")
    let imgFacebookOff = UIImage(named: "facebookGray")
    
    @IBOutlet weak var redButton: UIButton!
    @IBOutlet weak var yellowButton: UIButton!
    @IBOutlet weak var pinkButton: UIButton!
    @IBOutlet weak var blueButton: UIButton!
    @IBOutlet weak var greenButton: UIButton!
    @IBOutlet weak var grayButton: UIButton!

    @IBOutlet weak var goodButton: UIButton!
    @IBOutlet weak var badButton: UIButton!
    
    
    var postImage1: UIImage? = nil
    var toolBar: UIToolbar!
    var postPickerDate: NSDate = NSDate()
    let postTextCharactersLabel: UILabel = UILabel()
    let notificationCenter = NSNotificationCenter.defaultCenter()
    
    let postImageView = UIImageView()
    
    var twitterToggle = false
    var facebookToggle = false
    var secretKeyToggle = false
    
    let user = NCMBUser.currentUser()
    
    var logDate: String?
    var dateColor: String = "g"
    
    var postDate : NSDate?
    var weekToggle = false
    
    var delegate: SubmitViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        print("SubmitViewController")
    }
        
//     Viewが画面に表示される度に呼ばれるメソッド
    override func viewWillAppear(animated: Bool) {
        self.setToolBar()
        self.currentEmojiLabel.text = "エモジ"
        
        self.postTextView.delegate = self
        self.postTextView.textContainerInset = UIEdgeInsetsMake(5,5,5,5) //postTExtViewに5pxのpaddingを設定する
        self.postTextView.becomeFirstResponder() // 最初からキーボードを表示させる
        self.postTextView.inputAccessoryView = toolBar // キーボード上にツールバーを表示

        postPickerDate = CalendarManager.currentDate
        
        if let postDate = postDate {
            //選択されたNSDateを表示する。®
            setDate(postDate)
        }else {
            //NSDate()で現在時刻をあらかじめ表示する。
            setDate(NSDate())
        }

        
        //テキストフィールドにDatePickerを表示する
        let postDatePicker = UIDatePicker()
        self.postDateTextField.inputView = postDatePicker
        //        日本の日付表示形式にする
        postDatePicker.timeZone = NSTimeZone.localTimeZone()
        //指定された日付があれば代入する（無ければ現在のNSDate）
        if let postDate = postDate{
            postDatePicker.date = postDate
        }
        //        UIDatePickerにイベントを設定。
        postDatePicker.addTarget(self, action: #selector(SubmitViewController.onDidChangeDate(_:)), forControlEvents: .ValueChanged)
        
        self.postDateTextField.inputAccessoryView = toolBar
        
        if postImage1 == nil {
            submitButton.enabled = false
        } else {
            submitButton.enabled = true
        }

//             NSNotificationCenterへの登録処理
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: #selector(SubmitViewController.showKeyboard(_:)), name: UIKeyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(SubmitViewController.hideKeyboard(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewDidLayoutSubviews() {
        
    }
    
    deinit {
//        notificationCenterの初期化, 必須
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

//    キーボードが表示された時
    func showKeyboard(notification: NSNotification) {
        let userInfo = notification.userInfo ?? [:]
        let keyboardHeight = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue().size.height //キーボードサイズの取得
        
        self.postTextView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight+40, right: 0) // 下からの高さ(+40は、30がシェアアイコンのサイズの高さでプラス10余裕持っている)
        
        self.postTextView.scrollIndicatorInsets = self.postTextView.contentInset // キーボードがある時は、一番下の部分をキーボードのしたから10の位置に指定
        let duration : NSTimeInterval = userInfo[UIKeyboardAnimationDurationUserInfoKey]! as! NSTimeInterval
        self.twitterBottomConstraint.constant = keyboardHeight + 5
        self.facebookBottomConstraint.constant = keyboardHeight + 5
        self.secretKeyBottomConstraint.constant = keyboardHeight + 5
        self.currentEmojiConstraint.constant = keyboardHeight + 5
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
        self.secretKeyBottomConstraint.constant = 5
        self.currentEmojiConstraint.constant = 5
        
        let duration : NSTimeInterval = userInfo[UIKeyboardAnimationDurationUserInfoKey]! as! NSTimeInterval
        UIView.animateWithDuration(duration, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
        
    }

    @IBAction func selectCancelButton(sender: AnyObject) {
        print("キャンセルボタンを押した")
        postTextView.resignFirstResponder() // 先にキーボードを下ろす
        postDateTextField.resignFirstResponder()
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

        if postImage1 != nil {
            // imageViewの表示位置
            self.postImageView.frame.origin = CGPointMake(0, textView.contentSize.height + 10)
            postImageView.center.x = self.postTextView.bounds.width/2
        }

        //labelを新規作成するために、textViewのCGPointをゲット
        let labelPoint = textView.frame.origin
        let labelWidth = textView.bounds.width
        let labelHeigth = textView.bounds.height
        //TTTLabel初期化
        let TTTLabel = TTTAttributedLabel.init(frame: CGRect(origin: labelPoint, size: CGSizeMake(labelWidth, labelHeigth)))
        //自動リンク機能つけて、text入れる
        TTTLabel.enabledTextCheckingTypes = NSTextCheckingType.Link.rawValue
        TTTLabel.text = text
//        文字数カウント
        let string: NSMutableString = NSMutableString(string: textView.text)
        string.replaceCharactersInRange(range, withString: text)
        
        if string.length > 0 {
            submitButton.enabled = true
        } else {
            if postImage1 == nil {
                submitButton.enabled = false
            }
        }

        postTextCharactersLabel.text = String(140-string.length)
        
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
}

// toolBar設定
extension SubmitViewController {
    func setToolBar() {
        // UIToolBarの設定
        toolBar = UIToolbar(frame: CGRectMake(0, self.view.frame.size.height/6, self.view.frame.size.width, 35.0))
        toolBar.layer.position = CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height-20.0)
        toolBar.barStyle = .Default
        //        toolBar.tintColor = UIColor.whiteColor()
        //        toolBar.backgroundColor = UIColor.blackColor()
        let toolBarCameraButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Camera, target: self, action: #selector(SubmitViewController.selectToolBarCameraButton(_:)))
        let toolBarPencilButton = UIBarButtonItem(title: "テキスト", style: .Plain, target: self, action: #selector(SubmitViewController.selectToolBarPencilButton(_:)))
        let toolBarGoodOrBadButton = UIBarButtonItem(title: "どんな日？", style: .Plain, target: self, action: #selector(SubmitViewController.selectToolBarGoodOrBadButton(_:)))
        //ColorKeyboardを使う時のボタン
//        let toolBarColorButton = UIBarButtonItem(title: "カラー", style: .Plain, target: self, action: #selector(SubmitViewController.selectToolBarColorButton(_:)))
        let toolBarDoneButton = UIBarButtonItem(title: "完了", style: .Done, target: self, action: #selector(SubmitViewController.selectToolBarDoneButton(_:)))

        postTextCharactersLabel.frame = CGRectMake(0, 0, 30, 35)
        postTextCharactersLabel.text = "140"
        postTextCharactersLabel.textColor = UIColor.lightGrayColor()
        let toolBarPostTextcharacterLabelItem = UIBarButtonItem(customView: postTextCharactersLabel)
        // Flexible Space Bar Button Item
        let flexibleItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        
        toolBar.items = [toolBarCameraButton, toolBarPencilButton, toolBarGoodOrBadButton, flexibleItem, toolBarPostTextcharacterLabelItem, toolBarDoneButton]
    }
}

// カメラ周り
extension SubmitViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate  {

    func selectToolBarCameraButton(sender: UIBarButtonItem) {
        print("カメラ&カメラロール呼び出しボタン押した")
        let alert: UIAlertController = UIAlertController(title: nil,
                                                         message: nil,
                                                         preferredStyle:  UIAlertControllerStyle.ActionSheet)
        // OKボタン
        let cameraAction: UIAlertAction = UIAlertAction(title: "カメラ", style: UIAlertActionStyle.Default, handler:{
            // ボタンが押された時の処理を書く（クロージャ実装）
            (action: UIAlertAction!) -> Void in
            print("カメラ選択")
            self.pickImageFromCamera()
        })
        let libraryAction: UIAlertAction = UIAlertAction(title: "カメラロール", style: UIAlertActionStyle.Default, handler:{
            // ボタンが押された時の処理を書く（クロージャ実装）
            (action: UIAlertAction!) -> Void in
            print("カメラ選択")
            self.pickImageFromLibrary()
        })

        // キャンセルボタン
        let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertActionStyle.Cancel, handler:{
            // ボタンが押された時の処理を書く（クロージャ実装）
            (action: UIAlertAction!) -> Void in
            print("Cancel")
        })
        alert.addAction(cancelAction)
        alert.addAction(cameraAction)
        alert.addAction(libraryAction)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    // ライブラリから写真を選択する
    func pickImageFromLibrary() {
        print("カメラロール起動")
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
        print("カメラ起動")
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            let controller = UIImagePickerController()
            controller.delegate = self
            controller.sourceType = UIImagePickerControllerSourceType.Camera
            self.presentViewController(controller, animated: true, completion: nil)
        }
    }
    
    //　写真を選択した時に呼ばれるメソッド
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        guard let image: UIImage = info[UIImagePickerControllerOriginalImage] as? UIImage else { return }
        UIImageWriteToSavedPhotosAlbum(image, self, nil, nil)
        let resizedImage = resize(image)
        self.postImage1 = resizedImage
        self.postImageView.image = resizedImage

        postImageView.frame = CGRectMake(0, postTextView.contentSize.height+10, self.postTextView.contentSize.width*0.9, self.postTextView.contentSize.width*0.9)
        postImageView.center.x = self.postTextView.bounds.width/2
        self.postImageView.contentMode = UIViewContentMode.ScaleAspectFill
        postImageView.layer.cornerRadius = 5.0
        postImageView.clipsToBounds = true
        self.postTextView.addSubview(postImageView)
        self.postTextView.endOfDocument

        picker.dismissViewControllerAnimated(true, completion: nil)
        self.postTextView.becomeFirstResponder()
    }
    
    // 画像リサイズメソッド
    func resize(image: UIImage) -> UIImage {
        if image.size.height < 1000 || image.size.width < 1000  {
            return image
        }
        var scale:CGFloat = 1.0
        if image.size.height >= image.size.width {
            scale = 1000.0 / image.size.height
        } else if image.size.height < image.size.width {
            scale = 1000.0 / image.size.width
        }

        let resizedSize = CGSizeMake(image.size.width*scale, image.size.height*scale)
        print(resizedSize)
        UIGraphicsBeginImageContext(resizedSize)
        image.drawInRect(CGRectMake(0, 0, resizedSize.width, resizedSize.height))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return resizedImage
    }

    //    画像選択がキャンセルされた時に呼ばれる.
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        // モーダルビューを閉じる
        self.dismissViewControllerAnimated(true, completion: nil)
        self.postTextView.becomeFirstResponder()
        print("カメラキャンセル")
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
        postDatePicker.addTarget(self, action: #selector(SubmitViewController.onDidChangeDate(_:)), forControlEvents: .ValueChanged)
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
        postDateLabel.text = postDateFormatter.stringFromDate(date)
//        postDateTextField.text = postDateFormatter.stringFromDate(date)
//        postDateLabel.text = postDateTextField.text
        postDate = date
    }
}

//logColor選択
extension SubmitViewController {

    func setSelectEmoji(emojiString: String) {
        print("setSelectEmoji側: emojiString", emojiString)
        self.currentEmojiLabel.text = emojiString
        self.dateColor = emojiString
    }

    func selectToolBarGoodOrBadButton(sender:UIBarButtonItem) {

        print("カラーボタンを押した")

        let emojiKeyboard = EmojiCollectionKeyboard(frame: CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.width, height: 216))
        self.postTextView.inputView = emojiKeyboard
        self.postTextView.reloadInputViews()
    }

    @IBAction func selectGood(sender: AnyObject) {
        print("Goodボタン押した")
        self.dateColor = "a"
        toolBar.backgroundColor = UIColor.redColor()
    }

    @IBAction func selectBad(sender: AnyObject) {
        print("Badボタン押した")
        self.dateColor = "b"
        toolBar.backgroundColor = UIColor.blueColor()
    }



    @IBAction func selectedA(sender: AnyObject) {
        print("Aボタン押した")
        self.dateColor = "a"
        toolBar.backgroundColor = UIColor.redColor()
    }

    @IBAction func selectedB(sender: AnyObject) {
        print("Bボタン押した")
        self.dateColor = "b"
        toolBar.backgroundColor = UIColor.redColor()
    }

    @IBAction func selectedC(sender: AnyObject) {
        print("Cボタン押した")
        self.dateColor = "c"
        toolBar.backgroundColor = UIColor.redColor()
    }

    @IBAction func selectedD(sender: AnyObject) {
        print("Dボタン押した")
        self.dateColor = "d"
        toolBar.backgroundColor = UIColor.blueColor()
    }

    @IBAction func selectedE(sender: AnyObject) {
        print("Eボタン押した")
        self.dateColor = "e"
        toolBar.backgroundColor = UIColor.blueColor()
    }
    @IBAction func selectedF(sender: AnyObject) {
        print("Fボタン押した")
        self.dateColor = "f"
        toolBar.backgroundColor = UIColor.blueColor()
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
    @IBAction func selectSubmitButton(sender: AnyObject) {
        print("投稿ボタン押した")
        //        object作成
        let postObject = NCMBObject(className: "Post")
        //         ユーザーを関連づけ
        postObject.setObject(NCMBUser.currentUser(), forKey: "user")
        postObject.setObject(self.postTextView.text, forKey: "text")
        postObject.setObject(postPickerDate, forKey: "postDate")
        postObject.setObject(secretKeyToggle, forKey: "secretKey")
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
                    let postProgress = CGFloat(percentDone)/CGFloat(100)
                    print("postProgress", postProgress)
                    self.delegate?.savePostProgressBar(postProgress)
            })
        }
//        self.setLogColor() //"logColor"クラスへのセット

        self.setLogColorArray() //"TeatLogColorDic"クラスへのセット
        self.setWeekLogColorArray() //"TestWeekColorDic"クラスへのセット

        //        非同期通信の保存処理

        postObject.saveInBackgroundWithBlock({(error) in
            if error != nil {print("Save error : ",error)}
        })

        postTextView.resignFirstResponder() // 先にキーボードを下ろす
        postDateTextField.resignFirstResponder()
        if let tab = self.presentingViewController as? UITabBarController {
            tab.selectedIndex = 0 // Logに遷移する.
        }
        //現在タブバーから投稿に飛んだ場合はdelegateが空で機能しません（HELP）
        self.dismissViewControllerAnimated(true, completion: {self.delegate?.submitFinish()})
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
        if facebookToggle == true {
            if self.postImage1 != nil {
                shareFacebookMedia()
            }else {
                shareFacebookPost()
            }
            print("facebbokシェア完了")
        }else {
            print("facebookシェアなし")
        }
        
        //Secretモードかの判断
        if secretKeyToggle == false {
            print("Secret投稿なし, 普通に公開")
        } else {
            print("Secret投稿")
        }
    }
}

//Secretモード
extension SubmitViewController {
    //secret切り替え
    @IBAction func selectSecretKeyButton(sender: AnyObject) {
        selectSecret()
    }
    
    func selectSecret(){
        secretKeyToggle = !secretKeyToggle
        if secretKeyToggle == true {
            secretKeyButton.setImage(UIImage(named: "secretON"), forState: .Normal)
            print("Secret投稿")
        } else if secretKeyToggle == false {
            secretKeyButton.setImage(UIImage(named: "secretOFF"), forState: .Normal)
            print("Secret投稿無し")
        }
    }
}


//Twitterシェア
extension SubmitViewController {
    @IBAction func selectShareTwitter(sender: AnyObject) {
        print("twitterボタン押した")
        print("初期状態だぞおおおおお", twitterToggle)
        print(NCMBTwitterUtils.isLinkedWithUser(user))
        
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
    
    func shareTwitterPost(mediaID: String? = nil){//mediaIDの初期値をnilに（複数にすると多分Arrayになる）
        if let userID = Twitter.sharedInstance().sessionStore.session()?.userID{
            let client = TWTRAPIClient(userID: userID)
            print("userID", userID)
            
            let statusesShowEndpoint = "https://api.twitter.com/1.1/statuses/update.json"
            let tweetText = self.postTextView.text
            print("tweetText", tweetText)
            let encodedTweetText = tweetText.stringByReplacingOccurrencesOfString("n", withString: "nr")
//            let encodedTweetText = tweetText.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())
            print("encodedTweetText", encodedTweetText)
            
            var params = ["status": encodedTweetText]
            print("params", params)

            
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
    
    //twitterメディア添付シェア(写真があった場合imageをjsonの型に変換して、shareTwitterPostを呼び出す)
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

extension SubmitViewController {
    //Facebookシェア
    @IBAction func selectShareFacebook(sender: AnyObject) {
        print("Facebookボタン押した")
        if NCMBFacebookUtils.isLinkedWithUser(user) == true {
            //Facebook連携済み
            facebookToggle = !facebookToggle
            if facebookToggle == true{
                print("Facebookリンクしているか？", NCMBFacebookUtils.isLinkedWithUser(user))
                
                facebookButton.setImage(imgFacebookOn, forState: .Normal)
                print(facebookToggle)
            }else {
                
                facebookButton.setImage(imgFacebookOff, forState: .Normal)
                print(facebookToggle)
                print("Facebookリンクしているか？", NCMBFacebookUtils.isLinkedWithUser(user))
            }
            
        }else {
            //Facebook未連携
            let containerSnsVC = ContainerSnsViewController()
            containerSnsVC.addSnsToFacebook(user)
        }
    }

    func shareFacebookPost() {
        let post = self.postTextView.text
        print("投稿する文章", post)
        let params = ["message": post]
        let graphRequest = FBSDKGraphRequest(graphPath: "me/feed", parameters: params, HTTPMethod: "post")
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            guard let response = result else {
                print("No response received")
                if let error = error {
                    print("errorInfo:", error.localizedDescription)
                }
                return }


            print(response)
        })
    }

    func shareFacebookMedia(){
        let post = self.postTextView.text
        let image1 = self.postImage1!
        print("投稿する文章", post)
        let params = ["message": post, "sourceImage": UIImagePNGRepresentation(image1)!]
        let graphRequest = FBSDKGraphRequest(graphPath: "me/photos", parameters: params, HTTPMethod: "post")
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            guard let response = result else {
                print("No response received")
                if let error = error {
                    print("errorInfo:", error.localizedDescription)
                }
                return }
            print(response)
        })
    }
}

//logColorArray(月version)
extension SubmitViewController {
    func setLogColorArray() {
        let longLogDate = postDateLabel.text //投稿画面に表示されている投稿する日時（PostDateのString版）
        let logYearAndMonth = longLogDate!.substringToIndex((longLogDate?.startIndex.advancedBy(7))!) // "yyyy/MM/dd HH:mm" → "yyyy/MM"
        let logDate = longLogDate!.substringToIndex((longLogDate?.startIndex.advancedBy(10))!) // "yyyy/MM/dd HH:mm" → "yyyy/MM/dd"
        let logDateTag = Int(logDate.stringByReplacingOccurrencesOfString("/", withString: ""))! // "yyyy/MM/dd" → "yyyyMMdd"
        let logColorArrayQuery: NCMBQuery = NCMBQuery(className: "TestColorDic")
        logColorArrayQuery.whereKey("user", equalTo: user)
        logColorArrayQuery.whereKey("logYearAndMonth", equalTo: logYearAndMonth)
        logColorArrayQuery.getFirstObjectInBackgroundWithBlock { (object, error) in
            if let error = error {
                print(error.localizedDescription)
            }else {
                if object == nil {
                    //その月の投稿がまだなにもない時
                    self.firstSetLogColorArray(logYearAndMonth, logDateTag: logDateTag)
                }else {
                    print("object", object)
                    let dayColorArrayObject = object.objectForKey("logDateTag") as! [String]
                    let oldLogDateTagInfoArray = dayColorArrayObject.filter { $0.containsString(String(logDateTag))}
                    print("oldLogDateTagInfoArray", oldLogDateTagInfoArray)

                    self.removePostedMonthLogColorCache()

                    if oldLogDateTagInfoArray == [] {
                        //その日の投稿はまだ無い
                        print("今月の投稿はあるけどその日の投稿はまだないから追加")
                        self.otherSetLogColorArray(object, logDateTag: logDateTag)
                    }else {
                        //その日はもう投稿している
                        print("その日既に投稿してある要素を置換")
                        let oldLogDateTagInfo = oldLogDateTagInfoArray[0]
                        print("oldLogDateTagInfo", oldLogDateTagInfo)
                        self.updateLogColorArray(object, logDateTag: logDateTag, oldLogDateTagInfo: oldLogDateTagInfo)
                    }

                }
            }
        }
    }

    //その月初めてのlogColorArray作成
    func firstSetLogColorArray(logYearAndMonth: String, logDateTag: Int) {
        let logDateTagInfo = String(logDateTag) + "&" + self.dateColor
        let logColorDicObject: NCMBObject = NCMBObject(className: "TestColorDic")
        logColorDicObject.setObject(user, forKey: "user")
        logColorDicObject.setObject(logYearAndMonth, forKey: "logYearAndMonth")
        logColorDicObject.addObject(logDateTagInfo, forKey: "logDateTag")
        logColorDicObject.saveInBackgroundWithBlock { (error) in
            if let error = error {
                print(error.localizedDescription)
            }else {
                print("firstSetLogColorDic成功")
                if self.weekToggle == false {
                    self.prepareFinishSubmit()
                }
            }
        }
    }

    //その月二回目の投稿&&その日の投稿は初めて
    func otherSetLogColorArray(object: NCMBObject, logDateTag: Int) {
        let logDateTagInfo = String(logDateTag) + "&" + self.dateColor
        object.addObject(logDateTagInfo, forKey: "logDateTag")
        object.saveInBackgroundWithBlock { (error) -> Void in
            if let error = error {
                print(error.localizedDescription)
            }else {
                print("otherSetLogColorArray成功")
                if self.weekToggle == false {
                    self.prepareFinishSubmit()
                }
            }
        }
    }

    //その月二回目の投稿&&その日の投稿も二回目以降
    func updateLogColorArray(object: NCMBObject, logDateTag: Int, oldLogDateTagInfo: String) {
        let logDateTagInfo = String(logDateTag) + "&" + self.dateColor
        object.removeObject(oldLogDateTagInfo, forKey: "logDateTag")
        object.saveInBackgroundWithBlock { (error) -> Void in
            if let error = error {
                print(error.localizedDescription)
            }else {
                print("updateLogColorArray削除成功")
                object.addUniqueObject(logDateTagInfo, forKey: "logDateTag")
                object.saveInBackgroundWithBlock({ (error) in
                    if let error = error {
                        print(error.localizedDescription)
                    }else {
                        print("updateLogColorArray追加成功")
                        if self.weekToggle == false {
                            self.prepareFinishSubmit()
                        }
                    }
                })
            }
        }
    }

    //monthlogColorCaheの、投稿があった月の部分を消す(投稿なので自分のみ)
    //このあと、サーバーに保存されたものをもう一度取りに行き、cacheは更新される
    func removePostedMonthLogColorCache () {
        let monthKey = CalendarManager.getDateYearAndMonth(postDate!)
        let key = String(0) + NCMBUser.currentUser().userName + monthKey
        print("monthのkey", key)
        CalendarLogColorCache.sharedSingleton.myMonthLogColorCache.removeObjectForKey(key)
    }
}


//logColorArray(週version)
extension SubmitViewController {
    func setWeekLogColorArray() {
        let yearAndWeekNumberArray = CalendarManager.getWeekNumber(postDate!)
        let year = yearAndWeekNumberArray[0]
        let weekOfYear = yearAndWeekNumberArray[1]
        let longLogDate = postDateLabel.text //投稿画面に表示されている投稿する日時（PostDateのString版）
        let logDate = longLogDate!.substringToIndex((longLogDate?.startIndex.advancedBy(10))!) // "yyyy/MM/dd HH:mm" → "yyyy/MM/dd"
        let logDateTag = Int(logDate.stringByReplacingOccurrencesOfString("/", withString: ""))! // "yyyy/MM/dd" → "yyyyMMdd"
        let logColorArrayQuery: NCMBQuery = NCMBQuery(className: "TestWeekColorDic")
        logColorArrayQuery.whereKey("user", equalTo: user)
        logColorArrayQuery.whereKey("year", equalTo: year)
        logColorArrayQuery.whereKey("weekOfYear", equalTo: weekOfYear)
        logColorArrayQuery.getFirstObjectInBackgroundWithBlock { (object, error) in
            if let error = error {
                print(error.localizedDescription)
            }else {
                if object == nil {
                    //その月の投稿がまだなにもない時
                    self.firstSetWeekLogColorArray(year, weekOfYear: weekOfYear, logDateTag: logDateTag)
                }else {
                    print("object", object)
                    let dayColorArrayObject = object.objectForKey("logDateTag") as! Array<String>
                    let oldLogDateTagInfoArray = dayColorArrayObject.filter { $0.containsString(String(logDateTag))}
                    print("oldLogDateTagInfoArray", oldLogDateTagInfoArray)

                    self.removePostedWeekLogColorCache()

                    if oldLogDateTagInfoArray == [] {
                        //その日の投稿はまだ無い
                        print("今月の投稿はあるけどその日の投稿はまだないから追加")
                        self.otherSetWeekLogColorArray(object, logDateTag: logDateTag)
                    }else {
                        //その日はもう投稿している
                        print("その日既に投稿してある要素を置換")
                        let oldLogDateTagInfo = oldLogDateTagInfoArray[0]
                        print("oldLogDateTagInfo", oldLogDateTagInfo)
                        self.updateWeekLogColorArray(object, logDateTag: logDateTag, oldLogDateTagInfo: oldLogDateTagInfo)
                    }
                }
            }
        }
    }

    //その週初めてのlogColorArray作成
    func firstSetWeekLogColorArray(year: Int, weekOfYear: Int, logDateTag: Int) {
        let logDateTagInfo = String(logDateTag) + "&" + self.dateColor
        let logColorDicObject: NCMBObject = NCMBObject(className: "TestWeekColorDic")
        logColorDicObject.setObject(user, forKey: "user")
        logColorDicObject.setObject(year, forKey: "year")
        logColorDicObject.setObject(weekOfYear, forKey: "weekOfYear")
        logColorDicObject.addObject(logDateTagInfo, forKey: "logDateTag")
        logColorDicObject.saveInBackgroundWithBlock { (error) in
            if let error = error {
                print(error.localizedDescription)
            }else {
                print("firstSetLogColorDic成功")
                if self.weekToggle == true {
                    self.prepareFinishSubmit()
                }
            }
        }
    }

    //その週二回目の投稿&&その日の投稿は初めて
    func otherSetWeekLogColorArray(object: NCMBObject, logDateTag: Int) {
        let logDateTagInfo = String(logDateTag) + "&" + self.dateColor
        object.addObject(logDateTagInfo, forKey: "logDateTag")
        object.saveInBackgroundWithBlock { (error) -> Void in
            if let error = error {
                print(error.localizedDescription)
            }else {
                print("otherSetLogColorArray成功")
                if self.weekToggle == true {
                    self.prepareFinishSubmit()
                }
            }
        }
    }

    //その週二回目の投稿&&その日の投稿も二回目以降
    func updateWeekLogColorArray(object: NCMBObject, logDateTag: Int, oldLogDateTagInfo: String) {
        let logDateTagInfo = String(logDateTag) + "&" + self.dateColor
        object.removeObject(oldLogDateTagInfo, forKey: "logDateTag")
        object.saveInBackgroundWithBlock { (error) -> Void in
            if let error = error {
                print(error.localizedDescription)
            }else {
                print("updateLogColorArray削除成功")
                object.addUniqueObject(logDateTagInfo, forKey: "logDateTag")
                object.saveInBackgroundWithBlock({ (error) in
                    if let error = error {
                        print(error.localizedDescription)
                    }else {
                        print("updateLogColorArray追加成功")
                        if self.weekToggle == true {
                            self.prepareFinishSubmit()
                        }
                    }
                })
            }
        }
    }

    //monthlogColorCaheの、投稿があった週の部分を消す(投稿なので自分のみ)
    //このあと、サーバーに保存されたものをもう一度取りに行き、cacheは更新される
    func removePostedWeekLogColorCache () {
        let weekKeyArray = CalendarManager.getWeekNumber(postDate!)
        let weekKey = String(weekKeyArray[0]) + String(weekKeyArray[1])
        let key = String(0) + NCMBUser.currentUser().userName + weekKey
        print("weekのkey", key)
        CalendarLogColorCache.sharedSingleton.myMonthLogColorCache.removeObjectForKey(key)
    }
}



//// LogColor
//extension SubmitViewController {
//    func setLogColor(){
//        let longLogDate = postDateLabel.text //投稿画面に表示されている投稿する日時（PostDateのString版）
//        let logDate = longLogDate!.substringToIndex((longLogDate?.startIndex.advancedBy(10))!) // "yyyy/MM/dd HH:mm" → "yyyy/MM/dd"
//        print("logDate", logDate)
//        let logYearAndMonth = longLogDate!.substringToIndex((longLogDate?.startIndex.advancedBy(7))!) // "yyyy/MM/dd HH:mm" → "yyyy/MM"
//        let myLogColorQuery: NCMBQuery = NCMBQuery(className: "LogColor") // 自分の投稿クエリ
//        myLogColorQuery.whereKey("user", equalTo: user)
//        myLogColorQuery.whereKey("logDate", equalTo: logDate)
//        myLogColorQuery.getFirstObjectInBackgroundWithBlock { (object, error) -> Void in
//            if let error = error {
//                print(error.localizedDescription)
//            }else {
//                if object == nil {
//                    //今日の投稿はまだない
//                    self.firstSetLogColor(logDate, logYearAndMonth: logYearAndMonth)
//                }else {
//                    //２度目以降の投稿
//                    print("変更した後の色は？", self.dateColor)
//                    self.updateLogColor(object)
//                }
//            }
//        }
//    }
//    
//    //今日初めての投稿
//    func firstSetLogColor(logDate: String, logYearAndMonth: String){
//        print("本日の色は？", self.dateColor)
//        let logColorObject = NCMBObject(className: "LogColor")
//        logColorObject.setObject(user, forKey: "user")
//        logColorObject.setObject(logDate, forKey: "logDate")
//        logColorObject.setObject(logYearAndMonth, forKey: "logYearAndMonth")
//        logColorObject.incrementKey("postCount")
//        if secretKeyToggle == false {
//            logColorObject.setObject(self.dateColor, forKey: "dateColor")
//        }
//        logColorObject.setObject(self.dateColor, forKey: "secretColor")
//        logColorObject.saveInBackgroundWithBlock { (error) -> Void in
//            if error != nil {
//                print("error", error)
//            }else {
//                print("logColor 今日初めての投稿 save成功")
//            }
//        }
//    }
//    
////    //今日２回目以降の投稿
//    func updateLogColor(object: AnyObject){
//        let secondObject = object as! NCMBObject
//        secondObject.incrementKey("postCount")
//        if self.dateColor != "normal"{ //色を選択している時だけ色を更新する
//            if secretKeyToggle == false {
//                secondObject.setObject(self.dateColor, forKey: "dateColor")
//            }
//            secondObject.setObject(self.dateColor, forKey: "secretColor")
//        }else {// 色を選択してない時
//            if secretKeyToggle == false {//色を選択してなくてカギ付きじゃない
//                if secondObject.objectForKey("dateColor") == nil {//色を選択してなくてカギなしで、カギなし投稿だけのフィールドが空の時
//                    secondObject.setObject(self.dateColor, forKey: "dateColor")
//                }
//            }
//        }
//        secondObject.saveInBackgroundWithBlock { (error) -> Void in
//            object.saveInBackgroundWithBlock { (error) -> Void in
//                if error != nil {
//                    print("error", error)
//                }else {
//                    print("logColor ２回目以降の投稿 save成功")
//                }
//            }
//        }
//        
//    }
//}


// 完了ボタン
extension SubmitViewController {
    func prepareFinishSubmit() {
        print("prepareFinishSubmit呼び出し")
        let n = NSNotification(name: "submitFinish", object: self, userInfo: nil)
        NSNotificationCenter.defaultCenter().postNotification(n)
    }

    func selectToolBarDoneButton(sender: UIBarButtonItem) {
        print("完了ボタン押した")
        self.view.endEditing(true)
    }
}
