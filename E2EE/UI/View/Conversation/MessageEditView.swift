//
//  MessageCellEditView.swift
//  E2EE
//
//  Created by Truong Nguyen on 12/4/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class MessageEditView: ASDisplayNode {
    
    private let removeBtn = ASButtonNode ()
    
    private let copyBtn = ASButtonNode()
    
    private let forward = ASButtonNode()
    
    private let fontSize : CGFloat = 13
    
    private var edgeInsets = UIEdgeInsets(top: 16, left: 8, bottom: 8, right: 16)
    
    private let optionNode = ASDisplayNode()
    
    private var optionNodeHeight = CGFloat(60)
    
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
        removeBtn.setAttributedTitle(attributedString("Remove", fontSize: fontSize, isBold: false, foregroundColor: .systemRed), for: .normal)
        removeBtn.setImage(UIImage(named: "trash"), for: .normal)
        removeBtn.laysOutHorizontally = false
        
        forward.setAttributedTitle(attributedString("Forward", fontSize: fontSize, isBold: false, foregroundColor: .darkGray), for: .normal)
        forward.setImage(UIImage(named: "right_arrow"), for: .normal)
        forward.laysOutHorizontally = false
        
        copyBtn.setAttributedTitle(attributedString("Copy", fontSize: fontSize, isBold: false, foregroundColor: .darkGray), for: .normal)
        copyBtn.setImage(UIImage(named: "copy"), for: .normal)
        copyBtn.laysOutHorizontally = false
        
        optionNode.backgroundColor = .white
        optionNode.automaticallyManagesSubnodes = true
        optionNode.layoutSpecBlock = { (node : ASDisplayNode, constrainedSize : ASSizeRange) -> ASLayoutSpec in
            let contentStack = ASStackLayoutSpec.horizontal()
            contentStack.children = [self.copyBtn, self.forward, self.removeBtn]
            contentStack.justifyContent = .spaceAround
            
            return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: 0, bottom: 8, right: 0), child: contentStack)
        }
        optionNode.setNeedsLayout()
    }
    
    override func safeAreaInsetsDidChange() {
        optionNodeHeight = 60 + safeAreaInsets.bottom
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        optionNode.style.layoutPosition = CGPoint(x: 0, y: constrainedSize.max.height - optionNodeHeight)
        optionNode.style.preferredSize = CGSize(width: constrainedSize.max.width, height: optionNodeHeight)
        
        return ASAbsoluteLayoutSpec(children: [optionNode])
    }
    
    override func animateLayoutTransition(_ context: ASContextTransitioning) {
        optionNode.frame.origin.y += optionNode.frame.height
        optionNode.alpha = 0
        
        UIView.animate(withDuration: 0.25, animations: {
            self.optionNode.frame = context.finalFrame(for: self.optionNode)
            self.optionNode.alpha = 1
            
        }) { (finished) in
            context.completeTransition(finished)
        }
    }
    
    override func removeFromSupernode() {
        super.removeFromSupernode()
        
        if messageCell?.isHideDetails ?? false{
            ASPerformBlockOnBackgroundThread {
                self.messageCell?.isHighlightContent = false
            }
        }
    }
    
    deinit {
        print("denitiiiiiï")
    }
}
