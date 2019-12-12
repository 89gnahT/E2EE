//
//  ChatTest.swift
//  E2EE
//
//  Created by Truong Nguyen on 12/11/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import UIKit
import AsyncDisplayKit

protocol ChatInputNodeDelegate {
    func chatInputNodeFrameDidChange(_ chatInputNode: ChatInputNode, newFrame nf: CGRect, oldFrame of: CGRect)
    
    func chatInputNode(_ chatInputNode: ChatInputNode, sendText text: String)
}

class ChatInputNode: ASDisplayNode {
    
    let editTextNode = ASEditableTextNode()
    
    let backgroundEditTextNode = ASImageNode()
    
    let optionNode = OptionalChatInput()
    
    var collapseBtn = ASButtonNode()
    
    var sendBtn = ASButtonNode()
    
    var quickSendBtn = ASButtonNode()
    
    var delegate: ChatInputNodeDelegate?
    
    private var inputExpanded: Bool = false
    
    private var isTransition: Bool = false
    
    private var inputContentSizeChanged: Bool = false
    
    private var quickSendBtnEnable: Bool = true
    
    private var lastContentBeforCollapse: String?
    
    override init() {
        super.init()
        
        automaticallyManagesSubnodes = true
        style.flexGrow = 1.0
        backgroundColor = .white
        
        let backgroundColor = UIColor(rgb: 240, a: 255)
        let imageName = "background_input_chat"
        backgroundEditTextNode.image = resizableImage(UIImage(named: imageName), color: backgroundColor, imageName: imageName + backgroundColor.toHexString())
        
        let fontSize = CGFloat(15)
        editTextNode.attributedPlaceholderText = attributedString("Aa", fontSize: fontSize, isBold: false, foregroundColor: .darkGray)
        editTextNode.textView.font = UIFont.defaultFont(ofSize: fontSize)
        editTextNode.textContainerInset = UIEdgeInsets(top: 7, left: 20, bottom: 7, right: 12)
        editTextNode.scrollEnabled = false
        editTextNode.delegate = self
        
        let buttonPreferredSize = CGSize(width: 25, height: 25)
        collapseBtn.setBackgroundImage(UIImage(named: "collapseBtn"), for: .normal)
        collapseBtn.style.preferredSize = buttonPreferredSize
        
        sendBtn.setBackgroundImage(UIImage(named: "sendBtn"), for: .normal)
        sendBtn.style.preferredSize = buttonPreferredSize
        
        quickSendBtn.setBackgroundImage(UIImage(named: "likeFilledBtn"), for: .normal)
        quickSendBtn.style.preferredSize = buttonPreferredSize
        
    }
    
    override func didLoad() {
        super.didLoad()
        
        collapseBtn.addTarget(self, action: #selector(collapsePressed(_:)), forControlEvents: .touchUpInside)
        
        let inputTap = UITapGestureRecognizer(target: self, action: #selector(inputTapped(_:)))
        inputTap.delegate = self
        editTextNode.view.addGestureRecognizer(inputTap)
        
        sendBtn.addTarget(self, action: #selector(sendText(_:)), forControlEvents: .touchUpInside)
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(tapEventInView(_:)))
        view.addGestureRecognizer(gesture)
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let input = ASBackgroundLayoutSpec(child: editTextNode, background: backgroundEditTextNode)
        input.style.flexGrow = 1.0
        
        let leftNode = inputExpanded ? collapseBtn : optionNode
        let rightNode = quickSendBtnEnable ? quickSendBtn : sendBtn
        let contentSatck = ASStackLayoutSpec(direction: .horizontal, spacing: 10, justifyContent: .center, alignItems: .center, children: [leftNode, input, rightNode])
        
        let x = ASStackLayoutSpec(direction: .vertical, spacing: 0, justifyContent: .start, alignItems: .stretch, children: [contentSatck])
        
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10), child: x)
    }
    
    
    override func animateLayoutTransition(_ context: ASContextTransitioning) {
        let delta = context.finalFrame(for: editTextNode).height - editTextNode.frame.height
        var newFrame = view.frame
        newFrame.origin.y -= delta
        newFrame.size.height += delta
        
        func commonAnimate(){
            if quickSendBtnEnable{
                quickSendBtn.frame = context.finalFrame(for: quickSendBtn)
            }else{
                sendBtn.frame = context.finalFrame(for: sendBtn)
            }
            
            self.editTextNode.frame = context.finalFrame(for: self.editTextNode)
            self.backgroundEditTextNode.frame = context.finalFrame(for: self.backgroundEditTextNode)
            
            self.delegate?.chatInputNodeFrameDidChange(self, newFrame: newFrame, oldFrame: self.view.frame)
            
            self.view.frame = newFrame
        }
        
        let animateTransitionDuration = 0.2
        
        // Setup sendBtn before animating
        if quickSendBtnEnable{
            var quickSendBtnInitialFrame = context.initialFrame(for: quickSendBtn)
            if quickSendBtnInitialFrame.originInfinity(){
                quickSendBtnInitialFrame = context.finalFrame(for: quickSendBtn)
            }
            quickSendBtn.frame = quickSendBtnInitialFrame
            quickSendBtn.alpha = 1
            sendBtn.alpha = 0
        }else{
            var sendBtnInitialFrame = context.initialFrame(for: sendBtn)
            if sendBtnInitialFrame.originInfinity(){
                sendBtnInitialFrame = context.finalFrame(for: sendBtn)
            }
            sendBtn.frame = sendBtnInitialFrame
            quickSendBtn.alpha = 0
            sendBtn.alpha = 1
        }
        
        if inputExpanded{
            if isTransition{
                var optionFinalFrame = optionNode.frame
                optionFinalFrame.origin.x -= optionFinalFrame.width
                optionNode.alpha = 1
                
                self.collapseBtn.alpha = 0
                
                UIView.animate(withDuration: animateTransitionDuration, animations: {
                    self.optionNode.frame = optionFinalFrame
                    self.optionNode.alpha = 0
                    
                    self.collapseBtn.alpha = 1
                    self.collapseBtn.frame = context.finalFrame(for: self.collapseBtn)
                    
                    commonAnimate()
                    
                }) { (finished) in
                    context.completeTransition(finished)
                    self.isTransition = false
                }
            }else{
                UIView.animate(withDuration: animateTransitionDuration, animations: {
                    self.collapseBtn.frame = context.finalFrame(for: self.collapseBtn)
                    
                    commonAnimate()
                    
                }) { (finished) in
                    context.completeTransition(finished)
                }
            }
            
        }else{
            if isTransition{
                var optionIntialFrame = context.finalFrame(for: optionNode)
                optionIntialFrame.origin.x -= optionIntialFrame.width
                optionNode.frame = optionIntialFrame
                optionNode.alpha = 0
                
                collapseBtn.alpha = 1
                
                UIView.animate(withDuration: animateTransitionDuration, animations: {
                    self.optionNode.frame = context.finalFrame(for: self.optionNode)
                    self.optionNode.alpha = 1
                    
                    self.collapseBtn.alpha = 0
                    
                    commonAnimate()
                    
                }) { (finished) in
                    context.completeTransition(finished)
                    self.isTransition = false
                }
            }else{
                UIView.animate(withDuration: animateTransitionDuration, animations: {
                    self.optionNode.frame = context.finalFrame(for: self.optionNode)
                    
                    commonAnimate()
                    
                }) { (finished) in
                    context.completeTransition(finished)
                }
            }
        }
        
    }
}

extension ChatInputNode{
    private func resizableImage(_ i : UIImage?, color : UIColor, imageName: String) -> UIImage?{
        return StandardBubbleConfiguration.shared.resizableImage(i, color: color, imageName: imageName)
    }
    
}

extension ChatInputNode: ASEditableTextNodeDelegate{
    
    func editableTextNodeDidBeginEditing(_ editableTextNode: ASEditableTextNode) {
        expand()
    }
    
    func editableTextNodeDidFinishEditing(_ editableTextNode: ASEditableTextNode) {
        collapse()
    }
    
    func editableTextNodeDidUpdateText(_ editableTextNode: ASEditableTextNode) {
        textInputDidChanged(editableTextNode)
    }
    
}

extension ChatInputNode{
    
    func textInputDidChanged(_ editableTextNode: ASEditableTextNode) {
        var needToMeasure: Bool = false
        
        let lineHeight = editableTextNode.textView.font?.lineHeight ?? 1
        let size = CGSize(width: editableTextNode.frame.width, height: .infinity)
        let estimatedSize = editableTextNode.calculateSizeThatFits(size)
        let estimatedNumberLine = estimatedSize.height / lineHeight
        let currentNumberLine = editableTextNode.frame.height / lineHeight
        
        editableTextNode.scrollEnabled = estimatedNumberLine <= 6 ? false : true
        
        if abs(estimatedNumberLine - currentNumberLine) >= 1 && estimatedNumberLine <= 6{
            editableTextNode.style.preferredSize.height = estimatedSize.height
            
            inputContentSizeChanged = true
            needToMeasure = true
        }
        
        if editableTextNode.attributedText != nil && !editTextNode.attributedText!.string.isEmpty{
            if quickSendBtnEnable{
                quickSendBtnEnable = false
                needToMeasure = true
            }
        }else{
            if !quickSendBtnEnable{
                quickSendBtnEnable = true
                needToMeasure = true
            }
        }
        
        if !inputExpanded{
            guard var addText = editableTextNode.attributedText?.string else {
                return
            }
            
            if lastContentBeforCollapse != nil{
                addText.removeFirst(3)
                lastContentBeforCollapse! += addText
            }else{
                lastContentBeforCollapse = addText
            }
            
            expand()
        }else{
            if needToMeasure{
                transitionLayout(withAnimation: true, shouldMeasureAsync: true, measurementCompletion: nil)
            }
        }
    }
    
    func collapse(){
        if inputExpanded && !isTransition{
            inputExpanded = false
            isTransition = true
            
            lastContentBeforCollapse = editTextNode.attributedText?.string
            if lastContentBeforCollapse != nil{
                editTextNode.textView.text = "..."
            }
            
            let lineHeight = editTextNode.textView.font?.lineHeight ?? 1
            let size = CGSize(width: editTextNode.frame.width, height: .infinity)
            let estimatedSize = editTextNode.calculateSizeThatFits(size)
            let estimatedNumberLine = estimatedSize.height / lineHeight
            let currentNumberLine = editTextNode.frame.height / lineHeight
            
            editTextNode.scrollEnabled = estimatedNumberLine <= 6 ? false : true
            
            if abs(estimatedNumberLine - currentNumberLine) >= 1 && estimatedNumberLine <= 6{
                editTextNode.style.preferredSize.height = estimatedSize.height
            }
            
            transitionLayout(withAnimation: true, shouldMeasureAsync: true, measurementCompletion: nil)
        }
    }
    
    func expand(){
        if !inputExpanded && !isTransition{
            inputExpanded = true
            isTransition = true
            
            if lastContentBeforCollapse != nil{
                editTextNode.textView.text = lastContentBeforCollapse
            }
            
            let lineHeight = editTextNode.textView.font?.lineHeight ?? 1
            let size = CGSize(width: editTextNode.frame.width, height: .infinity)
            let estimatedSize = editTextNode.calculateSizeThatFits(size)
            let estimatedNumberLine = estimatedSize.height / lineHeight
            let currentNumberLine = editTextNode.frame.height / lineHeight
            
            editTextNode.scrollEnabled = estimatedNumberLine <= 6 ? false : true
            
            if abs(estimatedNumberLine - currentNumberLine) >= 1 && estimatedNumberLine <= 6{
                editTextNode.style.preferredSize.height = estimatedSize.height
            }
            
            transitionLayout(withAnimation: true, shouldMeasureAsync: true, measurementCompletion: nil)
        }
    }
    
    @objc func sendText(_ button: ASButtonNode){
        guard let text = inputExpanded ? editTextNode.attributedText?.string : lastContentBeforCollapse else {
            return
        }
        
        if !inputExpanded{
            lastContentBeforCollapse = nil
        }
        
        editTextNode.attributedText = nil
        delegate?.chatInputNode(self, sendText: text)
        
        textInputDidChanged(editTextNode)
    }
    
    
    @objc func collapsePressed(_ button: ASButtonNode){
        collapse()
    }
    
    @objc func inputTapped(_ gesture: UITapGestureRecognizer){
        expand()
    }
    
    @objc func tapEventInView(_ gesture: UITapGestureRecognizer){
        
    }
}

extension ChatInputNode: UIGestureRecognizerDelegate{
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
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
