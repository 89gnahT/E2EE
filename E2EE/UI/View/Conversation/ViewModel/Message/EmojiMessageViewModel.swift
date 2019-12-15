//
//  EmojiMessageViewModel.swift
//  E2EE
//
//  Created by Truong Nguyen on 12/15/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import UIKit

class EmojiMessageViewModel: MessageViewModel {
    public var emojiContent : NSAttributedString = NSAttributedString()
    
    public var emojiModel : EmojiMessageModel{
        return model as! EmojiMessageModel
    }
    
    init(model : EmojiMessageModel) {
        super.init(model: model)
                
        updateData(nil)
    }
    
    override func updateData(_ completion : (() -> Void)?) {
        super.updateData(completion)
                
        emojiContent = attributedString(emojiModel.content, fontSize: 45, isBold: false, foregroundColor: .black)
        
    }
}
