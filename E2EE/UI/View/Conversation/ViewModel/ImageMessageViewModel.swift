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
        
        reloabdData(nil)
    }
    
    override func reloabdData(_ completion : (() -> Void)?) {
        super.reloabdData(completion)
        
        for i in model.contents{
            let url = URL(string: i)
            if url != nil{
                imageURLs.append(url!)
            }
        }
        
    }
}