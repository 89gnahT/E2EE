//
//  BaseMessageCell.swift
//  E2EE
//
//  Created by Truong Nguyen on 12/14/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import UIKit
import AsyncDisplayKit

protocol BaseMessageCellDelegate {
    
}

class BaseMessageCell: ASCellNode {
    
    var delegate : BaseMessageCellDelegate?
    
    override init() {
        super.init()
        
        setup()
    }
    
    func setup(){
        
    }
    
    public func updateUI(){
        
    }
    
    // MARK: - Should be override in subclass
    func setupContent(){
        
    }
    
    func getViewModel() -> BaseMessageViewModel{
        assert(false, "getViewModel should be override in subClass")
        return BaseMessageViewModel()
    }
    
    public func updateUIContent(){
        
    }
}



