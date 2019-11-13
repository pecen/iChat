//
//  DesignableButton.swift
//  iChat
//
//  Created by Peter Centellini on 2019-11-12.
//  Copyright © 2019 Redesajn Interactive Solutions. All rights reserved.
//

import Foundation
import UIKit

// Set the 'Class' under Custom Class in the Identity Inspector to this
// class, i.e. DesignableButton instead of UIButton
@IBDesignable class DesignableButton : UIButton
{
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
// The following commented out code is just an example of how you can
// change the corner radius for buttons programmatically by only first adding the
// @IBDesignable attribute to the class. If you only add the attribute
// @IBDesignable to the class and have the code below commented out, you can set it
// manually in the User Defined Runtime Attribute under the Identity Inspector,
// where KeyPath=layer.cornerRadius, Type=Number, Value=70 (value is your choice).
        
//        updateCornerRadius()

//    @IBInspectable var rounded: Bool = false {
//        didSet {
//            updateCornerRadius()
//        }
//    }
//
//    func updateCornerRadius() {
//        layer.cornerRadius = rounded ? frame.size.height / 2 : 0
//    }
}
