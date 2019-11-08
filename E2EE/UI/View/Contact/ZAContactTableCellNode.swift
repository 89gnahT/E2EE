//
//  ZAContactTableCellNode.swift
//  LearnTextureKit
//
//  Created by CPU12015 on 11/7/19.
//  Copyright © 2019 CPU12015. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class ZAContactTableCellNode: ASCellNode {
    var imageNode : ASNetworkImageNode?
    
    var titleNode : ASTextNode?
    var subTitleNode : ASTextNode?
    
    var icon1RightTitleNode : ASImageNode?
    var icon2RightTitleNode : ASImageNode?
    
    init(viewModel : ZAContactViewModel) {
        super.init()
        
        self.backgroundColor = UIColor.white
        self.automaticallyManagesSubnodes = true
        
        imageNode = ASNetworkImageNode()
        imageNode?.url = viewModel.avatarURL
        imageNode?.style.preferredSize = CGSize(width: 48, height: 48)
        imageNode?.imageModificationBlock = ASImageNodeRoundBorderModificationBlock(0, nil)
        
        
        // Setup ImageNode
        //        imageNode = node.avatar
        //        if (imageNode != nil){
        //            node.getAvatarImage { (image) in
        //                self.imageNode?.image = image
        //            }
        //
        //            imageNode?.style.preferredSize = CGSize(width: 48, height: 48)
        //            //imageNode?.imageModificationBlock = ASImageNodeRoundBorderModificationBlock(0, nil)
        //        }
        
        // Setup titleNode
        if viewModel.title != nil{
            titleNode = ASTextNode()
            titleNode!.truncationMode = .byTruncatingTail
            titleNode!.maximumNumberOfLines = 1
            
            let attributedText = NSAttributedString(string: viewModel.title!,
                                                    attributes: [NSAttributedString.Key.font : UIFont.defaultFont(ofSize: 16), NSAttributedString.Key.foregroundColor : UIColor.black])
            titleNode!.attributedText = attributedText
        }
        
        // Setup subTitleNode
        if viewModel.subTitle != nil{
            subTitleNode = ASTextNode()
            subTitleNode!.truncationMode = .byTruncatingTail
            subTitleNode!.maximumNumberOfLines = 1
            let attributedText = NSAttributedString(string: viewModel.subTitle!,
                                                    attributes: [NSAttributedString.Key.font : UIFont.boldDefaultFont(ofSize: 14), NSAttributedString.Key.foregroundColor : UIColor.black])
            subTitleNode!.attributedText = attributedText
        }
        
        var icon = viewModel.icon1RightTitle
        if icon != nil{
            icon1RightTitleNode = icon
            icon1RightTitleNode!.style.preferredSize = CGSize(width: 17, height: 17)
        }
        
        icon = viewModel.icon2RightTitle
        if icon != nil{
            icon2RightTitleNode = icon
            icon2RightTitleNode!.style.preferredSize = CGSize(width: 20, height: 20)
        }
    }
    
    //        ---------------------------------------------
    //        |      | Title    |
    //        |image | subTitle |   righttopSubContent(icon, icon)
    //        |      |          |
    //        |--------------------------------------------
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        let contentStack = ASStackLayoutSpec.horizontal()
        let subContenStack = ASStackLayoutSpec.horizontal()
        let leftSubContentStack = ASStackLayoutSpec.vertical()
        let rightSubContentStack = ASStackLayoutSpec.horizontal()
        
        // Setup Size
        contentStack.style.maxSize = constrainedSize.max
        contentStack.style.minSize = constrainedSize.min
        
        // ContentStack
        if imageNode == nil{
            contentStack.children = [subContenStack]
        }else{
            contentStack.children = [imageNode!, subContenStack]
        }
        contentStack.spacing = 10
        
        // SubContentStack
        subContenStack.style.flexGrow = 1.0
        subContenStack.spacing = 5
        subContenStack.justifyContent = .spaceBetween
        subContenStack.children = [leftSubContentStack, rightSubContentStack]
        
        // LeftSubContent
        let imageNodeWidth = imageNode?.style.preferredSize.width ?? 0
        var arrayOfLeftSubContent = Array<ASLayoutElement>()
        if titleNode != nil{
            let maxWidth = (contentStack.style.maxWidth.value - imageNodeWidth) * 0.6
            titleNode?.style.maxWidth = ASDimensionMake(maxWidth)
            
            arrayOfLeftSubContent.append(titleNode!)
        }
        if subTitleNode != nil{
            let maxWidth = (contentStack.style.maxWidth.value - imageNodeWidth) * 0.6
            subTitleNode?.style.maxWidth = ASDimensionMake(maxWidth)
            
            arrayOfLeftSubContent.append(subTitleNode!)
        }
        leftSubContentStack.children = arrayOfLeftSubContent
        leftSubContentStack.justifyContent = .center
        leftSubContentStack.spacing = 5
        
        // RightSubContent
        var arrayOfRightSubContent = Array<ASLayoutElement>()
        if icon1RightTitleNode != nil{
            arrayOfRightSubContent.append(icon1RightTitleNode!)
        }
        if icon2RightTitleNode != nil{
            arrayOfRightSubContent.append(icon2RightTitleNode!)
        }
        rightSubContentStack.children = arrayOfRightSubContent
        rightSubContentStack.spacing = 20
        rightSubContentStack.justifyContent = .center
        rightSubContentStack.verticalAlignment = .center
        
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 14), child: contentStack)
    }
    
    
}
