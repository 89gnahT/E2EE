//
//  ChatInput.swift
//  E2EE
//
//  Created by CPU12015 on 11/29/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import PINCache

protocol ChatInputViewDelegate {
    func chatInputViewSizeDidChange(chatInputView: ChatInputView)
}

class ChatInputView: ASDisplayNode {
    
    var collapseBtn = ASButtonNode()
    var sendBtn = ASButtonNode()
    let inputChat = TextInputChat()
    let option = OptionalChatInput()
    let editText = ASEditableTextNode()
    
    var delegate: ChatInputViewDelegate?
    
    var inputExpanded: Bool = false{
        didSet{
            ASPerformBlockOnMainThread {
                self.inputChatSizeDidChange = false;
                self.transitionLayout(withAnimation: true, shouldMeasureAsync: true, measurementCompletion: nil)
            }
        }
    }
    
    private var inputChatSizeDidChange: Bool = true
    
    private var inputChatDidChangeLine: Bool = false
    
    private var newFrame: CGRect = CGRect.zero
    
    override init() {
        super.init()
        
        setup()
    }
    
    private func setup(){
        automaticallyManagesSubnodes = true
        backgroundColor = .white
        
        collapseBtn.setBackgroundImage(UIImage(named: "collapseBtn"), for: .normal)
        collapseBtn.style.preferredSize = CGSize(width: 25, height: 25)
        
        sendBtn.setBackgroundImage(UIImage(named: "sendBtn"), for: .normal)
        sendBtn.style.preferredSize = CGSize(width: 25, height: 25)
        
        inputChat.delegate = self
    }
    
    override func didLoad() {
        super.didLoad()
        
        collapseBtn.addTarget(self, action: #selector(collapseBtnPressed(_:)), forControlEvents: .touchUpInside)
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        var contenStackElements = [ASLayoutElement]()
        if inputExpanded{
            contenStackElements = [collapseBtn, inputChat, sendBtn]
        }else{
            contenStackElements = [option, inputChat, sendBtn]
        }
        let contentStack = ASStackLayoutSpec(direction: .horizontal, spacing: 10, justifyContent: .center, alignItems: .center, children: contenStackElements)
        
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 15), child: contentStack)
    }
    
    override func animateLayoutTransition(_ context: ASContextTransitioning) {
        if context.isAnimated(){
            var optionFinalFrame: CGRect
            var collapaseFinalFrame: CGRect
            
            inputChat.frame = context.initialFrame(for: inputChat)
            sendBtn.frame = context.initialFrame(for: sendBtn)
            
            if inputExpanded{
                optionFinalFrame = context.initialFrame(for: option)
                optionFinalFrame.origin.x -= optionFinalFrame.width
                
                let collapaseInitialFrame = context.finalFrame(for: collapseBtn)
                collapaseFinalFrame = collapaseInitialFrame
                collapseBtn.alpha = 0
            }else{
                var optionInitialFrame = context.finalFrame(for: option)
                optionInitialFrame.origin.x -= optionInitialFrame.width
                option.frame = optionInitialFrame
                option.alpha = 0
                optionFinalFrame = context.finalFrame(for: option)
                
                collapaseFinalFrame = context.initialFrame(for: collapseBtn)
                collapseBtn.alpha = 1
            }
                
            UIView.animate(withDuration: 0.25, animations: {
                if self.inputExpanded{
                    self.option.alpha = 0
                    self.collapseBtn.alpha = 1
                }else{
                    self.option.alpha = 1
                    self.collapseBtn.alpha = 0
                }
                
                self.option.frame = optionFinalFrame
                self.collapseBtn.frame = collapaseFinalFrame
                
                self.inputChat.frame = context.finalFrame(for: self.inputChat)
                self.sendBtn.frame = context.finalFrame(for: self.sendBtn)
                
            }) { (finished) in
                context.completeTransition(finished)
                self.inputChatSizeDidChange = true
                self.inputChatDidChangeLine = false
            }
        }else{
            super.animateLayoutTransition(context)
        }
        
    }
    
    @objc func collapseBtnPressed(_ buttonNode: ASButtonNode){
        if inputExpanded{
            inputExpanded = false
        }
    }
}

extension ChatInputView: TextInputChatDelegate{
    
    func textInputChatDidBeginEditing(textInput: TextInputChat) {
        if !inputExpanded{
            inputExpanded = true
        }
    }
    
    func textInputChatDidFinishEditing(textInput: TextInputChat) {
        if inputExpanded{
            inputExpanded = false
        }
    }
    
    func textInputChatSizeDidChange(textInput: TextInputChat, newSize: CGSize) {
//        let delta = newSize.height - textInput.frame.height
//        newFrame = frame
//        newFrame.origin.y -= delta
//        newFrame.size.height += delta
//
//        inputChatDidChangeLine = true
        //transitionLayout(withAnimation: true, shouldMeasureAsync: true, measurementCompletion: nil)
        setNeedsLayout()
    }
    
}

protocol TextInputChatDelegate {
    func textInputChatSizeDidChange(textInput: TextInputChat, newSize: CGSize)
    
    func textInputChatDidBeginEditing(textInput: TextInputChat)
    
    func textInputChatDidFinishEditing(textInput: TextInputChat)
    
}

class TextInputChat: ASDisplayNode{
    let editText = ASEditableTextNode()
    
    let backgroundNode = ASImageNode()
    
    var delegate: TextInputChatDelegate?
    
    var maxNumberOfLine: UInt = 5{
        didSet{
            
        }
    }
    
    private var lastNumberLine: CGFloat = 1
    
    override init() {
        super.init()
        
        automaticallyManagesSubnodes = true
        
        let backgroundColor = UIColor(rgb: 240, a: 255)
        let imageName = "background_input_chat"
        backgroundNode.image = resizableImage(UIImage(named: imageName), color: backgroundColor, imageName: imageName + backgroundColor.toHexString())
        let fontSize = CGFloat(15)
        editText.attributedPlaceholderText = attributedString("Aa", fontSize: fontSize, isBold: false, foregroundColor: .darkGray)
        editText.textView.font = UIFont.defaultFont(ofSize: fontSize)
        editText.textContainerInset = UIEdgeInsets(top: 7, left: 20, bottom: 7, right: 12)
        editText.delegate = self
        
        style.flexGrow = 1.0
        //style.flexShrink = 1.0
    }
    
    func resizableImage(_ i : UIImage?, color : UIColor, imageName: String) -> UIImage?{
        return StandardBubbleConfiguration.shared.resizableImage(i, color: color, imageName: imageName)
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let contentLayout = ASInsetLayoutSpec(insets: UIEdgeInsets.zero, child: editText)
        return ASBackgroundLayoutSpec(child: contentLayout, background: backgroundNode)
    }
    
}

extension TextInputChat: ASEditableTextNodeDelegate{
    
    func editableTextNodeDidBeginEditing(_ editableTextNode: ASEditableTextNode) {
        delegate?.textInputChatDidBeginEditing(textInput: self)
    }
    
    func editableTextNodeDidFinishEditing(_ editableTextNode: ASEditableTextNode) {
        delegate?.textInputChatDidFinishEditing(textInput: self)
    }
    
    func editableTextNodeDidUpdateText(_ editableTextNode: ASEditableTextNode) {
        let lineHeight = editableTextNode.textView.font!.lineHeight
        let max = CGFloat(maxNumberOfLine)
        let heightInset = self.editText.textContainerInset.top + self.editText.textContainerInset.bottom
        ASPerformBlockOnBackgroundThread {
            let sizeThatFitsTextView = editableTextNode.calculateSizeThatFits(CGSize(width: 0, height: CGFloat(MAXFLOAT)))
            
            let numberOfLines = (sizeThatFitsTextView.height - heightInset) / lineHeight
            if abs(numberOfLines - self.lastNumberLine) >= 1{
                self.lastNumberLine = numberOfLines
                
                editableTextNode.style.preferredSize.height = numberOfLines <= max ? sizeThatFitsTextView.height : max * lineHeight + heightInset
                
                self.setNeedsLayout()
                
                ASPerformBlockOnMainThread {
                    self.delegate?.textInputChatSizeDidChange(textInput: self, newSize: editableTextNode.style.preferredSize)
                }
            }
        }
    }
    
}

class OptionalChatInput: ASDisplayNode{
    var cameraBtn = ASButtonNode()
    var imageBtn = ASButtonNode()
    var voiceBtn = ASButtonNode()
    var plusBtn = ASButtonNode()
    
    override init() {
        super.init()
        
        setup()
    }
    
    private func setup(){
        automaticallyManagesSubnodes = true
        backgroundColor = .white
        
        let btnSize = CGSize(width: 25, height: 25)
        cameraBtn.setBackgroundImage(UIImage(named: "cameraBtn"), for: .normal)
        cameraBtn.style.preferredSize = btnSize
        
        plusBtn.setBackgroundImage(UIImage(named: "plusBtn"), for: .normal)
        plusBtn.style.preferredSize = btnSize
        
        imageBtn.setBackgroundImage(UIImage(named: "imageBtn"), for: .normal)
        imageBtn.style.preferredSize = btnSize
        
        voiceBtn.setBackgroundImage(UIImage(named: "voiceBtn"), for: .normal)
        voiceBtn.style.preferredSize = btnSize
        
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let contentStack = ASStackLayoutSpec(direction: .horizontal, spacing: 10, justifyContent: .center, alignItems: .stretch, children: [self.plusBtn, self.cameraBtn, self.imageBtn, self.voiceBtn])
        
        return ASInsetLayoutSpec(insets: UIEdgeInsets.zero, child: contentStack)
    }
}
