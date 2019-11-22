//
//  TabBarViewController.swift
//  LearnTextureKit
//
//  Created by Truong Nguyen on 10/24/19.
//  Copyright © 2019 CPU12015. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class TabBarViewController: UIViewController, UITabBarControllerDelegate {
    let tabBarCtl = ASTabBarController()
    
    var chatListVC : InboxesViewController!
    var friendListVC : ContactViewController!
    var groupChatListVC : ChatScreenViewController!
    var logoView = ASDisplayNode()
    
    override func viewDidLoad() {
        
        self.createLogoView()
        
        self.view.addSubnode(logoView)
        DataManager.shared.batchFetchingAllData({[weak self] in
           
            self?.logoView.removeFromSupernode()
            
            self?.chatListVC = InboxesViewController()
            self?.friendListVC = ContactViewController()
           
            self?.tabBarCtl.viewControllers = [self?.chatListVC, self?.friendListVC ].map{
                UINavigationController.init(rootViewController: $0!)
            }
            
            UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont.defaultFont(ofSize: 10)], for: .normal)
            self?.tabBarCtl.tabBar.backgroundColor = UIColor(named: "tabbar_color")!
            self?.tabBarCtl.tabBar.barTintColor = UIColor(named: "tabbar_color")!
            self?.view.addSubview(self?.tabBarCtl.view ?? UIView())
            
            self?.navigationController?.setNavigationBarHidden(true, animated: false)
        }, callbackQueue: DispatchQueue.main)
        
    }
    
    private func createLogoView(){
        let imageNode = ASImageNode()
        imageNode.image = UIImage(named: "logo")!
        imageNode.style.maxWidth = ASDimensionMake(200)
        imageNode.style.maxHeight = ASDimensionMake(200)
        
        logoView.frame = self.view.frame
        logoView.backgroundColor = UIColor(named: "background_color")
        logoView.layoutSpecBlock = { (node : ASDisplayNode, constrainedSize : ASSizeRange) -> ASLayoutSpec in
            let contentStack = ASStackLayoutSpec.horizontal()
            contentStack.children = [imageNode]
            contentStack.justifyContent = .center
            contentStack.verticalAlignment = .center
            
            return ASInsetLayoutSpec(insets: UIEdgeInsets.zero, child: contentStack)
        }
        logoView.setNeedsLayout()
    }
}
