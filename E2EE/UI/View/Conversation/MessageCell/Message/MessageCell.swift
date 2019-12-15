//
//  MessageViewCell.swift
//  E2EE
//
//  Created by Truong Nguyen on 11/19/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import UIKit
import AsyncDisplayKit

protocol MessageCellDelegate: BaseMessageCellDelegate {
    func messageCell(_ cell : MessageCell, avatarClicked avatarNode : ASImageNode)
    
    func messageCell(_ cell : MessageCell, subFunctionClicked subFunctionNode : ASImageNode)
    
    func messageCell(_ cell : MessageCell, contentClicked contentNode: ASDisplayNode)
    
    func messageCell(_ cell : MessageCell, longPressGesture: UILongPressGestureRecognizer)
}

class MessageCell: BaseMessageCell {
    var justifyContent : ASStackLayoutJustifyContent = .start
    
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
            let setHighlightContentIfNeed = !isHideDetails
            
            ASPerformBlockOnBackgroundThread {
                self.isHighlightContent = setHighlightContentIfNeed
                
                ASPerformBlockOnMainThread {
                    self.transitionLayout(withAnimation: true, shouldMeasureAsync: true, measurementCompletion: nil)
                }
            }
        }
    }
    
    // Should call updateHighlightContentIfNeed() after set property
    var isHighlightContent: Bool = false{
        didSet{
            self.updateHighlightContentIfNeed()
        }
    }
    
    var insets : UIEdgeInsets = UIEdgeInsets.zero
    
    override init() {
        super.init()
    }
    
    override func setup(){
        super.setup()
        
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
    
    public override func updateUI(){
        ASPerformBlockOnBackgroundThread {
            let viewModel = self.getViewModel()
            viewModel.updateData(nil)
            
            self.avatarImageNode.url = viewModel.avatarURL
            
            self.isIncommingMessage = viewModel.isIncommingMessage
            
            self.timeNode.attributedText = viewModel.time
            
            self.statusNode.attributedText = viewModel.status
            
            self.avatarImageNode.isHidden = !viewModel.isShowAvatar
            
            self.insets = viewModel.insets
            
            self.updateUIContent()
            
            self.setNeedsLayout()
        }
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        self.updateCellAttributeWhenLayout()
        
        let topStack = ASStackLayoutSpec(direction: .horizontal, spacing: 0, justifyContent: .center, alignItems: .stretch, children: [timeNode])
        
        let contentStack = ASStackLayoutSpec(direction: .vertical, spacing: 5, justifyContent: justifyContent, alignItems: .end, children: [self.layoutSpecForMessageContent(constrainedSize)])
        if !isHideDetails{
            contentStack.children?.append(statusNode)
        }
        contentStack.alignItems = isIncommingMessage ? .start : .end
        
        let bottomStack = ASStackLayoutSpec(direction: .horizontal, spacing: 10, justifyContent: justifyContent, alignItems: .stretch, children: [contentStack])
        if isIncommingMessage{
            let avatarStack = ASStackLayoutSpec(direction: .vertical, spacing: 0, justifyContent: .end, alignItems: .stretch, children: [avatarImageNode])
            bottomStack.children?.insert(avatarStack, at: 0)
        }
        
        let stack = ASStackLayoutSpec(direction: .vertical, spacing: 15, justifyContent: justifyContent, alignItems: .stretch, children: [bottomStack])
        if !isHideDetails{
            stack.children?.insert(topStack, at: 0)
        }
        stack.style.maxSize = constrainedSize.max
        stack.style.minSize = constrainedSize.min
        
        var newInset = insets
        if !isHideDetails{
            newInset.top += 15
            newInset.bottom += 5
        }
        
        return ASInsetLayoutSpec(insets: newInset, child: stack)
    }
    
    override func animateLayoutTransition(_ context: ASContextTransitioning) {
        if context.isAnimated(){
            
            if isIncommingMessage{
                avatarImageNode.frame = context.initialFrame(for: avatarImageNode)
            }
            
            let contentNode: ASDisplayNode = getContentNode()
            contentNode.frame = context.initialFrame(for: contentNode)
            
            var targetStatusFrame = CGRect.zero
            var targetTimeNodeFrame = CGRect.zero
            if isHideDetails{
                targetStatusFrame = context.initialFrame(for: statusNode)
                targetStatusFrame.origin.y += targetStatusFrame.size.height
                
                targetTimeNodeFrame = context.initialFrame(for: timeNode)
                targetTimeNodeFrame.origin.y -= targetTimeNodeFrame.size.height
            }else{
                var initialStatusNodeFrame = context.finalFrame(for: statusNode)
                initialStatusNodeFrame.origin.y += initialStatusNodeFrame.size.height
                statusNode.frame = initialStatusNodeFrame
                statusNode.alpha = 0
                targetStatusFrame = context.finalFrame(for: self.statusNode)
                
                var initialTimeNodeFrame = context.finalFrame(for: timeNode)
                initialTimeNodeFrame.origin.y += initialTimeNodeFrame.size.height
                timeNode.frame = initialTimeNodeFrame
                timeNode.alpha = 0
                targetTimeNodeFrame = context.finalFrame(for: self.timeNode)
            }
            
            UIView.animate(withDuration: 0.35, animations: {
                if self.isHideDetails{
                    self.statusNode.alpha = 0
                    self.timeNode.alpha = 0
                }else{
                    self.statusNode.alpha = 1
                    self.timeNode.alpha = 1
                }
                self.statusNode.frame = targetStatusFrame
                self.timeNode.frame = targetTimeNodeFrame
                
                contentNode.frame = context.finalFrame(for: contentNode)
                
                if self.isIncommingMessage{
                    self.avatarImageNode.frame = context.finalFrame(for: self.avatarImageNode)
                }
                
                let fromSize = context.layout(forKey: ASTransitionContextFromLayoutKey)!.size
                let toSize = context.layout(forKey: ASTransitionContextToLayoutKey)!.size
                if !__CGSizeEqualToSize(fromSize, toSize){
                    self.frame = CGRect(origin: self.frame.origin, size: toSize)
                }
                
            }) { (finished) in
                context.completeTransition(finished)
            }
        }else{
            super.animateLayoutTransition(context)
        }
    }
    
    // MARK: - Should be override in subclass
    override func setupContent(){
        
    }
    
    override func getViewModel() -> MessageViewModel{
        assert(false, "getViewModel should be override in subClass")
        return MessageViewModel(model: MessageModel())
    }
    
    func getContentNode() -> ContentNode{
        assert(false, "getContentNode should be override in subClass")
        return ContentNode()
    }
    
    public override func updateUIContent(){
        
    }
    
    // Should call this method in background thread
    public func updateHighlightContentIfNeed(){
        
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
            (self.delegate as? MessageCellDelegate)?.messageCell(self, longPressGesture: longPressGesture)
            
            self.isHighlightContent = true
            self.updateHighlightContentIfNeed()
        }        
    }
    
    @objc func avatarClicked(_ avatarNode : ASImageNode){
        
    }
    
    @objc func subFunctionClicked(_ subFunctionNode : ASImageNode){
        
    }
    
    @objc func contentClicked(_ contentNode : ASDisplayNode){
        (delegate as? MessageCellDelegate)?.messageCell(self, contentClicked: getContentNode())
    }
    
}
