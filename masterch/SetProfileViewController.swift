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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userIdLabel.text = "@" + NCMBUser.currentUser().userName
        
        //プロフィール写真の形を整える
        //!!! 写真をグレーでぼかしたい, 谷口
        userImageView.layer.cornerRadius = userImageView.frame.width/2
        userImageView.layer.masksToBounds = true
        //プロフィール写真を表示
        let userImageName = (NCMBUser.currentUser().objectForKey("userProfileImage") as? String)!
        let userImageData = NCMBFile.fileWithName(userImageName, data: nil) as! NCMBFile
        
        userImageData.getDataInBackgroundWithBlock { (imageData: NSData?, error: NSError!) -> Void in
            if error != nil{
                print("写真の取得失敗: \(error)")
                //初期の場合のユーザー画像
                self.userImageView.image = UIImage(named: "noprofile.png")
            } else {
                self.userImageView.image = UIImage(data: imageData!)
            }
        }
        
        
    }
    
    //keyboardで、return押した時
    func textFieldShouldReturn(textField: UITextField!) -> Bool {
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
    
    @IBAction func userInfo(sender: AnyObject) {
        print("user情報 \(NCMBUser.currentUser())")
    }
    
    //プロフィール画面のカメラ選択ボタン
    @IBAction func PhotoAndCamera(sender: AnyObject) {
        tappedToolBarCameraButton()
    }
    
    
    @IBAction func setFinishBtn(sender: AnyObject) {
        newProfileSave()
    }
    
    
    //完了ボタン（今はない）
    @IBAction func SaveProfileBtn(sender: AnyObject) {
        newProfileSave()
    }
}




// カメラ周り
extension SetProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    
    func tappedToolBarCameraButton() {
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


// 投稿アクション周り
extension SetProfileViewController {
    //    投稿ボタンプッシュ, 投稿機能メソッド
    func newProfileSave() {
        let user = NCMBUser.currentUser()
        
        //ユーザーネーム保存
        user.setObject(userNameTextFiled.text, forKey: "userFaceName")
        
        // プロフィール写真保存
        if profileImage != nil {
            
            let userimageData = UIImagePNGRepresentation(self.profileImage!)! as NSData
            let userimageFile: NCMBFile = NCMBFile.fileWithData(userimageData) as! NCMBFile
            
            user.setObject(userimageFile.name, forKey: "userProfileImage")
            
            //            ファイルはバックグラウンド実行をする
            userimageFile.saveInBackgroundWithBlock({ (error: NSError!) -> Void in
                if error == nil {
                    print("画像データ保存完了: \(userimageFile.name)")
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
        
//        self.performSegueWithIdentifier("signUpedSegue", sender: self)
        print("投稿完了")
    }
}
