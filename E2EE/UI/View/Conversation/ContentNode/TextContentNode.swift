//
//  TextContentNode.swift
//  E2EE
//
//  Created by CPU12015 on 11/22/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class TextContentNode: ContentNode {
    open var textNode = ASTextNode()
    
    open var attributedText : NSAttributedString = NSAttributedString(){
        didSet{
            textNode.attributedText = self.attributedText
            setNeedsLayout()
        }
    }
    
    open var insets = UIEdgeInsets(top: 9, left: 12, bottom: 9, right: 12) {
        didSet {
            setNeedsLayout()
        }
    }
    
    override init() {
        super.init()
      
        setup()
    }
    
    private func setup(){
        textNode.maximumNumberOfLines = 50
        textNode.style.maxWidth = ASDimension(unit: .points, value: 300)
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let x = ASInsetLayoutSpec(insets: insets, child: textNode)
        
        return x
    }
    
}
