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
    
    
    public func setUIWithAfterItem(_ item : MessageViewModel?){
        if item == nil || !isGroupWith(item!){
            insets.top = CGFloat(5)
            insets.bottom = insets.top
            
            position = .none
            
            isShowAvatar = true
        }else{
            position = .first
            insets.top = CGFloat(0.5)
            insets.bottom = insets.top
        }
    }
    
    public func setUIWithPreviousItem(_ item : MessageViewModel){
        if isGroupWith(item){
            insets.top = CGFloat(0.5)
            
            if position == .none{
                position = .last
                
                isShowAvatar = true
            }else if position == .first{
                position = .middle
                
                isShowAvatar = false
            }
        }else{
            insets.top = CGFloat(5)
        }
    }
    
    private func isGroupWith(_ other: MessageViewModel) -> Bool{
        if model.sender.id != other.model.sender.id{
            return false
        }
        if fabs(model.time.sent - other.model.time.sent) <= MINUTE * 2{
            return true
        }
        
        return true
        
    }
}

