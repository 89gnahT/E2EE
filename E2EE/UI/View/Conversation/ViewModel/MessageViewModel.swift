//
//  MessageViewModel.swift
//  E2EE
//
//  Created by CPU12015 on 11/27/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import UIKit

protocol MessageViewModelDelegate {
    
}

class MessageViewModel: NSObject {
    private(set) var model : MessageModel
    
    init(model : MessageModel) {
        self.model = model
    }
    
    //public weak var delegate : MessageViewModelDelegate?
    
    private var bubleConfiguration = StandardBubbleConfiguration.shared
    
    public var status : NSAttributedString = NSAttributedString()
    
    public var time : NSAttributedString = NSAttributedString()
    
    public var avatarURL : URL?
    
    public var isShowAvatar : Bool = false
    
    public var bubbleImage : UIImage?
    
    public var isIncommingMessage : Bool = false{
        didSet{
            if self.isIncommingMessage{
                insets.left = CGFloat(12)
            }else{
                insets.right = CGFloat(12)
            }
        }
    }
    
    public var position : MessageCellPosition = .none{
        didSet{
            bubbleImage = bubleConfiguration.getBubbleImage(isIncoming: isIncommingMessage, position: position)
        }
    }
    
    public var insets : UIEdgeInsets = UIEdgeInsets.zero
    
    public func reloabdData(_ completion : (() -> Void)?){
        isIncommingMessage = !model.isMyMessage()
        avatarURL = URL(string: model.sender.avatarURL)
        
        time = attributedString(getTimeWithFormath(time: model.time.sent, format: "dd/MM/yyyy"), fontSize: 13, isBold: false, foregroundColor: .darkGray)
        
        status = attributedString("Delivered", fontSize: 13, isBold: false, foregroundColor: .darkGray)
        
        bubbleImage = bubleConfiguration.getBubbleImage(isIncoming: isIncommingMessage, position: position)
        
    }
    
    public func setupPositionWith(previous preItem: MessageViewModel?, andAfter afterItem: MessageViewModel?){
        var tempPos : MessageCellPosition = .none
        isShowAvatar = true
        if preItem != nil && isGroupWith(preItem!){
            insets.top = CGFloat(2)
            tempPos = .last
        }else{
            insets.top = CGFloat(16)
            tempPos = .none
        }
        
        if afterItem != nil && isGroupWith(afterItem!){
            tempPos = tempPos == .none ? .first : .middle
            isShowAvatar = false
        }
        
        position = tempPos
    }
    
    private func isGroupWith(_ other: MessageViewModel) -> Bool{
        if model.sender.id != other.model.sender.id{
            return false
        }
        if fabs(model.time.sent - other.model.time.sent) <= DAY{
            return true
        }
        
        return true
    }
}

