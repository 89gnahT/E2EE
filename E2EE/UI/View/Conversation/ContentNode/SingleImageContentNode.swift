//
//  SingleImageContentNode.swift
//  E2EE
//
//  Created by Truong Nguyen on 11/27/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class SingleImageContentNode: ContentNode {
    open var imageNode = ASNetworkImageNode()
    
    open var imageURL : URL?{
        didSet{
            imageNode.url = self.imageURL
        }
    }
    
    open var bubbleImage : UIImage?{
        didSet{
            
        }
    }
    
    override init() {
        super.init()
      
        setup()
    }
    
    private func setup(){
        imageNode.style.maxSize = CGSize(width: 250, height: 300)
        
        imageNode.contentMode = .scaleAspectFill
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return ASInsetLayoutSpec(insets: UIEdgeInsets.zero, child: imageNode)
    }
}
