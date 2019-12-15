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
    
    func chatInputNode(_ chatInputNode: ChatInputNode, sendMessageWithContent content: String, type: MessageType)
}

class ChatInputNode: ASDisplayNode {
    
    let baseHeight = CGFloat(49)
    
    let editTextNode = ASEditableTextNode()
    
    let backgroundEditTextNode = ASImageNode()
    
    let optionNode = OptionalChatInput()
    
    var collapseBtn = ASButtonNode()
    
    var sendBtn = ASButtonNode()
    
    var quickSendBtn = ASButtonNode()
    
    var delegate: ChatInputNodeDelegate?
    
    var maximumLinesToDisplayLandscape: CGFloat = 3
    
    var maximumLinesToDisplayPortrait: CGFloat = 6
    
    private var maximumLinesToDisplay: CGFloat = 6
    
    private var contentInsets: UIEdgeInsets = .zero
    
    private var inputExpanded: Bool = false
    
    private var isTransition: Bool = false
    
    private var inputContentSizeChanged: Bool = false
    
    private var quickSendBtnEnable: Bool = true
    
    private var lastContentBeforCollapse: String?
    
    private var currentOrientation: UIDeviceOrientation = UIDevice.current.orientation
    
    private var keyboardAppeared: Bool = false
    
    private var currentKeyboardFrame: CGRect = CGRect.zero
    
    private var lastSafeAreaInsets: UIEdgeInsets = UIEdgeInsets.zero
    
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
        editTextNode.textView.textColor = .black
        editTextNode.textContainerInset = UIEdgeInsets(top: 8.5, left: 20, bottom: 8.5, right: 12)
        editTextNode.scrollEnabled = false
        editTextNode.delegate = self
        
        let buttonPreferredSize = CGSize(width: 25, height: 25)
        collapseBtn.setBackgroundImage(UIImage(named: "collapseBtn"), for: .normal)
        collapseBtn.style.preferredSize = buttonPreferredSize
        
        sendBtn.setBackgroundImage(UIImage(named: "sendBtn"), for: .normal)
        sendBtn.style.preferredSize = buttonPreferredSize
        
        quickSendBtn.setBackgroundImage(UIImage(named: "likeFilledBtn"), for: .normal)
        quickSendBtn.style.preferredSize = buttonPreferredSize
        
        maximumLinesToDisplay = UIDevice.current.orientation.isPortrait ? maximumLinesToDisplayPortrait : maximumLinesToDisplayLandscape
    }
    
    func registerNotifications(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardAppear(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDisappear(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    func unregisterNotifications(){
        NotificationCenter.default.removeObserver(self)
    }
    
    override func didLoad() {
        super.didLoad()
        
        collapseBtn.addTarget(self, action: #selector(collapsePressed(_:)), forControlEvents: .touchUpInside)
        
        let inputTap = UITapGestureRecognizer(target: self, action: #selector(inputTapped(_:)))
        inputTap.delegate = self
        editTextNode.view.addGestureRecognizer(inputTap)
        
        sendBtn.addTarget(self, action: #selector(sendText(_:)), forControlEvents: .touchUpInside)
        quickSendBtn.addTarget(self, action: #selector(sendEmoji(_:)), forControlEvents: .touchUpInside)
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(tapEventInView(_:)))
        view.addGestureRecognizer(gesture)
    }
    
    /**
     Follow: The system will automatically the methods in the following order:
     1. If keyboard disappeard: viewSafeAreaInsetsDidChange -> orientation changed
     2. If keyboard appeared: viewSafeAreaInsetsDidChange -> keyboard disappeared -> orientation changed -> keyboard appear
     
     With case 1, we handle it very easily
     Step 1: in safeAreaInsetsChange, We need to update height, position and contentInsets of the nodes (remove old value and update new value)
     Step 2: In orientationChange, we retains chatInputNode's height and change the remainning properties according to the new frame
     
     With case 2, we'll transform this case to case 1:
     We need handle Step 1 to 3 in safeAreaInsetsChange
     Step 1: First, we call keyboardDisappear with old safe area insets
     Step 2: Now, we do the same as Step 1 in case 1
     Step 3: We call keyboarAppear after update safe area insets
     Step 4: Do the same as step 2 in case 1
     */
    func safeAreaInsetsChange(_ newInsets: UIEdgeInsets) {
        // When safe area insets changed, we need to update the height, the position, the content insets of chatInputNode and tabeNode
        func handleSafeAreaInsetDidChangeWhenKeyboardDisappeared(){
            frame.origin.y += lastSafeAreaInsets.bottom - newInsets.bottom
            frame.size.height += -lastSafeAreaInsets.bottom + newInsets.bottom
            
            contentInsets = newInsets
            // We do not use top's content inset
            contentInsets.top = 0
        }
        
        if keyboardAppeared{
            handleFrameWhenKeyboardChanged(keyboardAppeard: false)
        }
        
        handleSafeAreaInsetDidChangeWhenKeyboardDisappeared()
        
        // Update new insets
        lastSafeAreaInsets = newInsets
        
        if keyboardAppeared{
            handleFrameWhenKeyboardChanged(keyboardAppeard: true)
        }
    }
    
    func deviceOrientationDidChange(_ viewFrame: CGRect){
        maximumLinesToDisplay = UIDevice.current.orientation.isPortrait ? maximumLinesToDisplayPortrait : maximumLinesToDisplayLandscape
        
        // Retains current chatInputNode's height and change the remainning properties according to the new frame
        let currentHeight = frame.height
        frame = CGRect(x: viewFrame.minX,
                       y: viewFrame.maxY - currentHeight,
                       width: viewFrame.width,
                       height: currentHeight)
        
        // Update content insets
        contentInsets = lastSafeAreaInsets
        // We do not use top's content inset
        contentInsets.top = 0
        
        textInputDidChanged(editTextNode)
    }
}

// MARK: ASEditableTextNodeDelegate
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

// MARK: UIGestureRecognizerDelegate
extension ChatInputNode: UIGestureRecognizerDelegate{
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

// MARK: Helper method
extension ChatInputNode{
    
    private func handleFrameWhenKeyboardChanged(keyboardAppeard appear: Bool){
        let height = currentKeyboardFrame.height - lastSafeAreaInsets.bottom
        let oldFrame = frame
        
        if appear{
            frame.origin.y -= height
            frame.size.height -= lastSafeAreaInsets.bottom
            
            contentInsets.bottom -= lastSafeAreaInsets.bottom
        }else{
            frame.origin.y += height
            frame.size.height += lastSafeAreaInsets.bottom
            
            contentInsets.bottom += lastSafeAreaInsets.bottom
        }
        
        delegate?.chatInputNodeFrameDidChange(self, newFrame: frame, oldFrame: oldFrame)
    }
    
    private func resizableImage(_ i : UIImage?, color : UIColor, imageName: String) -> UIImage?{
        return StandardBubbleConfiguration.shared.resizableImage(i, color: color, imageName: imageName)
    }
    
    func textInputDidChanged(_ editableTextNode: ASEditableTextNode) {
        var needToMeasure: Bool = false
        
        let lineHeight = editableTextNode.textView.font?.lineHeight ?? 1
        let size = CGSize(width: editableTextNode.frame.width, height: .infinity)
        let estimatedSize = editableTextNode.calculateSizeThatFits(size)
        let estimatedNumberLine = estimatedSize.height / lineHeight
        let currentNumberLine = editableTextNode.frame.height / lineHeight
        
        editableTextNode.scrollEnabled = estimatedNumberLine <= maximumLinesToDisplay ? false : true
        
        if abs(estimatedNumberLine - currentNumberLine) >= 1 && estimatedNumberLine <= maximumLinesToDisplay{
            editTextNode.style.preferredSize.height = estimatedSize.height
            
            inputContentSizeChanged = true
            needToMeasure = true
        }else if estimatedNumberLine > maximumLinesToDisplay{
            editTextNode.style.preferredSize.height = maximumLinesToDisplay * lineHeight
            
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
            
            editTextNode.scrollEnabled = estimatedNumberLine <= maximumLinesToDisplay ? false : true
            
            if abs(estimatedNumberLine - currentNumberLine) >= 1 && estimatedNumberLine <= maximumLinesToDisplay{
                editTextNode.style.preferredSize.height = estimatedSize.height
            }else if estimatedNumberLine > maximumLinesToDisplay{
                editTextNode.style.preferredSize.height = maximumLinesToDisplay * lineHeight
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
            
            editTextNode.scrollEnabled = estimatedNumberLine <= maximumLinesToDisplay ? false : true
            
            if abs(estimatedNumberLine - currentNumberLine) >= 1 && estimatedNumberLine <= maximumLinesToDisplay{
                editTextNode.style.preferredSize.height = estimatedSize.height
            }else if estimatedNumberLine > maximumLinesToDisplay{
                editTextNode.style.preferredSize.height = maximumLinesToDisplay * lineHeight
            }
            
            transitionLayout(withAnimation: true, shouldMeasureAsync: true, measurementCompletion: nil)
        }
    }
}

// MARK: Action in view
extension ChatInputNode{
    
    @objc func sendText(_ button: ASButtonNode){
        guard let text = inputExpanded ? editTextNode.attributedText?.string : lastContentBeforCollapse else {
            return
        }
        
        if !inputExpanded{
            lastContentBeforCollapse = nil
        }
        
        editTextNode.attributedText = nil
        delegate?.chatInputNode(self, sendMessageWithContent: text, type: .text)
        
        textInputDidChanged(editTextNode)
    }
    
    @objc func sendEmoji(_ button: ASButtonNode){
        if !inputExpanded{
            lastContentBeforCollapse = nil
        }
        
        editTextNode.attributedText = nil
        delegate?.chatInputNode(self, sendMessageWithContent: "👍", type: .emoji)
        
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
    
    @objc func keyboardAppear(notification: NSNotification) {
        if !keyboardAppeared, let keyboardValue: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            keyboardAppeared = true
            currentKeyboardFrame = keyboardValue.cgRectValue
            
            handleFrameWhenKeyboardChanged(keyboardAppeard: keyboardAppeared)
        }
    }
    
    @objc func keyboardDisappear(notification: NSNotification) {
        if keyboardAppeared{
            keyboardAppeared = false
            
            handleFrameWhenKeyboardChanged(keyboardAppeard: keyboardAppeared)
        }
    }
    
    @objc func keyboardWillChangeFrame(notification: NSNotification) {
        if keyboardAppeared{
            if let keyboardValue: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                
                handleFrameWhenKeyboardChanged(keyboardAppeard: false)
                
                currentKeyboardFrame = keyboardValue.cgRectValue
                
                handleFrameWhenKeyboardChanged(keyboardAppeard: true)
            }
        }
    }
}






// MARK: Layout and animation
extension ChatInputNode{
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let input = ASBackgroundLayoutSpec(child: editTextNode, background: backgroundEditTextNode)
        let space: CGFloat = UIDevice.current.orientation.isPortrait ? 20 : 10
        input.style.flexGrow = 1.0
        
        let leftNode = inputExpanded ? collapseBtn : optionNode
        let rightNode = quickSendBtnEnable ? quickSendBtn : sendBtn
        let stack = ASStackLayoutSpec(direction: .horizontal, spacing: space, justifyContent: .center, alignItems: .center, children: [leftNode, input, rightNode])
        
        let stackWrapper = ASStackLayoutSpec(direction: .vertical, spacing: 0, justifyContent: .start, alignItems: .stretch, children: [stack])
        
        let insetLayout = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 7, left: 10, bottom: 10, right: 10), child: stackWrapper)
        
        return ASInsetLayoutSpec(insets: contentInsets, child: insetLayout)
    }
    
    override func animateLayoutTransition(_ context: ASContextTransitioning) {
        let delta = context.finalFrame(for: editTextNode).height - editTextNode.frame.height
        let oldFrame = view.frame
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
            if delta != 0{
                self.delegate?.chatInputNodeFrameDidChange(self, newFrame: newFrame, oldFrame: oldFrame)
            }
            
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

class OptionalChatInput: ASDisplayNode{
    var cameraBtn = ASButtonNode()
    var imageBtn = ASButtonNode()
    var voiceBtn = ASButtonNode()
    var plusBtn = ASButtonNode()
    
    var spaceLandscape: CGFloat = 20
    
    var spacePortrait: CGFloat = 10
    
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
        voiceBtn.style.preferredSize = CGSize(width: 20, height: 25)
        
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        let space = UIDevice.current.orientation.isPortrait ? spacePortrait : spaceLandscape
        let contentStack = ASStackLayoutSpec(direction: .horizontal, spacing: space, justifyContent: .center, alignItems: .stretch, children: [self.plusBtn, self.cameraBtn, self.imageBtn, self.voiceBtn])
        
        return ASInsetLayoutSpec(insets: UIEdgeInsets.zero, child: contentStack)
    }
}
