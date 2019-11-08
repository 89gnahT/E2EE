//
//  EditNavigationView.swift
//  LearnTextureKit
//
//  Created by CPU12015 on 11/6/19.
//  Copyright © 2019 CPU12015. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class EditNavigationBarAndTabBarView: NSObject {
    
    private let editNavigationBar = ASDisplayNode()
    private let editTabBar = ASDisplayNode()
    
    private let leftButtonInNavigationBar = ASButtonNode()
    private let rightButtonInNavigationBar = ASButtonNode()
    
    private let leftButtonInTabBar = ASButtonNode ()
    private let rightButtonInTabBar = ASButtonNode()
    
    private let fontSize : CGFloat = 15
    
    init(target : Any?,
         navigationViewFrame : CGRect,
         toolBarViewFrame : CGRect,
         leftTopButtonAction : Selector,
         rightTopButtonAction : Selector,
         leftBottomButtonAction : Selector,
         rightBottomButtonAction : Selector) {
        
        super.init()
        
        let edgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        // NavigationBar
        editNavigationBar.frame = navigationViewFrame
        editNavigationBar.backgroundColor = .white
        
        updateLeftButtonInEditNavigation()
        leftButtonInNavigationBar.addTarget(target,
                                             action: leftTopButtonAction,
                                             forControlEvents: .touchUpInside)
        
        updateRightButtonInEditNavigation(numberOfItems: 1)
        rightButtonInNavigationBar.addTarget(target,
                                              action: rightTopButtonAction,
                                              forControlEvents: .touchUpInside)
        
        editNavigationBar.automaticallyManagesSubnodes = true
        
        editNavigationBar.layoutSpecBlock = { (node : ASDisplayNode, constrainedSize : ASSizeRange) -> ASLayoutSpec in
            let contentStack = ASStackLayoutSpec.horizontal()
            contentStack.children = [self.leftButtonInNavigationBar, self.rightButtonInNavigationBar]
            contentStack.justifyContent = .spaceBetween
            
            return ASInsetLayoutSpec(insets: edgeInsets, child: contentStack)
        }
        editNavigationBar.setNeedsLayout()
        
        // TabBar
        editTabBar.frame = toolBarViewFrame
        editTabBar.backgroundColor = .white
        
        updateLeftButtonInEditTabBar()
        leftButtonInTabBar.addTarget(target,
                                         action: leftBottomButtonAction,
                                         forControlEvents: .touchUpInside)
        
        updateRightButtonInEditTabBar(numberOfItems: 1)
        rightButtonInTabBar.addTarget(target,
                                          action: rightBottomButtonAction,
                                          forControlEvents: .touchUpInside)
        
        editTabBar.automaticallyManagesSubnodes = true
        
        editTabBar.layoutSpecBlock = { (node : ASDisplayNode, constrainedSize : ASSizeRange) -> ASLayoutSpec in
            let contentStack = ASStackLayoutSpec.horizontal()
            contentStack.children = [self.leftButtonInTabBar, self.rightButtonInTabBar]
            contentStack.justifyContent = .spaceBetween
            
            return ASInsetLayoutSpec(insets: edgeInsets, child: contentStack)
        }
        editTabBar.setNeedsLayout()
    }
    
    func addSubNodeIntoNavigationBar(_ navigationBar : UINavigationBar, tabBar : UITabBar){
        navigationBar.addSubnode(editNavigationBar)
        tabBar.addSubnode(editTabBar)
    }
    
    func removeFromSupernode(){
        editNavigationBar.removeFromSupernode()
        editTabBar.removeFromSupernode()
    }
    
    func updateButtonInNavigationBarAndTabBar(numberOfItems : Int){
        updateRightButtonInEditTabBar(numberOfItems: numberOfItems)
        updateRightButtonInEditNavigation(numberOfItems: numberOfItems)
    }
    
    private func updateLeftButtonInEditNavigation(){
        let atributedString = atributed(string: "Huỷ", isBold: false, foregroundColor: UIColor.systemBlue)
        leftButtonInNavigationBar.setAttributedTitle(atributedString, for: .normal)
    }
    
    private func updateRightButtonInEditNavigation(numberOfItems : Int){
        var atributedString : NSAttributedString
        
        if numberOfItems > 0{
            let title = "Xoá (" + String(numberOfItems) + ")"
            atributedString = atributed(string: title, isBold: true, foregroundColor: UIColor.systemRed)
            rightButtonInNavigationBar.isEnabled = true
        }else{
            atributedString = atributed(string: "Xoá", isBold: true, foregroundColor: UIColor.darkGray)
            rightButtonInNavigationBar.isEnabled = false
        }
        
        rightButtonInNavigationBar.setAttributedTitle(atributedString, for: .normal)
    }
    
    private func updateLeftButtonInEditTabBar(){
        let atributedString = atributed(string: "Chọn tất cả", isBold: false, foregroundColor: UIColor.systemBlue)
        leftButtonInTabBar.setAttributedTitle(atributedString, for: .normal)
    }
    
    private func updateRightButtonInEditTabBar(numberOfItems : Int){
        var atributedString : NSAttributedString
        
        if numberOfItems > 0{
            let title = "Đánh dấu đã đọc (" + String(numberOfItems) + ")"
            atributedString = atributed(string: title, isBold: false, foregroundColor: UIColor.systemBlue)
            rightButtonInTabBar.isEnabled = true
        }else{
            atributedString = atributed(string: "Đánh dấu đã đọc", isBold: false, foregroundColor: UIColor.darkGray)
            rightButtonInTabBar.isEnabled = false
        }
        
        rightButtonInTabBar.setAttributedTitle(atributedString, for: .normal)
    }
    
    
    
    private func atributed(string : String, isBold : Bool, foregroundColor : UIColor) -> NSAttributedString{
        var font : UIFont
        if isBold{
            font = UIFont.boldDefaultFont(ofSize: fontSize)
        }else{
            font = UIFont.defaultFont(ofSize: fontSize)
        }
        return NSAttributedString(string: string,
                                  attributes: [NSAttributedString.Key.font: font,
                                               NSAttributedString.Key.foregroundColor : foregroundColor])
    }

}
