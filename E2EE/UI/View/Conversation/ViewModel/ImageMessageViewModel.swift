//
//  ImageMessageViewModel.swift
//  E2EE
//
//  Created by CPU12015 on 11/28/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class ImageMessageViewModel: MessageViewModel {
    public var imageURLs = [URL]()
    
    init(model : ImageMessageModel) {
        super.init(model: model)
        
        updateData(nil)
    }
    
    override func updateData(_ completion : (() -> Void)?) {
        super.updateData(completion)
        
        for i in model.contents{
            let url = URL(string: i)
            if url != nil{
                imageURLs.append(url!)
            }
        }
        
    }
}
