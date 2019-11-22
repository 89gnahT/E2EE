//
//  TextMessageViewModel.swift
//  E2EE
//
//  Created by CPU12015 on 11/22/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import UIKit
import AsyncDisplayKit

enum Position {
    case first
    case midle
    case last
    case none
}

class TextMessageViewModel {
    private(set) var model : TextMessageModel
    
    init(model : TextMessageModel) {
        self.model = model
    }
    
    public var textContent : NSAttributedString = NSAttributedString()
    
    public var status : NSAttributedString = NSAttributedString()
    
    public var time : NSAttributedString = NSAttributedString()
    
    public var avatarURL : URL?
    
    public var bubbleImage : UIImage?
    
    public var isIncommingMessage : Bool = false
    
    public var position : Position = .midle{
        didSet{
            let isIncommingMessage = model.sender.id != DataManager.shared.you.id
            if isIncommingMessage{
                switch self.position{
                case .first:
                    bubbleImage = bubleConfiguration.getFirstIncomingBubble()
                case .midle:
                    bubbleImage = bubleConfiguration.getMidIncomingBubble()
                case .last:
                    bubbleImage = bubleConfiguration.getLastIncomingBubble()
                default:
                    bubbleImage = bubleConfiguration.getDefaultInComingBubble()
                }
            }else{
                switch self.position {
                case .first:
                    bubbleImage = bubleConfiguration.getFirstOutgoingBubble()
                case .midle:
                    bubbleImage = bubleConfiguration.getMidOutgoingBubble()
                case .last:
                    bubbleImage = bubleConfiguration.getLastOutgoingBubble()
                default:
                    bubbleImage = bubleConfiguration.getDefaultOutgoingBubble()
                }
            }
        }
    }
    
    public func reloabdData(_ completion : (() -> Void)?){
        let contentMessage = model.content
        let timeMessage = model.time.sent
        let avatarURL = model.sender.avatarURL
        let isIncommingMessage = model.sender.id != DataManager.shared.you.id
        
        self.position = .none
        ASPerformBlockOnBackgroundThread {
            self.textContent = attributedString(contentMessage, fontSize: 15, isBold: false, foregroundColor: .white)
            
            self.avatarURL = URL(string: avatarURL)!
        
            self.isIncommingMessage = isIncommingMessage
            completion?()
        }
        
    }
    
    private var bubleConfiguration = StandardBubbleConfiguration()
}
