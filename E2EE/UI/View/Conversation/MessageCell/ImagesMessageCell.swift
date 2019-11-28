//
//  ImagesMessageCell.swift
//  E2EE
//
//  Created by CPU12015 on 11/28/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class ImagesMessageCell: MessageCell {
    public var imageViewModel : ImageMessageViewModel{
        get{
            return viewModel as! ImageMessageViewModel
        }
    }
    
    private var maxWidthDimension : ASDimension
    private var maxWidthNodeDemension : ASDimension!
    
    private var numberOfRow : Int!
    private var numberNodePerRow : Int!
    private var listImageNode = [ASNetworkImageNode]()
    
    
    init(viewModel: ImageMessageViewModel) {
        maxWidthDimension = ASDimension(unit: .points, value: UIScreen.main.bounds.size.width * 0.65)
        
        super.init(viewModel: viewModel)
        
        updateUI()
    }
    
    override func updateUI() {
        super.updateUI()
        
        getImageNodeFromURLs(imageViewModel.imageURLs)
    }
    
    private func getImageNodeFromURLs(_ imageURLs : [URL]){
        // Calculate size
        if imageURLs.count < 4{
            numberNodePerRow = imageURLs.count
        }else if imageURLs.count == 4{
            numberNodePerRow = 2
        }else{
            numberNodePerRow = 3
        }
        
        numberOfRow = imageURLs.count / numberNodePerRow
        if imageURLs.count % numberNodePerRow != 0{
            numberOfRow += 1
        }
        
        maxWidthNodeDemension = ASDimension(unit: .points, value: maxWidthDimension.value / CGFloat(numberNodePerRow))
        
        listImageNode.removeAll()
        
        for i in imageURLs{
            let imageNode = ASNetworkImageNode()
            imageNode.url = i
            imageNode.contentMode = .scaleToFill
            imageNode.style.width = maxWidthNodeDemension
            imageNode.style.height = maxWidthNodeDemension
            imageNode.clipsToBounds = true
            imageNode.cornerRadius = 10
            
            listImageNode.append(imageNode)
        }
    }
    
    override func layoutSpecForMessageContent(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let spacingBetweenImageNode = CGFloat(2)
        var imagesContentArray = [ASLayoutElement]()
        for i in 0..<numberOfRow{
            var imagesContentArrayInRow = [ASLayoutElement]()
            
            for j in 0..<numberNodePerRow{
                let index = i * numberNodePerRow + j
                
                if index < listImageNode.count{
                    imagesContentArrayInRow.append(listImageNode[index])
                }else{
                    break
                }
            }
            
            let contentInRow = ASStackLayoutSpec(direction: .horizontal, spacing: spacingBetweenImageNode, justifyContent: justifyContent, alignItems: .stretch, children: imagesContentArrayInRow)
            contentInRow.style.maxWidth = maxWidthDimension
            contentInRow.style.maxHeight = maxWidthDimension
            
            imagesContentArray.append(contentInRow)
        }
        
        let content = ASStackLayoutSpec(direction: .vertical, spacing: spacingBetweenImageNode, justifyContent: justifyContent, alignItems: .stretch, children: imagesContentArray)
        content.style.maxWidth = maxWidthDimension
        content.style.maxHeight = maxWidthDimension
        
        return ASInsetLayoutSpec(insets: UIEdgeInsets.zero, child: content)
    }
}
