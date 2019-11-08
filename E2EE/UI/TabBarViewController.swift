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
    
    let chatListVC = ConversationsViewController()
    let friendListVC = ContactViewController()
    let groupChatListVC = ASViewController<ASTableNode>()
    
    override func viewDidLoad() {
        
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
        
        tabBarCtl.tabBar.backgroundColor = .white
        self.view.addSubview(tabBarCtl.view)
        
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    
    
    
    //    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
    //        switch item.title {
    //        case chatListVC.title:
    //            print("Chat tab")
    //
    //            let button1 = UIBarButtonItem(title: "Button1", style: .plain, target: self, action: #selector(testFunc))
    //            navigationController?.navigationBar.backgroundColor = UIColor.green
    //
    //            navigationController?.navigationItem.rightBarButtonItem = button1
    //            moreNavigationController.navigationBar.backgroundColor = UIColor.green
    //        //navigationItem.rightBarButtonItems = [button1]
    //        case friendListVC.title:
    //            print("Friend tab")
    //        case groupChatListVC.title:
    //            print("Group chat tab")
    //        default:
    //            print("Other")
    //        }
    //
    //    }
    
}
