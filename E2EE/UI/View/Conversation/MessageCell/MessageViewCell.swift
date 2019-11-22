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
    
    var viewModel : TextMessageViewModel
    
    var avatarImageNode = ASNetworkImageNode()
    
    var timeNode = ASTextNode()
    
    var statusNode = ASTextNode()
    
    var contentNode = TextContentNode()
    
    var hideDetails : Bool = true{
        didSet{
            setNeedsLayout()
        }
    }
    
    init(viewModel : TextMessageViewModel) {
        self.viewModel = viewModel
        
        super.init()
        
        setup()
        reloadData()
    }
    
    
    private func setup(){
        self.automaticallyManagesSubnodes = true
        
        avatarImageNode.style.preferredSize = CGSize(squareEdge: 28)
        avatarImageNode.imageModificationBlock = ASImageNodeRoundBorderModificationBlock(0, nil)
    }
    
    public func reloadData(){
        viewModel.reloabdData {
            ASPerformBlockOnMainThread {
                self.updateDataCellNode()
            }
        }
    }
    
    private func updateDataCellNode(){
        avatarImageNode.url = viewModel.avatarURL
        
        contentNode.attributedText = viewModel.textContent
        contentNode.bubble.image = viewModel.bubbleImage
        
        isIncommingMessage = viewModel.isIncommingMessage
        
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return isIncommingMessage ? layoutSpecThatFitsIncommingMessage(constrainedSize) : layoutSpecThatFitsOutgoingMessage(constrainedSize)
    }
    
    func layoutSpecThatFitsOutgoingMessage(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        var subContentStackChildren : [ASLayoutElement]
        if hideDetails{
            subContentStackChildren = [self.contentNode]
        }else{
            subContentStackChildren = [self.timeNode, self.contentNode, self.statusNode]
        }
        
        let subContentStack = ASStackLayoutSpec(direction: .vertical,
                                                spacing: 5,
                                                justifyContent: .end, alignItems: .stretch,
                                                children: subContentStackChildren)
        
        let contentStack = ASStackLayoutSpec(direction: .horizontal,
                                             spacing: 10,
                                             justifyContent: .end,
                                             alignItems: .center,
                                             children: [subContentStack, self.avatarImageNode])
        contentStack.style.maxSize = constrainedSize.max
        contentStack.style.minSize = constrainedSize.min
        
        return ASInsetLayoutSpec(insets: UIEdgeInsets.zero, child: contentStack)
    }
    
    func layoutSpecThatFitsIncommingMessage(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        var subContentStackChildren : [ASLayoutElement]
        if hideDetails{
            subContentStackChildren = [self.contentNode]
        }else{
            subContentStackChildren = [self.timeNode, self.contentNode, self.statusNode]
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
        
        return ASInsetLayoutSpec(insets: UIEdgeInsets.zero, child: contentStack)
    }
    
    
    
    @objc func contentNodeClicked(node : ASDisplayNode){
        hideDetails = !hideDetails
    }
}
