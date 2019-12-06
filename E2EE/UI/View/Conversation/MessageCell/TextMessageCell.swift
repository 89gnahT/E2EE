//
//  TextMessageCell.swift
//  E2EE
//
//  Created by CPU12015 on 11/27/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class TextMessageCell: MessageCell {

    public var contentNode: ContentNode!
    
    public var textViewModel : TextMessageViewModel
    
    open var textMessageNode = ASTextNode()

    open var messageInsets = UIEdgeInsets(top: 9, left: 12, bottom: 9, right: 12) {
        didSet {
            setNeedsLayout()
        }
    }
    
    open var bubble = Bubble()
    
    init(viewModel: TextMessageViewModel, rootViewController: ChatScreenViewController?) {
        textViewModel = viewModel
   
        super.init()
        
        self.rootViewController = rootViewController
    }
    
//    override func getContentNode() -> ContentNode {
//        return ContentNode()
//    }
    
    override func setup() {
        super.setup()
        
        textMessageNode.maximumNumberOfLines = 50
        textMessageNode.style.maxWidth = ASDimension(unit: .points, value: UIScreen.main.bounds.size.width * 0.6)
        
        bubble.addTarget(self, action: #selector(contentClicked(_:)), forControlEvents: .touchUpInside)
        
        updateUI()
    }
    
    override func didLoad() {
        super.didLoad()
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        longPressGesture.minimumPressDuration = 0.7
        longPressGesture.delegate = self
        
        bubble.view.addGestureRecognizer(longPressGesture)
    }
    
    override func getViewModel() -> MessageViewModel {
        return textViewModel
    }
    
    override func updateUI() {
        super.updateUI()
        
        textMessageNode.attributedText = textViewModel.textContent
        bubble.image = textViewModel.bubbleImage
    }
    
    override func layoutSpecForMessageContent(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return ASBackgroundLayoutSpec(child: ASInsetLayoutSpec(insets: messageInsets, child: textMessageNode),
                                      background: bubble)
    }
   
    override func contentClicked(_ contentNode: ASDisplayNode) {
        super.contentClicked(contentNode)
        
        hideDetails = !hideDetails
    }
}
