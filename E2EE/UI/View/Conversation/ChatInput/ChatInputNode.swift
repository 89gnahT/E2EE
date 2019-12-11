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
    func CHatInputNodeFrameDidChange(_ chatInputNode: ChatInputNode, newFrame nf: CGRect, oldFrame of: CGRect)
}

class ChatInputNode: ASDisplayNode {
    
    let editTextNode = ASEditableTextNode()
    
    let backgroundEditTextNode = ASImageNode()
    
    let optionNode = OptionalChatInput()
    
    var collapseBtn = ASButtonNode()
    
    var sendBtn = ASButtonNode()
    
    var quickSendBtn = ASButtonNode()
    
    private var inputExpanded: Bool = false
    
    private var inputContentSizeChanged: Bool = false
    
    private var quickSendBtnEnable: Bool = true
    
    override init() {
        super.init()
        
        automaticallyManagesSubnodes = true
        style.flexGrow = 1.0
        backgroundColor = .black
        
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
        
        let inputTap = UIGestureRecognizer(target: self, action: #selector(inputTapped(_:)))
        inputTap.delegate = self
        editTextNode.textView.addGestureRecognizer(inputTap)
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let input = ASBackgroundLayoutSpec(child: editTextNode, background: backgroundEditTextNode)
        input.style.flexGrow = 1.0
        
        let leftNode = inputExpanded ? collapseBtn : optionNode
        let rightNode = quickSendBtnEnable ? quickSendBtn : sendBtn
        let contentSatck = ASStackLayoutSpec(direction: .horizontal, spacing: 10, justifyContent: .center, alignItems: .center, children: [leftNode, input, rightNode])
        
        let x = ASStackLayoutSpec(direction: .vertical, spacing: 0, justifyContent: .start, alignItems: .stretch, children: [contentSatck])
        
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 20), child: x)
    }
    
    
    override func animateLayoutTransition(_ context: ASContextTransitioning) {
        func setSendBtnInitialFrame(){
            quickSendBtn.alpha = quickSendBtnEnable ? 0 : 1
            sendBtn.alpha = quickSendBtnEnable ? 1 : 0
        }
        
        func setSendBtnFinalFrame(){
            quickSendBtn.alpha = quickSendBtnEnable ? 1 : 0
            sendBtn.alpha = quickSendBtnEnable ? 0 : 1
        }
        
        if inputContentSizeChanged{
            let delta = context.finalFrame(for: editTextNode).height - editTextNode.frame.height
            
            setSendBtnInitialFrame()
            
            UIView.animate(withDuration: 0.15, animations: {
                
                setSendBtnFinalFrame()
                
                self.collapseBtn.frame = context.finalFrame(for: self.collapseBtn)
                self.sendBtn.frame = context.finalFrame(for: self.sendBtn)
                
                self.editTextNode.frame = context.finalFrame(for: self.editTextNode)
                self.backgroundEditTextNode.frame = context.finalFrame(for: self.backgroundEditTextNode)
                
                self.view.frame.origin.y -= delta
                self.view.frame.size.height += delta
            }) { (finished) in
                context.completeTransition(finished)
                self.inputContentSizeChanged = false
            }
            
        }else{
            if inputExpanded{
                var optionFinalFrame = optionNode.frame
                optionFinalFrame.origin.x -= optionFinalFrame.width
                optionNode.alpha = 1
                
                self.collapseBtn.alpha = 0
                
                setSendBtnInitialFrame()
                
                UIView.animate(withDuration: 0.25, animations: {
                    setSendBtnFinalFrame()
                    
                    self.optionNode.frame = optionFinalFrame
                    self.optionNode.alpha = 0
                    
                    self.collapseBtn.alpha = 1
                    self.collapseBtn.frame = context.finalFrame(for: self.collapseBtn)
                    
                    self.editTextNode.frame = context.finalFrame(for: self.editTextNode)
                    self.backgroundEditTextNode.frame = context.finalFrame(for: self.backgroundEditTextNode)
                }) { (finished) in
                    context.completeTransition(finished)
                }
            }else{
                var optionIntialFrame = context.finalFrame(for: optionNode)
                optionIntialFrame.origin.x -= optionIntialFrame.width
                optionNode.frame = optionIntialFrame
                optionNode.alpha = 0
                
                collapseBtn.alpha = 1
                
                setSendBtnInitialFrame()
                
                UIView.animate(withDuration: 0.25, animations: {
                    setSendBtnFinalFrame()
                    
                    self.optionNode.frame = context.finalFrame(for: self.optionNode)
                    self.optionNode.alpha = 1
                    
                    self.collapseBtn.alpha = 0
                    
                    self.editTextNode.frame = context.finalFrame(for: self.editTextNode)
                    self.backgroundEditTextNode.frame = context.finalFrame(for: self.backgroundEditTextNode)
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
        
        if needToMeasure{
            transitionLayout(withAnimation: true, shouldMeasureAsync: true, measurementCompletion: nil)
        }
    }
    
}

extension ChatInputNode{
    func collapse(){
        if inputExpanded{
            inputExpanded = false
            
            transitionLayout(withAnimation: true, shouldMeasureAsync: true, measurementCompletion: nil)
        }
    }
    
    func expand(){
        if !inputExpanded{
            inputExpanded = true
            transitionLayout(withAnimation: true, shouldMeasureAsync: true, measurementCompletion: nil)
        }
    }
    
    @objc func collapsePressed(_ button: ASButtonNode){
        collapse()
    }
    
    @objc func inputTapped(_ gesture: UITapGestureRecognizer){
        
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
