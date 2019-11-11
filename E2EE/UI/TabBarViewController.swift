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
    
    var chatListVC : ConversationsViewController!
    var friendListVC : ContactViewController!
    var groupChatListVC : ASViewController<ASTableNode>!
    
    override func viewDidLoad() {
        chatListVC = ConversationsViewController()
        friendListVC = ContactViewController()
        groupChatListVC = ASViewController<ASTableNode>()
        
        chatListVC.title = "Tin nhắn"
        chatListVC.tabBarItem.image = UIImage(named: "message_icon")
        chatListVC.tabBarItem.selectedImage = UIImage(named: "message_selected_icon")
        
        friendListVC.title = "Danh bạ"
        friendListVC.tabBarItem.image = UIImage(named: "contact_icon")
        friendListVC.tabBarItem.selectedImage = UIImage(named: "contact_selected_icon")
        
        groupChatListVC.title = "Nhóm"
        groupChatListVC.tabBarItem.image = UIImage(named: "group_icon")
        groupChatListVC.tabBarItem.selectedImage = UIImage(named: "group_selected_icon")
        
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont.defaultFont(ofSize: 10)], for: .normal)
        
        tabBarCtl.delegate = self
        tabBarCtl.viewControllers = [chatListVC, friendListVC, groupChatListVC].map{
            UINavigationController.init(rootViewController: $0)
        }
        
        tabBarCtl.tabBar.backgroundColor = UIColor(named: "tabbar_color")!
        tabBarCtl.tabBar.barTintColor = UIColor(named: "tabbar_color")!
        self.view.addSubview(tabBarCtl.view)

        navigationController?.setNavigationBarHidden(true, animated: true)
    }
}
