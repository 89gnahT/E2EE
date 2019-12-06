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
    
    private let copyBtn = ASButtonNode()
    
    private let fontSize : CGFloat = 15
    
    private var edgeInsets = UIEdgeInsets(top: 16, left: 8, bottom: 8, right: 16)
    
    private let optionNode = ASDisplayNode()
    
    public var messageCell : MessageCell?
    
    
    init(target : Any?,
         frame : CGRect,
         removeBtnAction : Selector) {
        
        super.init()
        
        self.automaticallyManagesSubnodes = true
        self.frame = frame
        self.backgroundColor = UIColor(white: 0, alpha: 0)
        self.isOpaque = true
        self.edgeInsets = UIEdgeInsets.zero
        
        removeBtn.addTarget(target, action: removeBtnAction, forControlEvents: .touchUpInside)
        removeBtn.setAttributedTitle(attributedString("Remove", fontSize: fontSize, isBold: true, foregroundColor: .systemRed), for: .normal)
        removeBtn.setImage(UIImage(named: "trash"), for: .normal)
        removeBtn.laysOutHorizontally = false
        
        copyBtn.setAttributedTitle(attributedString("Copy", fontSize: fontSize, isBold: true, foregroundColor: .darkGray), for: .normal)
        copyBtn.setImage(UIImage(named: "copy"), for: .normal)
        copyBtn.laysOutHorizontally = false
                       
        optionNode.backgroundColor = .white
        optionNode.automaticallyManagesSubnodes = true
        optionNode.layoutSpecBlock = { (node : ASDisplayNode, constrainedSize : ASSizeRange) -> ASLayoutSpec in
            let contentStack = ASStackLayoutSpec.horizontal()
            contentStack.children = [self.copyBtn, self.removeBtn]
            contentStack.justifyContent = .spaceBetween
            
            return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 8, left: 20, bottom: 8, right: 20), child: contentStack)
        }
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let optionNodePosition = constrainedSize.max.height * 8 / 9
        optionNode.style.layoutPosition = CGPoint(x: 0, y: optionNodePosition)
        optionNode.style.preferredSize = CGSize(width: constrainedSize.max.width, height: constrainedSize.max.height - optionNodePosition)
        
        return ASAbsoluteLayoutSpec(children: [optionNode])
    }
    
    override func removeFromSupernode() {
        super.removeFromSupernode()        
    }
    
    deinit {
        print("denitiiiiiï")
    }
}
