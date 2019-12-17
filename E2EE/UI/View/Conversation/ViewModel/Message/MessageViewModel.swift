//
//  MessageViewModel.swift
//  E2EE
//
//  Created by CPU12015 on 11/27/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import UIKit

class MessageViewModel: BaseMessageViewModel {
    private(set) var model : MessageModel
    
    private var bubleConfiguration = StandardBubbleConfiguration.shared
    
    public var status : NSAttributedString = NSAttributedString()
    
    public var time : NSAttributedString = NSAttributedString()
    
    public var avatarURL : URL?
    
    public var isShowAvatar : Bool = true
    
    public var bubbleImage : UIImage?
    
    public var isIncommingMessage : Bool = false{
        didSet{
            if self.isIncommingMessage{
                insets.left = CGFloat(12)
                insets.right = CGFloat(0)
            }else{
                insets.left = CGFloat(0)
                insets.right = CGFloat(12)
            }
        }
    }
    
    public var isHighlight: Bool = false{
        didSet{
            updateData(nil)
        }
    }
    
    public var position : MessageCellPosition = .none
    
    public var insets : UIEdgeInsets = UIEdgeInsets.zero
    
    init(model : MessageModel) {
        self.model = model
    }
    
    public override func updateData(_ completion : (() -> Void)?){
        isIncommingMessage = !model.isMyMessage()
        avatarURL = URL(string: model.sender.avatarURL)
        
        time = attributedString(getTimeWithFormath(time: model.time.sent, format: "hh:mm dd/MM/yyyy"), fontSize: 13, isBold: false, foregroundColor: .darkGray)
        
        status = attributedString("Delivered", fontSize: 13, isBold: false, foregroundColor: .darkGray)
        
        bubbleImage = bubleConfiguration.getBubbleImage(isIncoming: isIncommingMessage, position: position, isHighlight: isHighlight)
    }
    
    // Don't care about afterItem
    public func setupPositionWith(previous preItem: MessageViewModel?){
        var tempPos : MessageCellPosition = .none
        isShowAvatar = true
        if preItem != nil && isGroupWith(preItem!){
            insets.top = CGFloat(2)
            tempPos = .last
        }else{
            insets.top = CGFloat(16)
            tempPos = .none
        }
        
        position = tempPos
    }
    
    // Don't care about previousItem
    public func setupPositionWith(after afterItem: MessageViewModel?){
        var tempPos : MessageCellPosition = position
        if afterItem != nil && isGroupWith(afterItem!){
            tempPos = tempPos == .none ? .first : .middle
            isShowAvatar = false
        }
        position = tempPos
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
            tempPos = (tempPos == .none) ? .first : .middle
            isShowAvatar = false
        }
        
        position = tempPos
    }
    
    func isGroupWith(_ other: BaseMessageViewModel) -> Bool{
        guard let item = other as? MessageViewModel else {
            return false
        }
        if model.sender.id != item.model.sender.id{
            return false
        }
        
        return isBlockMessageWith(other)
    }
    
    override func messageTime() -> TimeInterval {
        return model.time.sent
    }
}
