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
    
    func removeMessageCell(_ cell : MessageCell)
}

class MessageCell: ASCellNode {
    var justifyContent : ASStackLayoutJustifyContent = .start
    
    var delegate : MessageCellDelegate?
    
    var rootViewController : ChatScreenViewController?
    
    var isIncommingMessage : Bool = true{
        didSet{
            if self.isIncommingMessage{
                justifyContent = .start
            }else{
                justifyContent = .end
            }
        }
    }
  
    var avatarImageNode = ASNetworkImageNode()
    
    var timeNode = ASTextNode()
    
    var statusNode = ASTextNode()
    
    var hideDetails : Bool = true{
        didSet{
            setNeedsLayout()
        }
    }
    
    var insets : UIEdgeInsets = UIEdgeInsets.zero
    
    override init() {
        super.init()
        
        setup()
    }
    
    func setup(){
        self.automaticallyManagesSubnodes = true
        
        avatarImageNode.style.preferredSize = CGSize(squareEdge: 28)
        avatarImageNode.imageModificationBlock = ASImageNodeRoundBorderModificationBlock(0, nil)
        avatarImageNode.addTarget(self, action: #selector(avatarClicked(_:)), forControlEvents: .touchUpInside)
    }
    
    func getViewModel() -> MessageViewModel{
        assert(false, "getViewModel should be override in subClass")
        return MessageViewModel(model: MessageModel())
    }
    
    func updateCellAttributeWhenLayout(){
        
    }
    
    func layoutSpecForMessageContent(_ constrainedSize : ASSizeRange) -> ASLayoutSpec{
        assert(false, "layoutSpecForMessageContent should be override in subClass")
        return ASLayoutSpec()
    }
    
    public func updateUI(){
        let viewModel = getViewModel()
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
    
    @objc func avatarClicked(_ avatarNode : ASImageNode){
        
    }
    
    @objc func subFunctionClicked(_ subFunctionNode : ASImageNode){
        
    }
    
    @objc func contentClicked(_ contentNode : ASDisplayNode){
        
    }
}

extension MessageCell: UIGestureRecognizerDelegate{
    @objc func handleLongPress(longPressGesture: UILongPressGestureRecognizer) {
        ASPerformBlockOnMainThread {
            
            let subFunctionView = ASDisplayNode()
            subFunctionView.frame = (self.rootViewController?.tabBarController?.tabBar.frame)!
            subFunctionView.backgroundColor = .white
            subFunctionView.automaticallyManagesSubnodes = true
            
            let removeBtn = ASButtonNode()
            removeBtn.setAttributedTitle(attributedString("Remove", fontSize: 15, isBold: false, foregroundColor: .darkGray), for: .normal)
            removeBtn.addTarget(self, action: #selector(self.deleteMessageCell), forControlEvents: .touchUpInside)
            
            subFunctionView.layoutSpecBlock = { (node : ASDisplayNode, constrainedSize : ASSizeRange) -> ASLayoutSpec in
                let contentStack = ASStackLayoutSpec.horizontal()
                contentStack.children = [removeBtn]
                contentStack.justifyContent = .end
                
                return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8), child: contentStack)
            }
            subFunctionView.setNeedsLayout()
            
            self.rootViewController?.view.addSubnode(subFunctionView)
            
        }        
    }
}

extension MessageCell{
    @objc private func deleteMessageCell(){
        delegate?.removeMessageCell(self)
    }
}
