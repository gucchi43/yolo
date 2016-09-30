//
//  UIExtension.swift
//  
//
//  Created by HIroki Taniguti on 2016/05/20.
//
//

import UIKit

class UIExtension: NSObject {
    

}

extension UITextField {
    
    func addUnderline(width: CGFloat, color: UIColor) {
        
        let border = CALayer()
        
        border.frame = CGRect(x: 0, y: self.frame.height - width, width: self.frame.width, height: width)
        
        border.backgroundColor = color.CGColor
        
        self.layer.addSublayer(border)
        
    }
    
}


extension UIView {
    func toImage() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(self.frame.size, false, 0.0)
        let context = UIGraphicsGetCurrentContext()
        CGContextTranslateCTM(context, 0.0, 0.0)
        self.layer.renderInContext(context!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return image
    }
}


@IBDesignable
class Button_Custom: UIButton {
    
    @IBInspectable var textColor: UIColor?
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var borderColor: UIColor = UIColor.clearColor() {
        didSet {
            layer.borderColor = borderColor.CGColor
        }
    }
}