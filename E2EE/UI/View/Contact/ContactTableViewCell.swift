//
//  ZAContactTableCellNode.swift
//  LearnTextureKit
//
//  Created by CPU12015 on 11/7/19.
//  Copyright © 2019 CPU12015. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class ContactTableViewCell: ASCellNode {
    var avatarImageNode = ASNetworkImageNode()
    
    var userNameNode = ASTextNode()
    var detailNode = ASTextNode()
    
    var callIconNode = ASImageNode()
    var videoCallIconNode = ASImageNode()
    
    private var viewModel : ContactViewModel
    
    init(viewModel : ContactViewModel) {
        self.viewModel = viewModel
        
        super.init()
        
        self.setup()
        
        self.updateDataCellNode()
    }
    
    private func setup(){
        self.backgroundColor = UIColor(named: "contact_cell_color")
        self.automaticallyManagesSubnodes = true
        
        avatarImageNode.style.preferredSize = CGSize(squareEdge: 48)
        avatarImageNode.imageModificationBlock = ASImageNodeRoundBorderModificationBlock(0, nil)
        
        userNameNode.truncationMode = .byTruncatingTail
        userNameNode.maximumNumberOfLines = 1
        
        detailNode.truncationMode = .byTruncatingTail
        detailNode.maximumNumberOfLines = 1
        
        callIconNode.style.preferredSize = CGSize(squareEdge: 17)
        
        videoCallIconNode.style.preferredSize = CGSize(squareEdge: 20)
    }
    
    public func reloadData(){
        DispatchQueue.global().async {[weak self] in
            self?.viewModel.reloadData()
            
            self?.updateDataCellNode()
        }
    }
    
    private func updateDataCellNode(){
        avatarImageNode.url = viewModel.avatarURL
        
        userNameNode.attributedText = viewModel.userName
        
        detailNode.attributedText = viewModel.detail
        
        callIconNode.image = viewModel.callIcon
        
        videoCallIconNode.image = viewModel.videoCallIcon
    }
    
    //        ---------------------------------------------
    //        |      | Title    |
    //        |image | subTitle |   righttopSubContent(icon, icon)
    //        |      |          |
    //        |--------------------------------------------
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let leftSubContentStack = ASStackLayoutSpec(direction: .vertical,
                                                    spacing: 5,
                                                    justifyContent: .center,
                                                    alignItems: .stretch,
                                                    children: [userNameNode, detailNode])
        
        let rightSubContentStack = ASStackLayoutSpec(direction: .horizontal,
                                                     spacing: 20,
                                                     justifyContent: .center,
                                                     alignItems: .stretch,
                                                     children: [callIconNode, videoCallIconNode])
        rightSubContentStack.verticalAlignment = .center
        
        let subContenStack = ASStackLayoutSpec(direction: .horizontal,
                                               spacing: 5,
                                               justifyContent: .spaceBetween,
                                               alignItems: .stretch,
                                               children: [leftSubContentStack, rightSubContentStack])
        subContenStack.style.flexGrow = 1.0
        
        let contentStack = ASStackLayoutSpec(direction: .horizontal,
                                             spacing: 10,
                                             justifyContent: .start,
                                             alignItems: .stretch,
                                             children: [avatarImageNode, subContenStack])
        contentStack.style.maxSize = constrainedSize.max
        contentStack.style.minSize = constrainedSize.min
        
        let width = contentStack.style.maxWidth.value - avatarImageNode.style.preferredSize.width
        userNameNode.style.maxWidth = ASDimensionMake(width * 0.6)
        
        detailNode.style.maxWidth = ASDimensionMake(width * 0.7)
        
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 14), child: contentStack)
    }
    
    
}
