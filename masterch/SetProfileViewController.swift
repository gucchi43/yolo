//
//  SetProfileViewController.swift
//  masterch
//
//  Created by HIroki Taniguti on 2016/04/12.
//  Copyright © 2016年 Fumiya Yamanaka. All rights reserved.
//

import UIKit

class SetProfileViewController: UIViewController, UITextFieldDelegate {
    

    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameTextFiled: UITextField!
    @IBOutlet weak var userIdLabel: UILabel!
    
    var profileImage: UIImage? = nil
    var homeImage: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        userIdLabel.text = "@" + NCMBUser.currentUser().userName
        
        //プロフィール写真の形を整える
        //!!! 写真をグレーでぼかしたい, 谷口
        userImageView.layer.cornerRadius = userImageView.frame.width/2
        //プロフィール写真を表示
        userImageView.image = UIImage(named: "noprofile.png")

        homeImage = UIImage(named: "noprofile.png")
        profileImage = UIImage(named: "noprofile.png")
        
        
    }
    
    //keyboardで、return押した時
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        //キーボードを閉じる
        textField.resignFirstResponder()
        return true
    }
    
    //keyboard以外をタップした時keyboardを下げる
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {


        if userNameTextFiled.isFirstResponder() {
            userNameTextFiled.resignFirstResponder()
        }
    }
    
}


// カメラ周り
extension SetProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    
    //プロフィール画面のカメラ選択ボタン
    @IBAction func editProfileImageButton(sender: AnyObject) {
        selectEditProfileImage()
    }

    func selectEditProfileImage() {
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
            let resizeImage = resize(image, width: 500, height: 500)
            image = resizeImage
            
            self.userImageView.image = image
            self.profileImage = image
            self.homeImage = image
        }
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //    画像選択がキャンセルされた時に呼ばれる.
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        // モーダルビューを閉じる
        self.dismissViewControllerAnimated(true, completion: nil)
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

func userSaveInBackground (){
    
}

// 投稿アクション周り
extension SetProfileViewController {
    //保存ボタン
    @IBAction func saveProfileButton(sender: AnyObject) {
        saveNewProfile()
    }

    //投稿ボタンプッシュ, 投稿機能メソッド
    func saveNewProfile() {
        let user = NCMBUser.currentUser()

        //ユーザーネーム保存
        user.setObject(userNameTextFiled.text, forKey: "userFaceName")
        print("userFaceName", userNameTextFiled.text)
        //自己紹介保存
        user.setObject("ここに自己紹介をいれます", forKey: "userSelfIntroduction")
        
        
        // プロフィール写真保存
        if profileImage != nil {
            
            //設定してもらったProfileImageをユーザー情報に追加
            let userProfileImageData = UIImagePNGRepresentation(self.profileImage!)! as NSData
            let userProfileImageFile: NCMBFile = NCMBFile.fileWithData(userProfileImageData) as! NCMBFile
            user.setObject(userProfileImageFile.name, forKey: "userProfileImage")
            
            //ファイルはバックグラウンド実行をする
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
        }else {
            print("profileImageはnil")
        }
        
        if homeImage != nil {
            //設定してもらったHomeImageをユーザー情報に追加
            let userHomeImageData = UIImagePNGRepresentation(self.profileImage!)! as NSData
            let userHomeImageFile: NCMBFile = NCMBFile.fileWithData(userHomeImageData) as! NCMBFile
            user.setObject(userHomeImageFile.name, forKey: "userHomeImage")
            
            //ファイルはバックグラウンド実行をする
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
        }else {
            print("homeImageはnil")            
        }
        
        
        user.saveInBackgroundWithBlock({(error) in
            if error != nil { print("Save error : ",error)}
        })
        
        performSegueWithIdentifier("signUpSegue", sender: self)
    }
}
