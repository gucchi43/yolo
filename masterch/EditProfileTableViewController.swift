//
//  EditProfileTableViewController.swift
//  masterch
//
//  Created by HIroki Taniguti on 2016/04/12.
//  Copyright © 2016年 Fumiya Yamanaka. All rights reserved.
//

import UIKit
import SVProgressHUD
import NCMB
import TwitterKit
import RSKImageCropper

class EditProfileTableViewController: UITableViewController {
    
    @IBOutlet weak var userProfileImageView: UIImageView!
    @IBOutlet weak var userHomeImageView: UIImageView!
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var userSelfIntroductionTextView: UITextView!
    @IBOutlet weak var statusConnectMailLabel: UILabel!
    @IBOutlet weak var changeProfileButton: UIButton!

    var changeImageButtonFrag: Int = 0 // 1 -> プロフィール, 2 -> ホーム

    var profileImageToggle = false
    var homeImageToggle = false
    
    var profileImage: UIImage!
    var profileHomeImage: UIImage!
    var ProfileName: String!
    var profileSelfIntroduction: String!

    var user: NCMBUser?

    private var onceTokenViewWillAppear: dispatch_once_t = 0

    
    override func viewDidLoad() {
        super.viewDidLoad()
        //プロフィール写真の形を整える
        userProfileImageView.layer.cornerRadius = userProfileImageView.frame.width/2
        changeProfileButton.layer.cornerRadius = changeProfileButton.frame.width/2
    }

    override func viewWillAppear(animated: Bool) {
         super.viewWillAppear(animated)
        dispatch_once(&onceTokenViewWillAppear) {
            print("ViewWillApperar読んでる")
            self.loadUser()
        }
        checkStatusMail()
    }

    override func viewDidAppear(animated: Bool) {
//        loadUser()

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func loadUser(){
        userProfileImageView.image = profileImage
        userHomeImageView.image = profileHomeImage
        userName.text = ProfileName
        userSelfIntroductionTextView.text = profileSelfIntroduction
    }


//    キャンセルボタンアクション
    @IBAction func selectCancelButton(sender: AnyObject) {
        print("キャンセルボタンを押した")
        dismissViewControllerAnimated(true, completion: nil)
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.row {
        case 0:
            print(indexPath.row)
        case 1:
            print(indexPath.row)
        case 2:
            print(indexPath.row)
        case 3:
            print(indexPath.row)
            performSegueWithIdentifier("toConnectMailTVC", sender: nil)
        case 4:
            print(indexPath.row)
        default:
            break

        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier {
        case "toMainVC"?:
            print("ログアウト遷移開始")
        case "toConnectMailTVC"?:
            print("メールアドレス連携設定")
        default:
            break
        }
//        if segue.identifier == "toMainVC"{
//            print("ログアウト遷移開始")
//        }
    }
}

// カメラ周り
extension EditProfileTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate,  RSKImageCropViewControllerDelegate, RSKImageCropViewControllerDataSource  {
    //プロフィール写真変更ボタンアクション
    @IBAction func changeProfileImage(sender: AnyObject) {
        print(sender.tag)
        changeImageButtonFrag = sender.tag // 1
        selectChangeImageButton()
    }
    
    //ホーム写真変更ボタンアクション
    @IBAction func changeHomeImage(sender: AnyObject) {
        print(sender.tag)
        changeImageButtonFrag = sender.tag // 2
        selectChangeImageButton()
    }
    
    func selectChangeImageButton() {
        print("カメラボタン押した")
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

//        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
//            //             アルバムから写真を取得
//            self.pickImageFromLibrary()
//            //        } else if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
//            //            self.pickImageFromCamera()
//        } else {
//            UIAlertView(title: "警告", message: "Photoライブラリにアクセス出来ません", delegate: nil, cancelButtonTitle: "OK").show()
//        }
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
            UIImageWriteToSavedPhotosAlbum(image, self, nil, nil)
            if changeImageButtonFrag == 1 {
                let imageCropVC = RSKImageCropViewController.init(image: image, cropMode: .Circle)
                imageCropVC.delegate = self
                imageCropVC.dataSource = nil
                self.navigationController?.pushViewController(imageCropVC, animated: true)

            } else if changeImageButtonFrag == 2 {
                let imageCropVC = RSKImageCropViewController.init(image: image, cropMode: .Custom)
                imageCropVC.delegate = self
                imageCropVC.dataSource = self
                self.navigationController?.pushViewController(imageCropVC, animated: true)
            }
        }
        picker.dismissViewControllerAnimated(true, completion: nil)
    }

    // 画像リサイズメソッド
//    func resize(image: UIImage, width: Int, height: Int) -> UIImage {
//        let size: CGSize = CGSize(width: width, height: height)
//        UIGraphicsBeginImageContext(size)
//        image.drawInRect(CGRectMake(0, 0, size.width, size.height))
//        
//        let resizeImage = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//        return resizeImage
//    }

    //    画像選択がキャンセルされた時に呼ばれる.
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        // モーダルビューを閉じる
        self.dismissViewControllerAnimated(true, completion: nil)
        print("カメラキャンセル")
    }

    func imageCropViewControllerCustomMaskRect(controller: RSKImageCropViewController) -> CGRect {
        print("imageCropViewControllerCustomMaskRect")
        var maskSize: CGSize
        var width: CGFloat!
        var height: CGFloat!
        width = self.view.frame.width
        height = 250.0
        maskSize = CGSizeMake(self.view.frame.width, height)
        let viewWidth: CGFloat = CGRectGetWidth(controller.view.frame)
        let viewHeight: CGFloat = CGRectGetHeight(controller.view.frame)

        let maskRect: CGRect = CGRectMake((viewWidth - maskSize.width) * 0.5, (viewHeight - maskSize.height) * 0.5, maskSize.width, maskSize.height)
        return maskRect
    }

    // トリミングしたい領域を描画（今回は四角な領域です・・・）
    func imageCropViewControllerCustomMaskPath(controller: RSKImageCropViewController) -> UIBezierPath {
        print("imageCropViewControllerCustomMaskPath")
        let rect: CGRect = controller.maskRect

        let point1: CGPoint = CGPointMake(CGRectGetMinX(rect), CGRectGetMaxY(rect))
        let point2: CGPoint = CGPointMake(CGRectGetMaxX(rect), CGRectGetMaxY(rect))
        let point3: CGPoint = CGPointMake(CGRectGetMaxX(rect), CGRectGetMinY(rect))
        let point4: CGPoint = CGPointMake(CGRectGetMinX(rect), CGRectGetMinY(rect))

        let square: UIBezierPath = UIBezierPath()
        square.moveToPoint(point1)
        square.addLineToPoint(point2)
        square.addLineToPoint(point3)
        square.addLineToPoint(point4)
        square.closePath()

        return square
    }

    func imageCropViewControllerCustomMovementRect(controller: RSKImageCropViewController) -> CGRect {
        print("imageCropViewControllerCustomMovementRect")
        return controller.maskRect
    }

    func imageCropViewController(controller: RSKImageCropViewController, willCropImage originalImage: UIImage) {
        print("imageCropViewController")
    }

    //写真編集画面で「キャンセル」タップした時
    func imageCropViewControllerDidCancelCrop(controller: RSKImageCropViewController) {
        print("imageCropViewControllerDidCancelCrop")
        self.navigationController?.popViewControllerAnimated(true)
    }


    //写真編集画面で「選択」タップした時
    func imageCropViewController(controller: RSKImageCropViewController, didCropImage croppedImage: UIImage, usingCropRect cropRect: CGRect) {
        print("imageCropViewController")
        if changeImageButtonFrag == 1{
            self.userProfileImageView.image = croppedImage
        }else if changeImageButtonFrag == 2{
            self.userHomeImageView.image = croppedImage
        }
        self.navigationController?.popViewControllerAnimated(true)
    }
}


// 保存アクション周り
extension EditProfileTableViewController {
    //保存ボタンアクション
    @IBAction func selectSaveButton(sender: AnyObject) {
        saveNewProfile()
    }
    
//    保存機能メソッド
    func saveNewProfile() {
        let user = NCMBUser.currentUser()
        
        // ユーザーネーム保存
        user.setObject(userName.text, forKey: "userFaceName")
        // 自己紹介保存
        user.setObject(userSelfIntroductionTextView.text, forKey: "userSelfIntroduction")
        
        // 変更があればプロフィール写真を保存
        if userProfileImageView.image != profileImage {

            let userProfileImageData = UIImageJPEGRepresentation(self.userProfileImageView.image!, 0.8)! as NSData
//            let userProfileImageData = UIImagePNGRepresentation(self.userProfileImageView.image!)! as NSData
            let userProfileImageFile: NCMBFile = NCMBFile.fileWithData(userProfileImageData) as! NCMBFile
            
            user.setObject(userProfileImageFile.name, forKey: "userProfileImage")
            //
            //            ファイルはバックグラウンド実行をする
            SVProgressHUD.show()
            userProfileImageFile.saveInBackgroundWithBlock({ (error: NSError!) -> Void in
                if error == nil {
                    SVProgressHUD.dismiss()
                    print("プロフィール画像保存完了")
                    self.profileImageToggle = true
                    self.dismissViewController()
                } else {
                    SVProgressHUD.showErrorWithStatus("アップロード中にエラーが発生しました")
                    print("アップロード中にエラーが発生しました: \(error)")
                    self.profileImageToggle = true
                    self.dismissViewController()
                }
                }, progressBlock: { (percentDone: Int32) -> Void in
                    //                    進捗状況を取得します。保存完了まで何度も呼ばれます
                    print("進捗状況: \(percentDone)% アップロード済み")
            })
        }else {
            profileImageToggle = true
        }
//        変更があればホーム画像を保存
        if userHomeImageView.image != profileHomeImage {
            let userHomeImageData = UIImageJPEGRepresentation(self.userHomeImageView.image!, 0.8)! as NSData
//            let userHomeImageData = UIImagePNGRepresentation(self.userHomeImageView.image!)! as NSData
            let userHomeImageFile: NCMBFile = NCMBFile.fileWithData(userHomeImageData) as! NCMBFile
            
            user.setObject(userHomeImageFile.name, forKey: "userHomeImage")
            
            //            ファイルはバックグラウンド実行をする
            SVProgressHUD.show()
            userHomeImageFile.saveInBackgroundWithBlock({ (error: NSError!) -> Void in
                if error == nil {
                    SVProgressHUD.dismiss()
                    print("ホーム画像保存完了")
                    self.homeImageToggle = true
                    self.dismissViewController()

                } else {
                    SVProgressHUD.showErrorWithStatus("アップロード中にエラーが発生しました")
                    print("アップロード中にエラーが発生しました: \(error)")
                    self.homeImageToggle = true
                    self.dismissViewController()
                }
                }, progressBlock: { (percentDone: Int32) -> Void in
                    //                    進捗状況を取得します。保存完了まで何度も呼ばれます
                    print("進捗状況: \(percentDone)% アップロード済み")
            })
        }else {
            homeImageToggle = true
            dismissViewController()
        }

        user.saveEventually { (error) in
            if let error = error {
                print(error.localizedDescription)
            }
        }

//        user.saveInBackgroundWithBlock({(error) in
//            if error != nil {print("Save error : ",error)}
//        })
//        dismissViewController()

//        self.dismissViewControllerAnimated(true, completion: nil)
//        print("保存完了")
    }

    //非同期処理が終わった後に遷移（それまでプログレスビュー）
    //二つのboolがすべてtrueになったら通れる
    func dismissViewController() {
        print("homeImageToggle", homeImageToggle)
        print("profileImage", profileImageToggle)
        if homeImageToggle == true && profileImageToggle == true {
            print("AccountVCに戻ります")
            dismissViewControllerAnimated(true, completion: nil)

        }
    }
}

//メールアドレス連携
extension EditProfileTableViewController{
    func checkStatusMail() {
        if let mailAddress = NCMBUser.currentUser().objectForKey("mailAddress") as? String{
            print(mailAddress)
            statusConnectMailLabel.text = "連携済み"
            statusConnectMailLabel.textColor = ColorManager.sharedSingleton.mainColor()
        }else {
            statusConnectMailLabel.text = "未連携"
            statusConnectMailLabel.textColor = UIColor.redColor()
        }
    }
}


//ログアウト
extension EditProfileTableViewController{

    @IBAction func tapLogoutButton(sender: AnyObject) {
        if let user = NCMBUser.currentUser(){
            print("ログアウト前、NCMBUser.currentUser(): ", user)
        } else {
            print("ログアウト前、currentUser無し")
        }
//        NCMBUser.logOut()

        //GCD入れるメソッドで挟み、本当はプログレスビュー入れるためにこう書いたのだが、プログレスは出ずに処理速度が上がったのでひとまずコレで。通信状況悪いと、プログレスビュー出るかも。
        SVProgressHUD.show()
        let gcdManager = GCDManager()
        gcdManager.dispatch_async_global { 
            NCMBUser.logOut()
            gcdManager.dispatch_async_main({ 
                SVProgressHUD.dismiss()
            })
        }

        if let user = NCMBUser.currentUser(){
            print("ログアウト後、NCMBUser.currentUser(): ", user)
        } else {
            print("ログアウト後、currentUser無し")
        }
    }
}


//extension EditProfileTableViewController{
//
//    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        switch indexPath.row {
//        case 0:
//            //画像変更
//            let cell = tableView.dequeueReusableCellWithIdentifier("editUserImageCell", forIndexPath: indexPath)
//
//            userProfileImageView.layer.cornerRadius = userProfileImageView.frame.width/2
//            changeProfileButton.layer.cornerRadius = changeProfileButton.frame.width/2
//            return cell
//        case 1:
//            //ユーザーネーム変更
//            let cell = tableView.dequeueReusableCellWithIdentifier("editUserNameCell", forIndexPath: indexPath)
//            return cell
//        case 2:
//            //自己紹介変更
//            let cell = tableView.dequeueReusableCellWithIdentifier("editUserSelfIntroductionCell", forIndexPath: indexPath)
//            return cell
//        case 3:
//            //Twitter連携
//            print("Twitter連携確認cell")
//            let cell = tableView.dequeueReusableCellWithIdentifier("connectTwitterCell", forIndexPath: indexPath)
//            return cell
//
//            let user = NCMBUser.currentUser()
//
//            // Tag番号 ２ （連携SNS名）
////            let label1 = tableView.viewWithTag(2) as! UILabel
////            label1.text = "\(label1Array[indexPath.row])"
//
//            // Tag番号 ４ （連携SNSのロゴImage）
//
//            //　Tag番号 ３、４、５ （SNSでのユーザー名、SNSのロゴ、連携済 or 未連携）
//
//            let connectAccontName = tableView.viewWithTag(3) as! UILabel
//            let logoImage = tableView.viewWithTag(4) as! UIImageView
//            let imgTwitterOn = UIImage(named: "twitter_logo_640*480_origin")
//            let imgTwitterOff = UIImage(named: "twitter_logo_640*480_gray")
//            let labelOnOff = tableView.viewWithTag(5) as! UILabel
//
//            print("user情報", user)
//            print("true or false", NCMBTwitterUtils.isLinkedWithUser(user))
//
//
//            if let userID = user.objectForKey("twitterID") {
//                if userID.isKindOfClass(NSNull) != true{
//                    if let userLink = Twitter.sharedInstance().sessionStore.sessionForUserID(userID as! String){
//                        print("Twitter連携済 userID:", userLink.userID)//Twitter連携している
//                        let snsName = user.objectForKey("twitterName")
//                        print("snsName:", snsName)
//                        connectAccontName.text = String(snsName)
//                        labelOnOff.text = "連携中"
//                        logoImage.image = imgTwitterOn
//                    }else{
//                        print("ありえないはず: twitterIDは登録してるのにTwitterSessionがsaveできていない")
//                        connectAccontName.text = ""
//                        labelOnOff.text = "未連携"
//                        logoImage.image = imgTwitterOff
//
//                    }
//                }else {
//                    print("Twitter未連携（外した状態） userID", userID)//Twitter連携をはずして、空っぽの状態
//                    //Twitter未連携
//                    connectAccontName.text = ""
//                    labelOnOff.text = "未連携"
//                    logoImage.image = imgTwitterOff
//                }
//            }else {
//                print("Twitter未連携")//Twitter連携は今まで一度もしていない
//                //Twitter未連携
//                connectAccontName.text = ""
//                labelOnOff.text = "未連携"
//                logoImage.image = imgTwitterOff
//            }
//            return cell
//
//        case 4:
//            //Facebook連携
//            print("Facebok連携確認cell")
//            let cell = tableView.dequeueReusableCellWithIdentifier("connectFacebookCell", forIndexPath: indexPath)
//            return cell
//        default:
//            //ログアウト
//            let cell = tableView.dequeueReusableCellWithIdentifier("logOutCell", forIndexPath: indexPath)
//            return cell
//
//        }
//    }
//
//
//    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        print("セルの選択: \(indexPath.row)")
//        switch indexPath.row {
//        case 5:
//            SVProgressHUD.show()
//            print("ユーザー情報", user)
//            NCMBUser.logOut()
//            print("ユーザー情報", user)
//            SVProgressHUD.dismiss()
//        default:
//            print("これでも落ちるんすか？", indexPath.row)
//        }
//
//    }
//}

