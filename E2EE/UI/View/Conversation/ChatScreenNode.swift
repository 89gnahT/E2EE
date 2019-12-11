//
//  ChatScreenNode.swift
//  E2EE
//
//  Created by Truong Nguyen on 12/11/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class ChatScreenNode: ASDisplayNode {
    var tableNode: ConversationTableNode
    var chatInputNode: ChatInputView
    
    init(tableNode: ConversationTableNode, chatInputNode: ChatInputView) {
        self.tableNode = tableNode
        self.chatInputNode = chatInputNode
        
        super.init()
        
        automaticallyManagesSubnodes = true
    }
    
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return ASStackLayoutSpec(direction: .vertical, spacing: 0, justifyContent: .start, alignItems: .stretch, children: [tableNode, chatInputNode])
    }
}
