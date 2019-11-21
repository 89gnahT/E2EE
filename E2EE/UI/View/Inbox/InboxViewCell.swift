//
//  ConversationViewCell.swift
//  E2EE
//
//  Created by Truong Nguyen on 11/14/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class InboxViewCell: ASCellNode {
    var avatarImageNode = ASNetworkImageNode()
    
    var nameNode = ASTextNode()
    var timeNode = ASTextNode()
    var mutedIcon = ASImageNode()
    
    var messageContentNode = ASTextNode()
    var notifyUnreadNode = ASImageNode()
    
    private var viewModel : ChatInboxViewModel
    
    init(viewModel : ChatInboxViewModel) {
        self.viewModel = viewModel
        
        super.init()
        
        self.setup()
       
        updateDataCellNode()
    }
    
  
    private func setup(){
        self.backgroundColor = UIColor(named: "conversation_cell_color")
        self.automaticallyManagesSubnodes = true
        
        avatarImageNode.style.preferredSize = CGSize(squareEdge: 60)
        avatarImageNode.imageModificationBlock = ASImageNodeRoundBorderModificationBlock(0, nil)
        
        nameNode.truncationMode = .byTruncatingTail
        nameNode.maximumNumberOfLines = 1
        
        messageContentNode.truncationMode = .byTruncatingTail
        messageContentNode.maximumNumberOfLines = 1
        
        timeNode.style.maxWidth = ASDimensionMake("80pt")
        
        mutedIcon.style.preferredSize = CGSize(width: 12, height: 15)
        
        notifyUnreadNode.style.preferredSize = CGSize(squareEdge: 12)
        
    }
    
    public func reloadData(){
        viewModel.reloadData({
            ASPerformBlockOnMainThread {
                self.updateDataCellNode()
            }
        })
        
    }
    
    private func updateDataCellNode(){
        avatarImageNode.url = viewModel.avatarURL
        
        nameNode.attributedText = viewModel.nameConversation
        
        messageContentNode.attributedText = viewModel.messageContent
        
        timeNode.attributedText = viewModel.timeConversation
        
        mutedIcon.image = viewModel.muteIcon
        
        notifyUnreadNode.image = viewModel.notifyUnreadMessage
        
//        self.setNeedsLayout()
//        self.layoutIfNeeded()
    }
    
    
    //        ---------------------------------------------
    //        |      | Title    | righttopSubContent(icon, text)
    //        |image |-------------------------------------
    //        |      |  bottomSubContent(subTitle , icon)
    //        |--------------------------------------------
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        let rightSubTopContentStack = ASStackLayoutSpec(direction: .horizontal,
                                                        spacing: 10,
                                                        justifyContent: .start,
                                                        alignItems: .stretch,
                                                        children: [mutedIcon, timeNode])
        
        let topSubContentStack = ASStackLayoutSpec(direction: .horizontal,
                                                   spacing: 0,
                                                   justifyContent: .spaceBetween,
                                                   alignItems: .stretch,
                                                   children: [nameNode, rightSubTopContentStack])
        
        let bottomSubContentStack = ASStackLayoutSpec(direction: .horizontal,
                                                      spacing: 0,
                                                      justifyContent: .spaceBetween,
                                                      alignItems: .center,
                                                      children: [messageContentNode, notifyUnreadNode])
        
        let subContenStack = ASStackLayoutSpec(direction: .vertical,
                                               spacing: 5,
                                               justifyContent: .center,
                                               alignItems: .stretch,
                                               children: [topSubContentStack, bottomSubContentStack])
        subContenStack.style.flexGrow = 1.0
        
        let contentStack = ASStackLayoutSpec(direction: .horizontal,
                                             spacing: 10,
                                             justifyContent: .start,
                                             alignItems: .stretch,
                                             children: [avatarImageNode, subContenStack])
        contentStack.style.maxSize = constrainedSize.max
        contentStack.style.minSize = constrainedSize.min
        
        let width = contentStack.style.maxWidth.value - avatarImageNode.style.preferredSize.width
        nameNode.style.maxWidth = ASDimensionMake(width * 0.6)
        
        messageContentNode.style.maxWidth = ASDimensionMake(width * 0.8)
        
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12), child: contentStack)
    }
}
