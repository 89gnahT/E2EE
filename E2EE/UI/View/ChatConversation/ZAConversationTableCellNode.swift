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
    var subTitleDetailNode : ASTextNode?
    
    private var viewModel : ZAConversationViewModel!
    
    init(viewModel : ZAConversationViewModel) {
        super.init()
        
        self.backgroundColor = UIColor(named: "conversation_cell_color")
        self.automaticallyManagesSubnodes = true
        
        self.viewModel = viewModel
        
        self.updateDataCellNode()
    }
    

    
    private func setAtributedStringForASTextNode(_ textNode : ASTextNode,
                                                 string : String,
                                                 fontSize : CGFloat,
                                                 isHighLight : Bool,
                                                 highLightColor : UIColor,
                                                 normalColor : UIColor){
        func atributedString(_ string : String,
                             fontSize : CGFloat,
                             isBold : Bool,
                             foregroundColor : UIColor) -> NSAttributedString{
            var font : UIFont
            if isBold{
                font = UIFont.boldDefaultFont(ofSize: fontSize)
            }else{
                font = UIFont.defaultFont(ofSize: fontSize)
            }
            
            return NSAttributedString(string: string,
                                      attributes: [NSAttributedString.Key.font : font, NSAttributedString.Key.foregroundColor : foregroundColor])
        }
        
        var attributedText : NSAttributedString
        
        if isHighLight{
            attributedText = atributedString(string, fontSize: fontSize, isBold: true, foregroundColor: highLightColor)
        }else{
            attributedText = atributedString(string, fontSize: fontSize, isBold: false, foregroundColor: normalColor)
        }
        textNode.attributedText = attributedText
    }
    
    public func reloadData(){
        DispatchQueue.global().async {
            self.updateDataCellNode()
        }
    }
    
    public func updateDataCellNode(){
        if viewModel == nil{
            return
        }
    
        let avatarURL = viewModel.avatarURL
        if avatarURL != nil{
            if imageNode == nil{
                imageNode = ASNetworkImageNode()
                imageNode?.style.preferredSize = CGSize(squareEdge: 60)
                imageNode?.imageModificationBlock = ASImageNodeRoundBorderModificationBlock(0, nil)
            }
            if imageNode?.url != avatarURL{
                imageNode?.url = avatarURL
            }
        }else{
            imageNode = nil
        }
        
        let isReadMsg = viewModel.isReadMsg ?? false
        
        // Setup titleNode
        if viewModel.title != nil{
            if titleNode == nil{
                titleNode = ASTextNode()
                titleNode!.truncationMode = .byTruncatingTail
                titleNode!.maximumNumberOfLines = 1
            }
            setAtributedStringForASTextNode(titleNode!,
                                            string: viewModel.title!,
                                            fontSize: 16,
                                            isHighLight: !isReadMsg,
                                            highLightColor: UIColor(named: "title_in_cell_color")!,
                                            normalColor: UIColor(named: "title_in_cell_color")!)
        }else{
            titleNode = nil
        }
        
        // Setup subTitleNode
        if viewModel.subTitle != nil{
            if subTitleNode == nil{
                subTitleNode = ASTextNode()
                subTitleNode!.truncationMode = .byTruncatingTail
                subTitleNode!.maximumNumberOfLines = 1
            }
            setAtributedStringForASTextNode(subTitleNode!,
                                            string: viewModel.subTitle!,
                                            fontSize: 14,
                                            isHighLight: !isReadMsg,
                                            highLightColor: UIColor(named: "highlight_sub_title_in_cell_color")!,
                                            normalColor: UIColor(named: "normal_sub_title_in_cell_color")!)

        }else{
            subTitleNode = nil
        }
        
        if viewModel.subTitleDetail != nil{
            if subTitleDetailNode == nil{
                subTitleDetailNode = ASTextNode()
                subTitleDetailNode?.backgroundColor = .systemRed
                subTitleDetailNode?.cornerRadius = 7
                subTitleDetailNode?.clipsToBounds = true
            }
            setAtributedStringForASTextNode(subTitleDetailNode!,
                                            string: viewModel.subTitleDetail!,
                                            fontSize: 12,
                                            isHighLight: !isReadMsg,
                                            highLightColor: .white,
                                            normalColor: .white)
            
        }else{
            subTitleDetailNode = nil
        }
        
        
        // Setup rightTitleNode
        if viewModel.rightTitle != nil{
            if rightTitleNode == nil{
                rightTitleNode = ASTextNode()
                rightTitleNode!.style.maxWidth = ASDimensionMake("80pt")
            }
            setAtributedStringForASTextNode(rightTitleNode!,
                                            string: viewModel.rightTitle!,
                                            fontSize: 12,
                                            isHighLight: !isReadMsg,
                                            highLightColor: UIColor(named: "highlight_sub_title_in_cell_color")!,
                                            normalColor: UIColor(named: "normal_sub_title_in_cell_color")!)
        }else{
            rightTitleNode = nil
        }
        
        let icon = viewModel.iconRightSubTitle
        if icon != nil{
            iconRightTitleNode = icon
            iconRightTitleNode!.style.preferredSize = CGSize(width: 12, height: 15)
        }else{
            iconRightTitleNode = nil
        }
        
        self.setNeedsLayout()
        self.layoutIfNeeded()
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
        rightSubTopContentStack.spacing = 10
        
        // BottomSubContent
        var arrayOfBottomSubContent = Array<ASLayoutElement>()
        if subTitleNode != nil{
            let maxWidth = (contentStack.style.maxWidth.value - imageNodeWidth) * 0.8
            subTitleNode?.style.maxWidth = ASDimensionMake(maxWidth)
            
            arrayOfBottomSubContent.append(subTitleNode!)
        }
        if subTitleDetailNode != nil{
            arrayOfBottomSubContent.append(subTitleDetailNode!)
        }
        bottomSubContentStack.children = arrayOfBottomSubContent
        bottomSubContentStack.justifyContent = .spaceBetween
        
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12), child: contentStack)
    }
}
