//
//  Bubble.swift
//  E2EE
//
//  Created by Truong Nguyen on 11/21/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import UIKit
import AsyncDisplayKit


open class Bubble : ASControlNode{
    public var image : UIImage?{
        didSet{
            imageNode.image = self.image
        }
    }
    
    private var imageNode : ASImageNode
    
    init(with image : UIImage? = nil) {
        imageNode = ASImageNode()
        
        super.init()
        
        self.automaticallyManagesSubnodes = true
        
        self.image = image
        imageNode.image = image
        
    }
    
    open override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return ASInsetLayoutSpec(insets: UIEdgeInsets.zero, child: imageNode)
    }
}

