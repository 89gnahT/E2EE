//
//  MessageViewCell.swift
//  E2EE
//
//  Created by Truong Nguyen on 11/19/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import UIKit
import AsyncDisplayKit

protocol MessageCellDelegate {
    func messageCell(_ cell : MessageCell, avatarClicked avatarNode : ASImageNode)
    
    func messageCell(_ cell : MessageCell, subFunctionClicked subFunctionNode : ASImageNode)
    
    //func messageCell(_ cell : MessageCell, longPressContent contentNode : ContentNode)
}

class MessageCell: ASCellNode {
    
    var justifyContent : ASStackLayoutJustifyContent = .start
    
    var delegate : MessageCellDelegate?
    
    var isIncommingMessage : Bool = true{
        didSet{
            if self.isIncommingMessage{
                justifyContent = .start
            }else{
                justifyContent = .end
            }
        }
    }
    
    var viewModel : MessageViewModel
    
    var avatarImageNode = ASNetworkImageNode()
    
    var timeNode = ASTextNode()
    
    var statusNode = ASTextNode()
    
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
    
    public func updateUI(){
        avatarImageNode.url = viewModel.avatarURL
        
        isIncommingMessage = viewModel.isIncommingMessage
    
        timeNode.attributedText = viewModel.time
        
        statusNode.attributedText = viewModel.status
        
        insets = viewModel.insets
        
        avatarImageNode.isHidden = !viewModel.isShowAvatar
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        self.updateCellAttributeWhenLayout()
        let content = self.layoutSpecForMessageContent(constrainedSize)
        
        var subContentStackChildren : [ASLayoutElement]
        if hideDetails{
            subContentStackChildren = [content]
        }else{
            subContentStackChildren = [self.timeNode, content, self.statusNode]
        }
        let subContentStack = ASStackLayoutSpec(direction: .vertical,
                                                spacing: 5,
                                                justifyContent: justifyContent, alignItems: .stretch,
                                                children: subContentStackChildren)
        
        let contentStack = ASStackLayoutSpec(direction: .horizontal,
                                             spacing: 10,
                                             justifyContent: justifyContent,
                                             alignItems: .center,
                                             children: [subContentStack])
        
        if isIncommingMessage{
            contentStack.children?.insert(self.avatarImageNode, at: 0)
        }
        
        contentStack.style.maxSize = constrainedSize.max
        contentStack.style.minSize = constrainedSize.min
        
        return ASInsetLayoutSpec(insets: insets, child: contentStack)
    }
    
    func updateCellAttributeWhenLayout(){
        
    }
    
    func layoutSpecForMessageContent(_ constrainedSize : ASSizeRange) -> ASLayoutSpec{
        assert(false, "layoutSpecForMessageContent should be override in subClass")
        return ASLayoutSpec()
    }
    
}
