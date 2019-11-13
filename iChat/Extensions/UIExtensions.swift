//
//  UIExtensions.swift
//  iChat
//
//  Created by Peter Centellini on 2019-11-12.
//  Copyright © 2019 Redesajn Interactive Solutions. All rights reserved.
//

import Foundation
import UIKit

// The following extension could of course be used on UIViews as well, instead of
// only UIButton, to be able to set the radius for any UIView derived class
extension UIButton {
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
}
