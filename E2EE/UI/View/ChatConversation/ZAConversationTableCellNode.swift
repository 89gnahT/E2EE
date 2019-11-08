//
//  ZANode.swift
//  LearnTextureKit
//
//  Created by CPU12015 on 10/23/19.
//  Copyright © 2019 CPU12015. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class ZAConversationTableCellNode: ASCellNode {
    var imageNode : ASNetworkImageNode?
    
    var titleNode : ASTextNode?
    var rightTitleNode : ASTextNode?
    var iconRightTitleNode : ASImageNode?
    
    var subTitleNode : ASTextNode?
    var iconRightSubTitleNode : ASTextNode?
    
    
    init(viewModel : ZAConversationViewModel) {
        super.init()
        
        self.backgroundColor = UIColor.white
        self.automaticallyManagesSubnodes = true
        
        imageNode = ASNetworkImageNode()
        imageNode?.url = viewModel.avatarURL!
        imageNode?.style.preferredSize = CGSize(width: 60, height: 60)
        imageNode?.imageModificationBlock = ASImageNodeRoundBorderModificationBlock(0, nil)
        
        
        // Setup ImageNode
//        imageNode = node.avatar
//        if (imageNode != nil){
//            node.getAvatarImage { (image) in
//                self.imageNode?.image = image
//            }
//
//            imageNode?.style.preferredSize = CGSize(width: 60, height: 60)
//            //imageNode?.imageModificationBlock = ASImageNodeRoundBorderModificationBlock(0, nil)
//        }
        
        let isReadMsg = viewModel.isReadMsg ?? false
        
        // Setup titleNode
        if viewModel.title != nil{
            titleNode = ASTextNode()
            titleNode!.truncationMode = .byTruncatingTail
            titleNode!.maximumNumberOfLines = 1
            
            var attributedText : NSAttributedString
            if isReadMsg{
                attributedText = NSAttributedString(string: viewModel.title!,
                                                    attributes: [NSAttributedString.Key.font : UIFont.defaultFont(ofSize: 16), NSAttributedString.Key.foregroundColor : UIColor.black])
            }else{
                attributedText = NSAttributedString(string: viewModel.title!,
                                                    attributes: [NSAttributedString.Key.font : UIFont.boldDefaultFont(ofSize: 16), NSAttributedString.Key.foregroundColor : UIColor.black])
            }
            titleNode!.attributedText = attributedText
        }
        
        // Setup subTitleNode
        if viewModel.subTitle != nil{
            subTitleNode = ASTextNode()
            subTitleNode!.truncationMode = .byTruncatingTail
            subTitleNode!.maximumNumberOfLines = 1
            var attributedText : NSAttributedString
            if isReadMsg{
                attributedText = NSAttributedString(string: viewModel.subTitle!,
                                                    attributes: [NSAttributedString.Key.font : UIFont.defaultFont(ofSize: 14), NSAttributedString.Key.foregroundColor : UIColor.darkGray])
            }else{
                attributedText = NSAttributedString(string: viewModel.subTitle!,
                                                    attributes: [NSAttributedString.Key.font : UIFont.boldDefaultFont(ofSize: 14), NSAttributedString.Key.foregroundColor : UIColor.black])
            }
            subTitleNode!.attributedText = attributedText
        }
        
        // Setup rightTitleNode
        if viewModel.rightTitle != nil{
            rightTitleNode = ASTextNode()
            rightTitleNode!.style.maxWidth = ASDimensionMake("80pt")
            var attributedText : NSAttributedString
            if isReadMsg{
                attributedText = NSAttributedString(string: viewModel.rightTitle!,
                                                    attributes: [NSAttributedString.Key.font : UIFont.defaultFont(ofSize: 12), NSAttributedString.Key.foregroundColor : UIColor.darkGray])
            }else{
                attributedText = NSAttributedString(string: viewModel.rightTitle!,
                                                    attributes: [NSAttributedString.Key.font : UIFont.boldDefaultFont(ofSize: 12), NSAttributedString.Key.foregroundColor : UIColor.black])
            }
            
            rightTitleNode!.attributedText = attributedText
        }
        
        let icon = viewModel.iconRightSubTitle
        if icon != nil{
            iconRightTitleNode = icon
            iconRightTitleNode!.style.preferredSize = CGSize(width: 12, height: 15)
        }
        
    }
    
    
    //        ---------------------------------------------
    //        |      | Title    | righttopSubContent(icon, text)
    //        |image |-------------------------------------
    //        |      |  bottomSubContent(subTitle , icon)
    //        |--------------------------------------------
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        let contentStack = ASStackLayoutSpec.horizontal()
        let subContenStack = ASStackLayoutSpec.vertical()
        let topSubContentStack = ASStackLayoutSpec.horizontal()
        let bottomSubContentStack = ASStackLayoutSpec.horizontal()
        let rightSubTopContentStack = ASStackLayoutSpec.horizontal()
        
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
        subContenStack.children = [topSubContentStack, bottomSubContentStack]
        subContenStack.spacing = 5
        subContenStack.justifyContent = .center
        
        let imageNodeWidth = imageNode?.style.preferredSize.width ?? 0
        // TopSubContent
        if titleNode == nil{
            topSubContentStack.children = [rightSubTopContentStack]
        }else{
            let maxWidth = (contentStack.style.maxWidth.value - imageNodeWidth) * 0.6
            titleNode?.style.maxWidth = ASDimensionMake(maxWidth)
            
            topSubContentStack.children = [titleNode!, rightSubTopContentStack]
        }
        topSubContentStack.justifyContent = .spaceBetween
        
        // RightSubTopContent
        var arrayOfRightSubTopContent = Array<ASLayoutElement>()
        if iconRightTitleNode != nil{
            arrayOfRightSubTopContent.append(iconRightTitleNode!)
        }
        if rightTitleNode != nil{
            arrayOfRightSubTopContent.append(rightTitleNode!)
        }
        rightSubTopContentStack.children = arrayOfRightSubTopContent
        rightSubTopContentStack.spacing = 5
        
        // BottomSubContent
        var arrayOfBottomSubContent = Array<ASLayoutElement>()
        if subTitleNode != nil{
            let maxWidth = (contentStack.style.maxWidth.value - imageNodeWidth) * 0.7
            subTitleNode?.style.maxWidth = ASDimensionMake(maxWidth)
            
            arrayOfBottomSubContent.append(subTitleNode!)
        }
        if iconRightSubTitleNode != nil{
            arrayOfBottomSubContent.append(iconRightSubTitleNode!)
        }
        bottomSubContentStack.children = arrayOfBottomSubContent
        
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12), child: contentStack)
    }
    
    
}
