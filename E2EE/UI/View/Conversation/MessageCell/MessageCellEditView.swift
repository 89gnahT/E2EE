//
//  MessageCellEditView.swift
//  E2EE
//
//  Created by Truong Nguyen on 12/4/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class MessageCellEditView: ASDisplayNode {
    
    private let removeBtn = ASButtonNode ()
    
    private let fontSize : CGFloat = 15
    
    private let edgeInsets = UIEdgeInsets(top: 16, left: 8, bottom: 8, right: 16)
    
    init(target : Any?,
         frame : CGRect,
         removeBtnAction : Selector) {
        
        super.init()
        
        backgroundColor = .white
        automaticallyManagesSubnodes = true
        self.frame = frame
        
        removeBtn.addTarget(target, action: removeBtnAction, forControlEvents: .touchUpInside)
        removeBtn.setAttributedTitle(attributedString("Remove", fontSize: fontSize, isBold: false, foregroundColor: .darkGray), for: .normal)
        removeBtn.laysOutHorizontally = false
        
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let contenStack = ASStackLayoutSpec(direction: .horizontal, spacing: 10, justifyContent: .end, alignItems: .stretch, children: [self.removeBtn])
        
        return ASInsetLayoutSpec(insets: edgeInsets, child: contenStack)
    }
    
    override func removeFromSupernode() {
        super.removeFromSupernode()
        
        removeBtn.removeTarget(nil, action: nil, forControlEvents: .allEvents)
    }
    
    deinit {
        print("denitiiiiiï")
    }
}
