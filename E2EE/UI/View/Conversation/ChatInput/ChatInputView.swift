//
//  ChatInput.swift
//  E2EE
//
//  Created by CPU12015 on 11/29/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class ChatInputView: ASDisplayNode {
    
    var cameraBtn = ASButtonNode()
    var collapaseBtn = ASButtonNode()
    var sendBtn = ASButtonNode()
    var imageBtn = ASButtonNode()
    var voiceBtn = ASButtonNode()
    var inputChat = ASEditableTextNode()
    var plusBtn = ASButtonNode()
    
    var leftGroup = ASDisplayNode()
    
    init(frame : CGRect) {
        super.init()
        
        self.automaticallyManagesSubnodes = true
        self.frame = frame
        
        setup()
    }
    
    private func setup(){
        backgroundColor = .white
        
        let btnSize = CGSize(width: 20, height: 20)
        cameraBtn.setBackgroundImage(UIImage(named: "cameraBtn"), for: .normal)
        cameraBtn.style.preferredSize = btnSize
        
        collapaseBtn.setBackgroundImage(UIImage(named: "collapaseBtn"), for: .normal)
        collapaseBtn.style.preferredSize = btnSize
        
        plusBtn.setBackgroundImage(UIImage(named: "plusBtn"), for: .normal)
        plusBtn.style.preferredSize = btnSize
        
        sendBtn.setBackgroundImage(UIImage(named: "sendBtn"), for: .normal)
        sendBtn.style.preferredSize = btnSize
        
        imageBtn.setBackgroundImage(UIImage(named: "imageBtn"), for: .normal)
        imageBtn.style.preferredSize = btnSize
        
        voiceBtn.setBackgroundImage(UIImage(named: "voiceBtn"), for: .normal)
        voiceBtn.style.preferredSize = btnSize
        
        let placeholderText = attributedString("Aa", fontSize: 20, isBold: false, foregroundColor: .darkGray)
        inputChat.attributedPlaceholderText = placeholderText
        inputChat.style.flexGrow = 1.0
        inputChat.style.flexShrink = 1.0
        inputChat.style.minWidth = ASDimension(unit: .points, value: UIScreen.main.bounds.width / 2)       
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let left = ASStackLayoutSpec(direction: .horizontal, spacing: 10, justifyContent: .start, alignItems: .stretch, children: [plusBtn, cameraBtn, imageBtn, voiceBtn])
        let box = ASStackLayoutSpec(direction: .horizontal, spacing: 10, justifyContent: .center, alignItems: .stretch, children: [left, inputChat, sendBtn])
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10), child: box)
    }
}

extension ChatInputView: ASEditableTextNodeDelegate{
    func editableTextNodeDidBeginEditing(_ editableTextNode: ASEditableTextNode) {
        
    }
    
    func editableTextNodeDidFinishEditing(_ editableTextNode: ASEditableTextNode) {
       
    }
}

