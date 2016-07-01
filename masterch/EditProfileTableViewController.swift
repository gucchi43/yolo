//
//  EditProfileTableViewController.swift
//  masterch
//
//  Created by HIroki Taniguti on 2016/04/12.
//  Copyright © 2016年 Fumiya Yamanaka. All rights reserved.
//

import UIKit
import SVProgressHUD

class EditProfileTableViewController: UITableViewController {
    
    @IBOutlet weak var userProfileImageView: UIImageView!
    @IBOutlet weak var userHomeImageView: UIImageView!
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var userSelfIntroductionTextView: UITextView!
    
    @IBOutlet weak var changeProfileButton: UIButton!
    
    var userProfileName: String!
    var userSelfIntroduction: String!
    
    var changeImageButtonFrag: Int = 0 // 1 -> プロフィール, 2 -> ホーム
    var profileImage: UIImage!
    var homeImage: UIImage!

    var user: NCMBUser!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        //プロフィール写真の形を整える
        userProfileImageView.layer.cornerRadius = userProfileImageView.frame.width/2
        changeProfileButton.layer.cornerRadius = changeProfileButton.frame.width/2
        
    }

    override func viewDidAppear(animated: Bool) {
        loadUser()

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func loadUser(){
        userName.text = user.objectForKey("userFaceName") as? String
        userSelfIntroductionTextView.text = user.objectForKey("userSelfIntroduction") as? String
        //プロフィール写真
        let userProfileImageName = (user.objectForKey("userProfileImage") as? String)!
        let userProfileImageData = NCMBFile.fileWithName(userProfileImageName, data: nil) as! NCMBFile
        userProfileImageData.getDataInBackgroundWithBlock { (imageData: NSData?, error: NSError!) -> Void in
            if error != nil{
                print("写真の取得失敗なんでnoprofileを入れる", error.localizedDescription)
                self.userProfileImageView.image = UIImage(named: "noprofile")
            } else {
                self.userProfileImageView.image = UIImage(data: imageData!)
            }
        }
        //ホーム写真
        let userHomeImageName = (user.objectForKey("userHomeImage") as? String)!
        let userHomeImageData = NCMBFile.fileWithName(userHomeImageName, data: nil) as! NCMBFile
        userHomeImageData.getDataInBackgroundWithBlock { (imageData: NSData?, error: NSError!) -> Void in
            if error != nil{
                print("写真の取得失敗なんでnoprofileを入れる", error.localizedDescription)
                self.userHomeImageView.image = UIImage(named: "noprofile")
            } else {
                self.userHomeImageView.image = UIImage(data: imageData!)
            }
        }
    }


//    キャンセルボタンアクション
    @IBAction func selectCancelButton(sender: AnyObject) {
        print("キャンセルボタンを押した")
        dismissViewControllerAnimated(true, completion: nil)
    }
}

extension EditProfileTableViewController{
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("セルの選択: \(indexPath.row)")
        switch indexPath.row {
        case 5:
            SVProgressHUD.show()
            print("ユーザー情報", user)
            NCMBUser.logOut()
            print("ユーザー情報", user)
            SVProgressHUD.dismiss()
        default:
            break
        }
        
    }
}


// カメラ周り
extension EditProfileTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
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

            if changeImageButtonFrag == 1 {
//                画像をリサイズしてUIImageViewにセット
                let resizeImage = resize(image, width: 500, height: 500)
                image = resizeImage

                userProfileImageView.image = image
                
            } else if changeImageButtonFrag == 2 {
                let resizeImage = resize(image, width: 800, height: 400)
                image = resizeImage
                userHomeImageView.image = image
            }
        }
        picker.dismissViewControllerAnimated(true, completion: nil)
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
    
    //    画像選択がキャンセルされた時に呼ばれる.
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        // モーダルビューを閉じる
        self.dismissViewControllerAnimated(true, completion: nil)
        print("カメラキャンセル")
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
            
            let userProfileImageData = UIImagePNGRepresentation(self.userProfileImageView.image!)! as NSData
            let userProfileImageFile: NCMBFile = NCMBFile.fileWithData(userProfileImageData) as! NCMBFile
            
            user.setObject(userProfileImageFile.name, forKey: "userProfileImage")
            
            //            ファイルはバックグラウンド実行をする
            userProfileImageFile.saveInBackgroundWithBlock({ (error: NSError!) -> Void in
                if error == nil {
                    print("画像データ保存完了: \(userProfileImageFile.name)")
                } else {
                    print("アップロード中にエラーが発生しました: \(error)")
                }
                }, progressBlock: { (percentDone: Int32) -> Void in
                    //                    進捗状況を取得します。保存完了まで何度も呼ばれます
                    print("進捗状況: \(percentDone)% アップロード済み")
            })
        }
//        変更があればホーム画像を保存
        if userHomeImageView.image != homeImage {
            let userHomeImageData = UIImagePNGRepresentation(self.userHomeImageView.image!)! as NSData
            let userHomeImageFile: NCMBFile = NCMBFile.fileWithData(userHomeImageData) as! NCMBFile
            
            user.setObject(userHomeImageFile.name, forKey: "userHomeImage")
            
            //            ファイルはバックグラウンド実行をする
            userHomeImageFile.saveInBackgroundWithBlock({ (error: NSError!) -> Void in
                if error == nil {
                    print("画像データ保存完了: \(userHomeImageFile.name)")
                } else {
                    print("アップロード中にエラーが発生しました: \(error)")
                }
                }, progressBlock: { (percentDone: Int32) -> Void in
                    //                    進捗状況を取得します。保存完了まで何度も呼ばれます
                    print("進捗状況: \(percentDone)% アップロード済み")
            })
        }
        
        user.saveInBackgroundWithBlock({(error) in
            if error != nil {print("Save error : ",error)}
        })
        
        self.dismissViewControllerAnimated(true, completion: nil)
        print("保存完了")
    }
}