//
//  SetProfileViewController.swift
//  masterch
//
//  Created by HIroki Taniguti on 2016/04/12.
//  Copyright © 2016年 Fumiya Yamanaka. All rights reserved.
//

import UIKit
import SVProgressHUD

class SetProfileViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {

    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var userIdLabel: UILabel!
    @IBOutlet weak var selfIntroductionTextView: UITextView!
    @IBOutlet weak var saveProfileButton: UIBarButtonItem!
    
    var user = NCMBUser()
    
    var userId: String!
    var password: String!

//   テキストフィールドのplaceholder用ラベル
    @IBOutlet weak var placeHolderLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        user = NCMBUser.currentUser()
        userIdLabel.text = "@" + user.userName
        
        //プロフィール写真の形を整える
        //!!! 写真をグレーでぼかしたい, 谷口
        userImageView.layer.cornerRadius = userImageView.frame.width/2
        //プロフィール写真を表示
        userImageView.image = UIImage(named: "noprofile")
        
        //userIdTextField入力画面を呼び出し
        userNameTextField.becomeFirstResponder()
        userNameTextField.addUnderline(1.0, color: UIColor.lightGrayColor())

        selfIntroductionTextView.layer.borderWidth = 1.0
        selfIntroductionTextView.layer.borderColor = UIColor.lightGrayColor().CGColor
        selfIntroductionTextView.layer.cornerRadius = 5.0
        
//        文字数カウントのために入力後の通知を受け取れるようにする
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector:#selector(SetProfileViewController.userNameTextFieldDidChange(_:)),
            name: UITextFieldTextDidChangeNotification,
            object: nil)
    }
    
//    通知後に呼ばれるメソッドで文字数をカウントする
    func userNameTextFieldDidChange(notification:NSNotification) {
        if userNameTextField.text!.characters.count == 0 {
            saveProfileButton.enabled = false
        } else {
            saveProfileButton.enabled = true
        }
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
//        userNameTextFieldでreturn押した時に自己紹介のtextViewへ
        if textField == userNameTextField {
            selfIntroductionTextView.becomeFirstResponder()
        }
        return true
    }
    
    //textviewがフォーカスされたら、Labelを非表示
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        placeHolderLabel.hidden = true
        return true
    }

    //textviewからフォーカスが外れて、TextViewが空だったらLabelを再び表示
    func textViewDidEndEditing(textView: UITextView) {
        if(textView.text.isEmpty){
            placeHolderLabel.hidden = false
        }
    }
    
    //keyboard以外をタップした時keyboardを下げる
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if userNameTextField.isFirstResponder() {
            userNameTextField.resignFirstResponder()
        }
        if selfIntroductionTextView.isFirstResponder() {
            selfIntroductionTextView.resignFirstResponder()
        }
    }
}


// カメラ周り
extension SetProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    
    //プロフィール画面のカメラ選択ボタン
    @IBAction func selectEditProfileImageButton(sender: AnyObject) {
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
    //保存ボタン
    @IBAction func selectSaveProfileButton(sender: AnyObject) {
        saveNewProfile()
    }

    //投稿ボタンプッシュ, 投稿機能メソッド
    func saveNewProfile() {
        
        user.ACL.setPublicWriteAccess(true)
        user.ACL.setPublicReadAccess(true)
        //ユーザーネーム保存
        user.setObject(userNameTextField.text, forKey: "userFaceName")
        //自己紹介保存
        user.setObject(selfIntroductionTextView.text, forKey: "userSelfIntroduction")

        // プロフィール写真保存
        if userImageView.image != nil {
            
            //設定してもらったProfileImageをユーザー情報に追加
            let userProfileImageData = UIImagePNGRepresentation(self.userImageView.image!)! as NSData
            let userProfileImageFile: NCMBFile = NCMBFile.fileWithData(userProfileImageData) as! NCMBFile
            user.setObject(userProfileImageFile.name, forKey: "userProfileImage")
            user.setObject(userProfileImageFile.name, forKey: "userHomeImage")
                        
            //ファイルはバックグラウンド実行をする
            userProfileImageFile.saveInBackgroundWithBlock({ (error: NSError!) -> Void in
                if error == nil {
                    SVProgressHUD.dismiss()
                    print("画像データ保存完了: \(userProfileImageFile.name)")
                    self.performSegueWithIdentifier("signUpSegue", sender: self)
                } else {
                    print("アップロード中にエラーが発生しました: \(error)")
                    SVProgressHUD.dismiss()
                }
                }, progressBlock: { (percentDone: Int32) -> Void in
                    //                    進捗状況を取得します。保存完了まで何度も呼ばれます
//                    SVProgressHUD.showProgress(Float(percentDone)/Float(100), status: "登録中")
                    print("進捗状況: \(percentDone)% アップロード済み")
                    print("進捗状況SVProgressHUD用: \((Float(percentDone)/Float(100))) アップロード済み")
            })
        }else {
            print("profileImageはnil")
        }
        
        user.saveInBackgroundWithBlock({(error) in
            SVProgressHUD.show()
            if error != nil {
                print("Save error : ",error)
                SVProgressHUD.dismiss()
            }else {
                self.performSegueWithIdentifier("signUpSegue", sender: self)
                SVProgressHUD.dismiss()
            }
        })
        
       
        
    }
}
