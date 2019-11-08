//
//  EditNavigationView.swift
//  LearnTextureKit
//
//  Created by CPU12015 on 11/6/19.
//  Copyright © 2019 CPU12015. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class EditNavigationView: NSObject {
    
    let leftButtonInEditNavigation = ASButtonNode()
    let rightButtonInEditNavigation = ASButtonNode()
    let editNavigationView = ASDisplayNode()
    
    let leftButtonInEditTabBar = ASButtonNode ()
    let rightButtonInEditTabBar = ASButtonNode()
    let editTabBarView = ASDisplayNode()
    
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
        editNavigationView.frame = navigationViewFrame
        editNavigationView.backgroundColor = .white
        
        updateLeftButtonInEditNavigation()
        leftButtonInEditNavigation.addTarget(target, action: leftTopButtonAction, forControlEvents: .touchUpInside)
        
        updateRightButtonInEditNavigation(numberOfItems: 1)
        rightButtonInEditNavigation.addTarget(target, action: rightTopButtonAction, forControlEvents: .touchUpInside)
        
        editNavigationView.automaticallyManagesSubnodes = true
        
        editNavigationView.layoutSpecBlock = { (node : ASDisplayNode, constrainedSize : ASSizeRange) -> ASLayoutSpec in
            let contentStack = ASStackLayoutSpec.horizontal()
            contentStack.children = [self.leftButtonInEditNavigation, self.rightButtonInEditNavigation]
            contentStack.justifyContent = .spaceBetween
            
            return ASInsetLayoutSpec(insets: edgeInsets, child: contentStack)
        }
        editNavigationView.setNeedsLayout()
        
        // ToolBar
        editTabBarView.frame = toolBarViewFrame
        editTabBarView.backgroundColor = .white
        
        updateLeftButtonInEditToolBar()
        leftButtonInEditTabBar.addTarget(target, action: leftBottomButtonAction, forControlEvents: .touchUpInside)
        
        updateRightButtonInEditToolBar(numberOfItems: 1)
        rightButtonInEditTabBar.addTarget(target, action: rightBottomButtonAction, forControlEvents: .touchUpInside)
        
        editTabBarView.automaticallyManagesSubnodes = true
        
        editTabBarView.layoutSpecBlock = { (node : ASDisplayNode, constrainedSize : ASSizeRange) -> ASLayoutSpec in
            let contentStack = ASStackLayoutSpec.horizontal()
            contentStack.children = [self.leftButtonInEditTabBar, self.rightButtonInEditTabBar]
            contentStack.justifyContent = .spaceBetween
            
            return ASInsetLayoutSpec(insets: edgeInsets, child: contentStack)
        }
        editTabBarView.setNeedsLayout()
    }
    
    
    func updateLeftButtonInEditNavigation(){
        let atributedString = NSAttributedString(string: "Huỷ",
                                                 attributes: [NSAttributedString.Key.font: UIFont.defaultFont(ofSize: fontSize),
                                                              NSAttributedString.Key.foregroundColor : UIColor.systemBlue])
        leftButtonInEditNavigation.setAttributedTitle(atributedString, for: .normal)
    }
    
    func updateRightButtonInEditNavigation(numberOfItems : Int){
        var atributedString : NSAttributedString
        if numberOfItems > 0{
            let title = "Xoá (" + String(numberOfItems) + ")"
            atributedString = NSAttributedString(string: title,
                                                 attributes: [NSAttributedString.Key.font: UIFont.boldDefaultFont(ofSize: fontSize),
                                                              NSAttributedString.Key.foregroundColor : UIColor.systemRed])
            rightButtonInEditNavigation.isEnabled = true
        }else{
            atributedString = NSAttributedString(string: "Xoá",
                                                 attributes: [NSAttributedString.Key.font: UIFont.boldDefaultFont(ofSize: fontSize),
                                                              NSAttributedString.Key.foregroundColor : UIColor.darkGray])
            rightButtonInEditNavigation.isEnabled = false
        }
        
        rightButtonInEditNavigation.setAttributedTitle(atributedString, for: .normal)
    }
    
    func updateLeftButtonInEditToolBar(){
        let atributedString = NSAttributedString(string: "Chọn tất cả",
                                                 attributes: [NSAttributedString.Key.font: UIFont.defaultFont(ofSize: fontSize),
                                                              NSAttributedString.Key.foregroundColor : UIColor.systemBlue])
        leftButtonInEditTabBar.setAttributedTitle(atributedString, for: .normal)
    }
    
    func updateRightButtonInEditToolBar(numberOfItems : Int){
        var atributedString : NSAttributedString
        if numberOfItems > 0{
            let title = "Đánh dấu đã đọc (" + String(numberOfItems) + ")"
            atributedString = NSAttributedString(string: title,
                                                 attributes: [NSAttributedString.Key.font: UIFont.defaultFont(ofSize: fontSize),
                                                              NSAttributedString.Key.foregroundColor : UIColor.systemBlue])
            rightButtonInEditTabBar.isEnabled = true
        }else{
            atributedString = NSAttributedString(string: "Đánh dấu đã đọc",
                                                 attributes: [NSAttributedString.Key.font: UIFont.defaultFont(ofSize: fontSize),
                                                              NSAttributedString.Key.foregroundColor : UIColor.darkGray])
            rightButtonInEditTabBar.isEnabled = false
        }
        
        rightButtonInEditTabBar.setAttributedTitle(atributedString, for: .normal)
    }
    deinit {
        print("navigation bar denit")
    }
}
