//
//  StrikeThroughText.swift
//  MyListApp
//
//  Created by Aoife McLaughlin on 12/04/2018.
//  Copyright © 2018 Aoife McLaughlin. All rights reserved.
//

import UIKit
import QuartzCore

class StrikeThroughText: UILabel {
    let strikeThroughLayer: CALayer
    
    var strikeThrough: Bool {
        didSet {
            strikeThroughLayer.isHidden = !strikeThrough
            if strikeThrough {
                resizeStrikeThrough()
            }
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    override init(frame: CGRect) {
        strikeThroughLayer = CALayer()
        strikeThroughLayer.backgroundColor = UIColor.white.cgColor
        strikeThroughLayer.isHidden = true
        strikeThrough  = false
        
        super.init(frame: frame)
        layer.addSublayer(strikeThroughLayer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        resizeStrikeThrough()
    }
    
    let kStrikeOutThickness: CGFloat = 2.0
    
    func resizeStrikeThrough() {
        let textSize = text!.size(withAttributes: [kCTFontAttributeName as NSAttributedStringKey: font])
        strikeThroughLayer.frame = CGRect(x: 0, y: bounds.size.height/2, width: textSize.width, height: kStrikeOutThickness)
    }
}
