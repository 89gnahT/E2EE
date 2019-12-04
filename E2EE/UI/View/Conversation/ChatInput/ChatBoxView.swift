//
//  ChatBoxView.swift
//  E2EE
//
//  Created by Huynh Lam Phu Si on 11/8/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import Foundation
import UIKit
import AsyncDisplayKit

protocol ChatBoxDelegate {
    func sendButtonPressed(_ text: String)
}

class ChatBoxView: NSObject {
    let chatBox = ASDisplayNode()
    let emojiButton = ASButtonNode()
    let inputChat = ASEditableTextNode()
    let rightGroupButton = ASDisplayNode()
    
    let attachButton = ASButtonNode()
    let voiceButton = ASButtonNode()
    let imageButton = ASButtonNode()
    let sendButton = ASButtonNode()
    
    var delegate: ChatBoxDelegate?
    
    init(target: Any?, chatboxFrame: CGRect) {
        super.init()
        let edgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        self.rightGroupButton.automaticallyManagesSubnodes = true
        
        attachButton.setBackgroundImage(UIImage(imageLiteralResourceName: "plusBtn"), for: .normal)
        attachButton.style.preferredSize = CGSize(width: 30, height: 30)
        
        voiceButton.setBackgroundImage(UIImage(imageLiteralResourceName: "voiceBtn"), for: .normal)
        voiceButton.style.preferredSize = CGSize(width: 30, height: 30)
        
        imageButton.setBackgroundImage(UIImage(imageLiteralResourceName: "imageBtn"), for: .normal)
        imageButton.style.preferredSize = CGSize(width: 30, height: 30)
        
        sendButton.setBackgroundImage(UIImage(imageLiteralResourceName: "sendBtn"), for: .normal)
        sendButton.style.preferredSize = CGSize(width: 40, height: 40)
        sendButton.addTarget(self, action: #selector(tapSendButton(_:)), forControlEvents: .touchUpInside)
        
        self.chatBox.frame = chatboxFrame
        self.chatBox.backgroundColor = .white//UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        self.chatBox.automaticallyManagesSubnodes = true
        self.inputChat.delegate = self
        
        setEmojiButton()
        setTextBox()
        setRightGroupButtons()
        
        chatBox.layoutSpecBlock = { (node: ASDisplayNode, constrainedSize: ASSizeRange) -> ASLayoutSpec in
            let contentStack = ASStackLayoutSpec(direction: .horizontal, spacing: 0, justifyContent: .start, alignItems: .center, children: [self.emojiButton, self.inputChat, self.rightGroupButton])
            contentStack.style.flexShrink = 1.0
            contentStack.style.flexGrow = 1.0
            return ASInsetLayoutSpec(insets: edgeInsets, child: contentStack)
        }
        chatBox.setNeedsLayout()
    }
    
    func setEmojiButton() {
        emojiButton.style.preferredSize = CGSize(width: 30, height: 30)
        emojiButton.setBackgroundImage(UIImage(imageLiteralResourceName: "emojiBtn"), for: .normal)
    }
    
    func setTextBox() {
        let placeholderText = NSAttributedString(string: "Tin nhắn,@...", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20, weight: .thin), NSAttributedString.Key.foregroundColor: UIColor.brown])
        self.inputChat.attributedPlaceholderText = placeholderText
        self.inputChat.textView.font = UIFont.systemFont(ofSize: 20, weight: .light)
        self.inputChat.style.flexGrow = 1.0
        self.inputChat.style.flexShrink = 1.0
    }
    
    func setRightGroupButtons() {
        setNormalState()
    }
    
    func setNormalState() {
        rightGroupButton.layoutSpecBlock = {(node: ASDisplayNode, constrainedSize: ASSizeRange) -> ASLayoutSpec in
            let rightGroupLayout = ASStackLayoutSpec(direction: .horizontal, spacing: 5, justifyContent: .end, alignItems: .center, children: [self.attachButton, self.voiceButton, self.imageButton])
            rightGroupLayout.style.flexGrow = 1.0
            rightGroupLayout.style.flexShrink = 1.0
            return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10), child: rightGroupLayout)
        }
        rightGroupButton.setNeedsLayout()
    }
    
    func setTypingState() {
        rightGroupButton.layoutSpecBlock = {(node: ASDisplayNode, constrainedSize: ASSizeRange) -> ASLayoutSpec in
            let rightGroupLayout = ASStackLayoutSpec(direction: .horizontal, spacing: 5, justifyContent: .end, alignItems: .center, children: [self.sendButton])
            rightGroupLayout.style.flexGrow = 1.0
            rightGroupLayout.style.flexShrink = 1.0
            return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10), child: rightGroupLayout)
        }
        rightGroupButton.setNeedsLayout()
    }
    
    
    @objc func tapSendButton(_ sender: ASButtonNode) {
        
        guard let text = inputChat.attributedText?.string else {
            return
        }
        delegate?.sendButtonPressed(text)
        inputChat.attributedText = nil
    }
}

extension ChatBoxView: ASEditableTextNodeDelegate {
    func editableTextNodeDidBeginEditing(_ editableTextNode: ASEditableTextNode) {
        setTypingState()
    }
    
    func editableTextNodeDidFinishEditing(_ editableTextNode: ASEditableTextNode) {
        setNormalState()
    }
}

extension ChatBoxView {
    func keyboardWillChange(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)!.cgRectValue
            let messageBarHeight = chatBox.bounds.size.height
            let point = CGPoint(x: chatBox.bounds.origin.x, y: endFrame.origin.y - messageBarHeight)
            //let inset = UIEdgeInsets(top: 0, left: 0, bottom: endFrame.size.height, right: 0)
            UIView.animate(withDuration: 0.25) {
                self.chatBox.frame.origin = point
            }
        }
    }
}
