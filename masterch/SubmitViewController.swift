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


protocol addSubmitlDelegate {
    func submitFinish()
}

class SubmitViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet var postTextView: UITextView!
    @IBOutlet var postDateTextField: UITextField!
    
    @IBOutlet weak var postDateLabel: UILabel!
    @IBOutlet weak var submitButton: UIBarButtonItem!
    @IBOutlet weak var twitterButton: UIButton!
    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var secretKeyButton: UIButton!
    
    @IBOutlet weak var twitterBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var facebookBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var secretKeyBottomConstraint: NSLayoutConstraint!
    
    let imgTwitterOn = UIImage(named: "twitter_logo_640*480_origin")
    let imgTwitterOff = UIImage(named: "twitter_logo_640*480_gray")
    let imgFacebookOn = UIImage(named: "facebook_logo_640*480_origin")
    let imgFacebookOff = UIImage(named: "facebook_logo_640*480_gray")
    
    @IBOutlet weak var redButton: UIButton!
    @IBOutlet weak var yellowButton: UIButton!
    @IBOutlet weak var pinkButton: UIButton!
    @IBOutlet weak var blueButton: UIButton!
    @IBOutlet weak var greenButton: UIButton!
    @IBOutlet weak var grayButton: UIButton!
    
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
    var dateColor: String = "normal"
    
    var delegate: addSubmitlDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        print("SubmitViewController")
    }
        
//     Viewが画面に表示される度に呼ばれるメソッド
    override func viewWillAppear(animated: Bool) {
        self.setToolBar()
        
        self.postTextView.delegate = self

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
        let toolBarColorButton = UIBarButtonItem(title: "カラー", style: .Plain, target: self, action: #selector(SubmitViewController.selectToolBarColorButton(_:)))
        let toolBarDoneButton = UIBarButtonItem(title: "完了", style: .Done, target: self, action: #selector(SubmitViewController.selectToolBarDoneButton(_:)))

        postTextCharactersLabel.frame = CGRectMake(0, 0, 30, 35)
        postTextCharactersLabel.text = "140"
        postTextCharactersLabel.textColor = UIColor.lightGrayColor()
        let toolBarPostTextcharacterLabelItem = UIBarButtonItem(customView: postTextCharactersLabel)
        // Flexible Space Bar Button Item
        let flexibleItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        
        toolBar.items = [toolBarCameraButton, toolBarPencilButton, toolBarColorButton, flexibleItem, toolBarPostTextcharacterLabelItem, toolBarDoneButton]
    }
}

// カメラ周り
extension SubmitViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate  {

    func selectToolBarCameraButton(sender: UIBarButtonItem) {
        print("カメラ&カメラロール呼び出しボタン押した")

        //カメラかカメラロールの分岐
        RMUniversalAlert.showActionSheetInViewController(self,
            withTitle: nil,
            message: nil,
            cancelButtonTitle: "Cancel",
            destructiveButtonTitle: nil,
            otherButtonTitles: ["カメラ", "カメラロール"],
            popoverPresentationControllerBlock: {(popover) in
                popover.sourceView = self.view
                popover.sourceRect = CGRect()
            },
            tapBlock: {(alert, buttonIndex) in
                if (buttonIndex == alert.cancelButtonIndex) {
                    print("Cancel Tapped")
                } else if (buttonIndex == alert.destructiveButtonIndex) {
                    print("Delete Tapped")
                } else if (buttonIndex == alert.firstOtherButtonIndex) {
                    print("カメラ選択 \(alert.firstOtherButtonIndex)")
                    self.pickImageFromCamera()
                } else {
                    print("カメラロール選択\(alert.firstOtherButtonIndex)")
                    self.pickImageFromLibrary()
                }
        })
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
    }
}

// DateColor設定
extension SubmitViewController {
    func selectToolBarColorButton(sender:UIBarButtonItem) {
        print("カラーボタンを押した")
        let colorKeyboardview:UIView = UINib(nibName: "ColorKeyboard", bundle: nil).instantiateWithOwner(self, options: nil)[0] as! UIView
        self.postTextView.inputView = colorKeyboardview
        self.postTextView.reloadInputViews()
    }
    
    @IBAction func selectRed(sender: AnyObject) {
        print("selectRed")
        self.dateColor = "red"
        toolBar.backgroundColor = UIColor.redColor()
    }
    @IBAction func selectYellow(sender: AnyObject) {
        print("selectYellow")
        self.dateColor = "yellow"
        toolBar.backgroundColor = UIColor.yellowColor()
    }
    @IBAction func selectPink(sender: AnyObject) {
        print("selectPink")
        self.dateColor = "pink"
        toolBar.backgroundColor = UIColor.magentaColor()
    }
    @IBAction func selectBlue(sender: AnyObject) {
        print("selectBlue")
        self.dateColor = "blue"
        toolBar.backgroundColor = UIColor.blueColor()
    }
    @IBAction func selectGreen(sender: AnyObject) {
        print("selectGreen")
        self.dateColor = "green"
        toolBar.backgroundColor = UIColor.greenColor()
    }
    @IBAction func selectGray(sender: AnyObject) {
        print("selectGray")
        self.dateColor = "gray"
        toolBar.backgroundColor = UIColor.darkGrayColor()
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
            })
        }
        self.setLogColor() //"logColor"クラスへのセット
        
//        非同期通信の保存処理
        postObject.saveInBackgroundWithBlock({(error) in
            if error != nil {print("Save error : ",error)}
        })

        postTextView.resignFirstResponder() // 先にキーボードを下ろす
//        self.dismissViewControllerAnimated(true, completion: nil)
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
            secretKeyButton.setImage(UIImage(named: "key_origin"), forState: .Normal)
            print("Secret投稿")
        } else if secretKeyToggle == false {
            secretKeyButton.setImage(UIImage(named: "key_gray"), forState: .Normal)
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

// LogColor
extension SubmitViewController {
    func setLogColor(){
        let longLogDate = postDateLabel.text //投稿画面に表示されている投稿する日時（PostDateのString版）
        let logDate = longLogDate!.substringToIndex((longLogDate?.startIndex.advancedBy(10))!) // "yyyy/MM/dd HH:mm" → "yyyy/MM/dd"
        print("logDate", logDate)
        let logYearAndMonth = longLogDate!.substringToIndex((longLogDate?.startIndex.advancedBy(7))!) // "yyyy/MM/dd HH:mm" → "yyyy/MM"
        let myLogColorQuery: NCMBQuery = NCMBQuery(className: "LogColor") // 自分の投稿クエリ
        myLogColorQuery.whereKey("user", equalTo: user)
        myLogColorQuery.whereKey("logDate", equalTo: logDate)
        myLogColorQuery.getFirstObjectInBackgroundWithBlock { (object, error) -> Void in
            if let error = error {
                print(error.localizedDescription)
            }else {
                if object == nil {
                    //今日の投稿はまだない
                    self.firstSetLogColor(logDate, logYearAndMonth: logYearAndMonth)
                }else {
                    //２度目以降の投稿
                    print("変更した後の色は？", self.dateColor)
                    self.updateLogColor(object)
                }
            }
        }
    }
    
    //今日初めての投稿
    func firstSetLogColor(logDate: String, logYearAndMonth: String){
        print("本日の色は？", self.dateColor)
        let logColorObject = NCMBObject(className: "LogColor")
        logColorObject.setObject(user, forKey: "user")
        logColorObject.setObject(logDate, forKey: "logDate")
        logColorObject.setObject(logYearAndMonth, forKey: "logYearAndMonth")
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
    
//    //今日２回目以降の投稿
    func updateLogColor(object: AnyObject){
        let secondObject = object as! NCMBObject
        secondObject.incrementKey("postCount")
        secondObject.setObject(self.dateColor, forKey: "dateColor")
        
        secondObject.saveInBackgroundWithBlock { (error) -> Void in
            object.saveInBackgroundWithBlock { (error) -> Void in
                if error != nil {
                    print("error", error)
                }else {
                    print("logColor ２回目以降の投稿 save成功")
                }
            }
        }
        
    }
}


// 完了ボタン
extension SubmitViewController {
    func selectToolBarDoneButton(sender: UIBarButtonItem) {
        print("完了ボタン押した")
        self.view.endEditing(true)
    }
}
