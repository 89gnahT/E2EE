//
//  MessageViewCell.swift
//  E2EE
//
//  Created by Truong Nguyen on 11/19/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class MessageViewCell: ASCellNode {
    
    var isIncommingMessage : Bool = true
    
    var viewModel : MessageViewModel
    
    var avatarImageNode = ASNetworkImageNode()
    
    var timeNode = ASTextNode()
    
    var statusNode = ASTextNode()
    
    var contentNode = ContentNode()
    
    var bubble = Bubble()
    
    var hideDetails : Bool = true{
        didSet{
            setNeedsLayout()
        }
    }
    
    var insets : UIEdgeInsets = UIEdgeInsets.zero
    
    init(viewModel : MessageViewModel) {
        self.viewModel = viewModel
     
        super.init()
        
        setup()
    }
    
    private func setup(){
        self.automaticallyManagesSubnodes = true
        
        avatarImageNode.style.preferredSize = CGSize(squareEdge: 28)
        avatarImageNode.imageModificationBlock = ASImageNodeRoundBorderModificationBlock(0, nil)
    }
    
    public func reloadData(){
        avatarImageNode.url = viewModel.avatarURL
        
        isIncommingMessage = viewModel.isIncommingMessage
        
        bubble.image = viewModel.bubbleImage
        
        timeNode.attributedText = viewModel.time
        
        statusNode.attributedText = viewModel.status
        
        insets = viewModel.insets
        
        avatarImageNode.isHidden = !viewModel.isShowAvatar
        
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return isIncommingMessage ? layoutSpecThatFitsIncommingMessage(constrainedSize) : layoutSpecThatFitsOutgoingMessage(constrainedSize)
    }
    
    func layoutSpecThatFitsOutgoingMessage(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        var subContentStackChildren : [ASLayoutElement]
        let contentNodeWithBubble = ASBackgroundLayoutSpec(child: self.contentNode, background: bubble)
        if hideDetails{
            subContentStackChildren = [contentNodeWithBubble]
        }else{
            subContentStackChildren = [self.timeNode, contentNodeWithBubble, self.statusNode]
        }
        let subContentStack = ASStackLayoutSpec(direction: .vertical,
                                                spacing: 5,
                                                justifyContent: .end, alignItems: .stretch,
                                                children: subContentStackChildren)
        
        let contentStack = ASStackLayoutSpec(direction: .horizontal,
                                             spacing: 10,
                                             justifyContent: .end,
                                             alignItems: .center,
                                             children: [subContentStack])
        
        contentStack.style.maxSize = constrainedSize.max
        contentStack.style.minSize = constrainedSize.min
        
        return ASInsetLayoutSpec(insets: insets, child: contentStack)
    }
    
    func layoutSpecThatFitsIncommingMessage(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        var subContentStackChildren : [ASLayoutElement]
        let contentNodeWithBubble = ASBackgroundLayoutSpec(child: self.contentNode, background: bubble)
        if hideDetails{
            subContentStackChildren = [contentNodeWithBubble]
        }else{
            subContentStackChildren = [self.timeNode, contentNodeWithBubble, self.statusNode]
        }
        
        let subContentStack = ASStackLayoutSpec(direction: .vertical,
                                                spacing: 5,
                                                justifyContent: .start, alignItems: .stretch,
                                                children: subContentStackChildren)
        
        let contentStack = ASStackLayoutSpec(direction: .horizontal,
                                             spacing: 10,
                                             justifyContent: .start,
                                             alignItems: .center,
                                             children: [self.avatarImageNode, subContentStack])
        contentStack.style.maxSize = constrainedSize.max
        contentStack.style.minSize = constrainedSize.min
        
        return ASInsetLayoutSpec(insets: insets, child: contentStack)
    }
    
    
    
    @objc func contentNodeClicked(node : ASDisplayNode){
        hideDetails = !hideDetails
    }
}
