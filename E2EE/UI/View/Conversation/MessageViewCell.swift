//
//  MessageViewCell.swift
//  E2EE
//
//  Created by Truong Nguyen on 11/19/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class MessageViewCell: ASCellNode {
    var avatarImageNode = ASNetworkImageNode()
    
    var timeNode = ASTextNode()
    
    var statusNode = ASTextNode()
    
    var contentNode = ASDisplayNode()
    
    override init() {
        super.init()
        self.automaticallyManagesSubnodes = true

        setup()
    }
    override class func draw(_ bounds: CGRect, withParameters parameters: Any?, isCancelled isCancelledBlock: () -> Bool, isRasterizing: Bool) {
        
    }
    
    private func setup(){
     
        avatarImageNode.style.preferredSize = CGSize(squareEdge: 40)
        avatarImageNode.image = UIImage(named: "default_avatar")
        
        
        contentNode.automaticallyManagesSubnodes = true
        contentNode.layoutSpecBlock = { (node : ASDisplayNode, constrainedSize : ASSizeRange) -> ASLayoutSpec in
           
            let content = ASTextNode()
            content.attributedText = atributedString("X", fontSize: 14, isBold: false, foregroundColor: UIColor(named: "normal_sub_title_in_cell_color")!)
            content.style.maxWidth = ASDimensionMake("300pt")
            
            
            
            let x = ContentNode(bubbleConfiguration: StandardBubbleConfiguration())
            let text = "Haha hehe"
           
            let boundingBox = text.boundingRect(with: CGSize.zero,
                                                options: .usesLineFragmentOrigin,
                                                attributes: [.font: UIFont.defaultFont(ofSize: 14)],
                                                context: nil)
            
            x.drawBubble(boundingBox)
           let contentStack = ASStackLayoutSpec.horizontal()
            contentStack.children = [content, x]
            contentStack.justifyContent = .spaceBetween
            
          // return ASBackgroundLayoutSpec(child: content, background: a)
            return ASInsetLayoutSpec(insets: UIEdgeInsets.zero, child: contentStack)
        }
        contentNode.setNeedsLayout()
        
        statusNode.attributedText = atributedString("Seen", fontSize: 12, isBold: false, foregroundColor: UIColor(named: "normal_sub_title_in_cell_color")!)
        timeNode.attributedText = atributedString("23h 44", fontSize: 12, isBold: false, foregroundColor: UIColor(named: "normal_sub_title_in_cell_color")!)
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let subContentStack = ASStackLayoutSpec(direction: .vertical,
                                  spacing: 5,
                                  justifyContent: .start, alignItems: .stretch,
                                  children: [self.timeNode, self.contentNode, self.statusNode])
        
        let contentStack = ASStackLayoutSpec(direction: .horizontal,
                                             spacing: 10,
                                             justifyContent: .start,
                                             alignItems: .stretch,
                                             children: [self.avatarImageNode, subContentStack])
        contentStack.style.maxSize = constrainedSize.max
        contentStack.style.minSize = constrainedSize.min
        
        return ASInsetLayoutSpec(insets: UIEdgeInsets.zero, child: contentStack)
    }
}
