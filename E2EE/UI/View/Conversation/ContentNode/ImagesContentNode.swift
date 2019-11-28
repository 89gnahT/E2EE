//
//  ImagesContentNode.swift
//  E2EE
//
//  Created by CPU12015 on 11/28/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class ImagesContentNode: ContentNode {
    
    private var maxWidthDimension : ASDimension = ASDimension(unit: .points, value: 300)
    private var maxWidthNodeDemension : ASDimension = ASDimension(unit: .points, value: 300)
    private var maxHeightNodeDemension : ASDimension = ASDimension(unit: .points, value: 300)
    private var numberOfRow : Int = 0
    private var numberNodePerRow : Int = 3
    private var justifyContent : ASStackLayoutJustifyContent = .start
    
    private var imagesNode = [ASNetworkImageNode]()
    
    open var imageURLs = [URL](){
        didSet{
            calculateContentSize()
            getImageNodeFromURLs()
            setNeedsLayout()
        }
    }
    
    open var isIncomingMessage : Bool = true{
        didSet{
            if self.isIncomingMessage{
                justifyContent = .start
            }else{
                justifyContent = .end
            }
            
        }
    }
    
    override init() {
        super.init()
        
        //self.automaticallyManagesSubnodes = true
    }
    
    private func setup(){
       
    }
    
    private func calculateContentSize(){
        numberOfRow = imageURLs.count / numberNodePerRow
        if imageURLs.count % numberNodePerRow != 0{
            numberOfRow += 1
        }
        
        maxWidthNodeDemension = ASDimension(unit: .points, value: maxWidthDimension.value / CGFloat(numberOfRow))
        maxHeightNodeDemension = maxWidthNodeDemension
    }
    
    private func getImageNodeFromURLs(){
        imagesNode.removeAll()
        
        for i in imageURLs{
            let imageNode = ASNetworkImageNode()
            imageNode.url = i
            imageNode.contentMode = .scaleAspectFill
//            imageNode.style.maxWidth = maxWidthNodeDemension
//            imageNode.style.maxHeight = maxHeightNodeDemension
            imageNode.style.preferredSize = CGSize(width: 100, height: 100)
            
            imagesNode.append(imageNode)
            self.addSubnode(imageNode)
        }
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        var imagesContentArray = [ASLayoutElement]()
        for i in 0..<numberOfRow{
            var imagesContentArrayInRow = [ASLayoutElement]()
            
            for j in 0..<numberNodePerRow{
                let index = i * numberNodePerRow + j
                
                if index < imagesNode.count{
                    imagesContentArrayInRow.append(imagesNode[index])
                }else{
                    break
                }
            }
            
            let contentInRow = ASStackLayoutSpec(direction: .horizontal, spacing: 5, justifyContent: justifyContent, alignItems: .stretch, children: imagesContentArray)
            
            imagesContentArray.append(contentInRow)
        }
        
        let content = ASStackLayoutSpec(direction: .vertical, spacing: 5, justifyContent: justifyContent, alignItems: .stretch, children: imagesContentArray)
        content.style.width = maxWidthDimension
        content.style.height = maxWidthDimension
        return ASInsetLayoutSpec(insets: UIEdgeInsets.zero, child: content)
    }
}
