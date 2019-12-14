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
    override init() {
        super.init()
        
        setup()
    }
    
    override func setup(){
        
    }
    
    public override func updateUI(){
        
    }
    
    // MARK: - Should be override in subclass
    override func setupContent(){
        
    }
    
    override func getViewModel() -> MessageTitleViewModel {
        return MessageTitleViewModel()
    }
    
    public override func updateUIContent(){
        
    }
}
