//
//  MessageTitleCell.swift
//  E2EE
//
//  Created by Truong Nguyen on 12/14/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class MessageTitleCell: BaseMessageCell {
    
    var viewModel: MessageTitleViewModel
    
    var textNode = ASTextNode()
    
    init(viewModel: MessageTitleViewModel) {
        self.viewModel = viewModel
        super.init()
    }
    
    override func setup(){
        super.setup()
        
        automaticallyManagesSubnodes = true
        
        updateUI()
    }
    
    public override func updateUI(){
        ASPerformBlockOnBackgroundThread {
            self.viewModel.updateData(nil)
            self.textNode.attributedText = self.viewModel.title
            
            self.setNeedsLayout()
        }
    }
    
    override func getViewModel() -> MessageTitleViewModel {
        return viewModel
    }
   
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let stack = ASStackLayoutSpec(direction: .horizontal, spacing: 0, justifyContent: .center, alignItems: .center, children: [textNode])
        
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 25, left: 0, bottom: 15, right: 0), child: stack)
    }
    
}
