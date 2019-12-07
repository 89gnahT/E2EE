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
    
    func messageCell(_ cell : MessageCell, contentClicked contentNode: ASDisplayNode)
    
    func messageCell(_ cell : MessageCell, longPressGesture: UILongPressGestureRecognizer)
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
    
    var isHideDetails : Bool = true{
        didSet{
            //updateUI()
            self.transitionLayout(withAnimation: true, shouldMeasureAsync: false, measurementCompletion: nil)
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
        
        setupContent()
        
        updateUI()
    }
    
    override func didLoad() {
        super.didLoad()
        
        avatarImageNode.addTarget(self, action: #selector(avatarClicked(_:)), forControlEvents: .touchUpInside)
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        longPressGesture.minimumPressDuration = 0.7
        longPressGesture.delegate = self
        getContentNode().view.addGestureRecognizer(longPressGesture)
    }
    
    public func updateUI(){
        ASPerformBlockOnBackgroundThread {
            let viewModel = self.getViewModel()
            viewModel.updateData(nil)
            
            self.avatarImageNode.url = viewModel.avatarURL
            
            self.isIncommingMessage = viewModel.isIncommingMessage
            
            self.timeNode.attributedText = viewModel.time
            
            self.statusNode.attributedText = viewModel.status
            
            self.insets = viewModel.insets
            
            self.avatarImageNode.isHidden = !viewModel.isShowAvatar
            
            self.updateUIContent()
            
            self.setNeedsLayout()
        }
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        self.updateCellAttributeWhenLayout()
        let content = self.layoutSpecForMessageContent(constrainedSize)
        
        var subContentStackChildren : [ASLayoutElement]
        if isHideDetails{
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
    
    override func animateLayoutTransition(_ context: ASContextTransitioning) {
        if context.isAnimated(){
            if isHideDetails{
                if self.isIncommingMessage{
                    avatarImageNode.frame = context.finalFrame(for: avatarImageNode)
                }
                            
                let contentNode: ASDisplayNode = getContentNode()
                contentNode.frame = context.finalFrame(for: contentNode)
                
                var finalStatusNodeFrame = context.initialFrame(for: statusNode)
                finalStatusNodeFrame.origin.y += finalStatusNodeFrame.size.height
                statusNode.alpha = 0
                
                var finalTimeNodeFrame = context.initialFrame(for: timeNode)
                finalTimeNodeFrame.origin.y += finalTimeNodeFrame.size.height
                timeNode.alpha = 0
                
                UIView.animate(withDuration: 0.3, animations: {
                    
                    self.statusNode.frame = finalStatusNodeFrame
                    self.statusNode.alpha = 0
                                     
                    self.timeNode.frame = finalTimeNodeFrame
                    self.timeNode.alpha = 0
                    
                    contentNode.frame = context.initialFrame(for: contentNode)
                    
                    if self.isIncommingMessage{
                        self.avatarImageNode.frame = context.initialFrame(for: self.avatarImageNode)
                    }
                    
                }) { (finished) in
                    context.completeTransition(finished)
                }
            }else{
                if isIncommingMessage{
                    avatarImageNode.frame = context.finalFrame(for: avatarImageNode)
                }
                
                let contentNode: ASDisplayNode = getContentNode()
                contentNode.frame = context.finalFrame(for: contentNode)
                
                var initialStatusNodeFrame = context.finalFrame(for: statusNode)
                initialStatusNodeFrame.origin.y += initialStatusNodeFrame.size.height
                statusNode.frame = initialStatusNodeFrame
                statusNode.alpha = 0
                
                var initialTimeNodeFrame = context.finalFrame(for: timeNode)
                initialTimeNodeFrame.origin.y += initialTimeNodeFrame.size.height
                timeNode.frame = initialTimeNodeFrame
                timeNode.alpha = 0
                
                UIView.animate(withDuration: 0.3, animations: {
                    self.statusNode.frame = context.finalFrame(for: self.statusNode)
                    self.statusNode.alpha = 1
                    
                    self.timeNode.frame = context.finalFrame(for: self.timeNode)
                    self.timeNode.alpha = 1
                    
                    contentNode.frame = context.initialFrame(for: contentNode)
          
                    if self.isIncommingMessage{
                        self.avatarImageNode.frame = context.initialFrame(for: self.avatarImageNode)
                    }
                    
                }) { (finished) in
                    context.completeTransition(finished)
                }
            }
        }else{
            super.animateLayoutTransition(context)
        }
        
    }
    
// MARK: - Should be override in subclass
    func setupContent(){
        
    }
    
    func getViewModel() -> MessageViewModel{
        assert(false, "getViewModel should be override in subClass")
        return MessageViewModel(model: MessageModel())
    }
    
    func getContentNode() -> ContentNode{
        assert(false, "getContentNode should be override in subClass")
        return ContentNode()
    }
    
    public func updateUIContent(){
        
    }
    
    func updateCellAttributeWhenLayout(){
           
       }
    
    func layoutSpecForMessageContent(_ constrainedSize : ASSizeRange) -> ASLayoutSpec{
        assert(false, "layoutSpecForMessageContent should be override in subClass")
        return ASLayoutSpec()
    }
}

// MARK: - Handle UIGestureRecognizerDelegate
extension MessageCell: UIGestureRecognizerDelegate{
    @objc func handleLongPress(longPressGesture: UILongPressGestureRecognizer) {
        ASPerformBlockOnMainThread {
            self.delegate?.messageCell(self, longPressGesture: longPressGesture)
        }        
    }
    
    @objc func avatarClicked(_ avatarNode : ASImageNode){
        
    }
    
    @objc func subFunctionClicked(_ subFunctionNode : ASImageNode){
        
    }
    
    @objc func contentClicked(_ contentNode : ASDisplayNode){
        delegate?.messageCell(self, contentClicked: getContentNode())
    }
    
}

extension MessageCell{
    
}
