//
//  TextMessageViewModel.swift
//  E2EE
//
//  Created by CPU12015 on 11/22/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import UIKit
import AsyncDisplayKit


class TextMessageViewModel: MessageViewModel {
    
    private var textColor : UIColor!
    
    public var textContent : NSAttributedString = NSAttributedString()
    
    public var textModel : TextMessageModel{
        return model as! TextMessageModel
    }
    
    init(model : TextMessageModel) {
        super.init(model: model)
                
        reloabdData(nil)
    }
    
    override func reloabdData(_ completion : (() -> Void)?) {
        super.reloabdData(completion)
        
        textColor = isIncommingMessage ? .black : .white
        textContent = attributedString(textModel.content, fontSize: 17, isBold: false, foregroundColor: textColor)
        
    }
    
}
