//
//  ImageManager.swift
//  masterch
//
//  Created by HIroki Taniguti on 2016/07/25.
//  Copyright © 2016年 Fumiya Yamanaka. All rights reserved.
//

import UIKit


class ImageManger: UIViewController, EditProfileTableViewControllerDelegate {

    func chageImage(image: UIImage, tag: Int){

    }
}

// カメラ周り
extension ImageManger: UIImagePickerControllerDelegate, UINavigationControllerDelegate,  RSKImageCropViewControllerDelegate, RSKImageCropViewControllerDataSource  {
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

    func selectImage(tag: Int) {
        switch ImageTag {
        case 1:
            print("プロフィール画面変更")
            selectChangeImageButton
        case 2:
            print("ホーム画面変更")
            selectChangeImageButton
        default:
            return nil

        }

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

    //    画像選択がキャンセルされた時に呼ばれる.
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        // モーダルビューを閉じる
        self.dismissViewControllerAnimated(true, completion: nil)
        print("カメラキャンセル")
    }

    //　写真を選択した時に呼ばれるメソッド
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if info[UIImagePickerControllerOriginalImage] != nil {
            var image = info[UIImagePickerControllerOriginalImage] as! UIImage
            switch ImageTag {
            case 1:
                let imageCropVC = RSKImageCropViewController.init(image: image, cropMode: .Circle)
                imageCropVC.delegate = self
                imageCropVC.dataSource = nil
                self.navigationController?.pushViewController(imageCropVC, animated: true)
            case 2:
                let imageCropVC = RSKImageCropViewController.init(image: image, cropMode: .Custom)
                imageCropVC.delegate = self
                imageCropVC.dataSource = self
                self.navigationController?.pushViewController(imageCropVC, animated: true)
            default:
                return nil
            }
        }
        picker.dismissViewControllerAnimated(true, completion: nil)
    }

    // 画像リサイズメソッド(今のとこ使わない)
    func resize(image: UIImage, width: Int, height: Int) -> UIImage {
        let size: CGSize = CGSize(width: width, height: height)
        UIGraphicsBeginImageContext(size)
        image.drawInRect(CGRectMake(0, 0, size.width, size.height))

        let resizeImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizeImage
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

    func imageCropViewControllerDidCancelCrop(controller: RSKImageCropViewController) {
        print("imageCropViewControllerDidCancelCrop")
        self.navigationController?.popViewControllerAnimated(true)
    }

    func imageCropViewController(controller: RSKImageCropViewController, didCropImage croppedImage: UIImage, usingCropRect cropRect: CGRect) {
        print("imageCropViewController")
        switch ImageTag {
        case 1:
            self.userProfileImageView.image = croppedImage
        case 2:
            self.userHomeImageView.image = croppedImage
        default:
            return nil
        }
        self.navigationController?.popViewControllerAnimated(true)
    }
}



