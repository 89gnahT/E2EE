//
//  TextContentNode.swift
//  E2EE
//
//  Created by CPU12015 on 12/6/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class TextContentNode: ContentNode {

     public var textViewModel : TextMessageViewModel
     
     open var textMessageNode = ASTextNode()

     open var messageInsets = UIEdgeInsets(top: 9, left: 12, bottom: 9, right: 12) {
         didSet {
             setNeedsLayout()
         }
     }
     
     open var bubble = Bubble()
     
     init(viewModel: TextMessageViewModel, tapAction: Selector, longPressAction: Selector) {
         textViewModel = viewModel
    
        super.init(tapAction: tapAction, longPressAction: longPressAction)
     }
     
     override func setup() {
         super.setup()
         
         textMessageNode.maximumNumberOfLines = 50
         textMessageNode.style.maxWidth = ASDimension(unit: .points, value: UIScreen.main.bounds.size.width * 0.6)
       
         updateUI()
     }
     
     override func didLoad() {
         super.didLoad()
         
         let longPressGesture = UILongPressGestureRecognizer(target: self, action: longPressAction)
         longPressGesture.minimumPressDuration = 0.7
         longPressGesture.delegate = self

         bubble.view.addGestureRecognizer(longPressGesture)
        bubble.addTarget(self, action: tapAction, forControlEvents: .touchUpInside)
     }
     
     override func updateUI() {
         super.updateUI()
         
         textMessageNode.attributedText = textViewModel.textContent
         bubble.image = textViewModel.bubbleImage
     }
     
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return ASBackgroundLayoutSpec(child: ASInsetLayoutSpec(insets: messageInsets, child: textMessageNode),
        background: bubble)
    }
}
