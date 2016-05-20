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