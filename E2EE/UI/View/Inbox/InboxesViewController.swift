//
//  ListConversationViewController.swift
//  LearnTextureKit
//
//  Created by CPU12015 on 11/1/19.
//  Copyright © 2019 CPU12015. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class InboxesViewController: ASViewController<ASDisplayNode>{
    
    let tableNode = InboxsTableNode()
    
    var viewModels : [ChatInboxViewModel] = []
    
    var listSelectedItemsInEdittingMode : [ChatInboxViewModel] = []
    
    var isEdittingMode : Bool = false{
        didSet{
            tableNode.isInEdittingMode = self.isEdittingMode
        }
    }
    
    lazy var editView : EditNavigationBarAndTabBarView = {
        let navigationViewFrame = (navigationController?.navigationBar.bounds)!
        let toolBarViewFrame = (tabBarController?.tabBar.bounds)!
        
        return EditNavigationBarAndTabBarView(target: self,
                                              navigationViewFrame: navigationViewFrame,
                                              toolBarViewFrame: toolBarViewFrame,
                                              leftTopButtonAction: #selector(leftTopButtonAction(button:)),
                                              rightTopButtonAction: #selector(rightTopButtonAction(button:)),
                                              leftBottomButtonAction: #selector(leftBottomButtonAction(button:)),
                                              rightBottomButtonAction: #selector(rightBottomButtonAction(button:)))
    }()
    
    var numberOfNewMsg : Int = 0{
        didSet{
            var badgeValue : String?
            
            let maxNumberOfUnreadMsg = 99
            if self.numberOfNewMsg > maxNumberOfUnreadMsg{
                badgeValue = String(maxNumberOfUnreadMsg) + "+"
            }else if self.numberOfNewMsg > 0{
                badgeValue = String(self.numberOfNewMsg)
            }else{
                badgeValue = nil
            }
            
            DispatchQueue.main.async {
                self.tabBarItem.badgeValue = badgeValue
            }
        }
    }
    
    init() {
        super.init(node: tableNode)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    func setup(){
        title = "Tin nhắn"
        tabBarItem.image = UIImage(named: "message_icon")
        tabBarItem.selectedImage = UIImage(named: "message_selected_icon")
        
        tableNode.dataSource = self
        tableNode.delegate = self
        tableNode.setNeedsLayout()
        tableNode.layoutIfNeeded()
        
        DataManager.shared.addObserver(for: .conversationChanged, target: self, callBackQueue: DispatchQueue.main)
        
        // Fetch data
        DataManager.shared.fetchConversationModels ( { (conversations) in
            
            var numberOfUnreadMsg = 0
            for c in conversations{
                self.viewModels.append(ChatInboxViewModel(model: c as! ChatInboxModel))
                
                // Count how many unread message
                numberOfUnreadMsg += c.isUnread() ? 1 : 0
            }
            
            self.numberOfNewMsg = numberOfUnreadMsg
            
            DispatchQueue.main.async {
                self.tableNode.reloadData()
            }
        }, callbackQueue: nil)
    }
    
    func markItemsAsRead(items : [ChatInboxViewModel]){
        for item in items {
            DataManager.shared.markAsRead(conversationID: item.modelID, completion: nil)
        }
    }
    
    
    func exitEdittingMode(){
        if isEdittingMode{
            isEdittingMode = false
            
            listSelectedItemsInEdittingMode.removeAll()
            
            editView.removeFromSupernode()
        }
    }
    
    func deleteItems(items : [ChatInboxViewModel]){
        for item in items {
            DataManager.shared.deleteConversationWithID(item.modelID, completion: nil)
        }
        
    }
    
    func muteItem(at indexPath : IndexPath, until time : TimeInterval){
        let item = viewModels[indexPath.row]
        DataManager.shared.muteConversationWithID(item.modelID, until: time, completion: nil)
    }
    
    func unmuteItem(at indexPath : IndexPath){
        let item = viewModels[indexPath.row]
        DataManager.shared.unmuteConversationWithID(item.modelID, completion: nil)
        
    }
}

// MARK: - Display alert
extension InboxesViewController{
    
    func alertMarkItemsAsRead(items : [ChatInboxViewModel], completion: (() -> Void)?){
        let message = "Đánh dấu đã đọc " + String(items.count) + " cuộc trò chuyện này?"
        
        let delete = UIAlertAction(title: "Không", style: .cancel, handler: { action in })
        
        let dontDelete = UIAlertAction(title: "Có", style: .destructive, handler: { action in
            self.markItemsAsRead(items: items)
            
            if (completion != nil){
                completion!()
            }
        })
        
        displayAlert(title: "Xác nhận", message: message, actions: [delete, dontDelete], preferredStyle: .alert)
    }
    
    func alertDeleteItems(items : Array<ChatInboxViewModel>, completion: (() -> Void)?){
        var message : String
        if items.count > 1{
            message = "Bạn có muốn xoá " + String(items.count) + " cuộc trò chuyện đã chọn?"
        }else{
            message = "Bạn có muốn xoá cuộc trò chuyện đã chọn?"
        }
        
        let delete = UIAlertAction(title: "Không", style: .cancel, handler: { action in })
        
        let dontDelete = UIAlertAction(title: "Có", style: .destructive, handler: { action in
            self.deleteItems(items: items)
            
            if (completion != nil){
                completion!()
            }
        })
        
        displayAlert(title: "Xác nhận", message: message, actions: [delete, dontDelete], preferredStyle: .alert)
    }
    
    func alertMuteItem(at indexPath : IndexPath, completion: (() -> Void)?){
        let message = "Không thông báo tin nhắn mới của hội thoại này"
        
        let mute1h = UIAlertAction(title: "Trong 1 tiếng", style: .default, handler: { action in
            self.muteItem(at: indexPath, until: timeNow + HOURS)
        })
        let mute4h = UIAlertAction(title: "Trong 4 tiếng", style: .default, handler: { action in
            self.muteItem(at: indexPath, until: timeNow + 4 * HOURS)
        })
        let mute8h = UIAlertAction(title: "Trong 8 tiếng", style: .default, handler: { action in
            self.muteItem(at: indexPath, until: timeNow + 8 * HOURS)
        })
        let muteUnlimited = UIAlertAction(title: "Cho đến khi được mở lại", style: .default, handler: { action in
            self.muteItem(at: indexPath, until: 2 * timeNow)
        })
        
        let cancel = UIAlertAction(title: "Huỷ", style: .cancel, handler: { action in })
        
        displayAlert(title: "Tắt thông báo", message: message, actions: [mute1h, mute4h, mute8h, muteUnlimited, cancel], preferredStyle: .actionSheet)
    }
    
    
    func displayAlert(title : String, message : String, actions : [UIAlertAction], preferredStyle: UIAlertController.Style, completion: (() -> Void)? = nil){
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
            for action in actions{
                alert.addAction(action)
            }
            self.present(alert, animated: true, completion: completion)
        }
    }
}


// MARK: - TableNode Delegate
extension InboxesViewController : InboxesDelegate{
    
    func tableNode(_ table: InboxsTableNode, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        // Option
        let more = UITableViewRowAction(style: .normal, title: "More", handler: { (viewAction, indexPath) in
            let mute = UIAlertAction(title: "Tắt thông báo", style: .default, handler: { action in
                self.alertMuteItem(at: indexPath, completion: nil)
            })
            
            let unmute = UIAlertAction(title: "Bật thông báo", style: .default, handler: { action in
                self.unmuteItem(at: indexPath)
            })
            
            let cancel = UIAlertAction(title: "Huỷ", style: .cancel, handler: { action in })
            
            var actions = Array<UIAlertAction>()
            if self.viewModels[indexPath.row].model.isMuted(){
                actions = [unmute, cancel]
            }else{
                actions = [mute, cancel]
            }
            
            self.displayAlert(title: "Tuỳ chọn", message: "", actions: actions, preferredStyle: .actionSheet)
        })
        more.backgroundColor = UIColor.systemGray
        
        // Hide Item
        let hide = UITableViewRowAction(style: .default, title: "Hide", handler: { (viewAction, indexPath) in
            let action = UIAlertAction(title: "OK", style: .cancel, handler: { action in })
            self.displayAlert(title: "Thông báo", message: "Tính năng đang cập nhật", actions: [action], preferredStyle: .actionSheet)
        })
        hide.backgroundColor = UIColor.systemPurple
        
        // Delete Item
        let delete = UITableViewRowAction(style: .destructive, title: "Delete", handler: { (viewAction, indexPath) in
            self.alertDeleteItems(items: [self.viewModels[indexPath.row]], completion: nil)
        })
        delete.backgroundColor = UIColor.systemRed
        
        return [delete, hide, more]
    }
    
    func tableNode(_ table: InboxsTableNode, didSelectRowAt indexPath: IndexPath) {
        if isEdittingMode{
            listSelectedItemsInEdittingMode.append(viewModels[indexPath.row])
            
            editView.updateButtonInNavigationBarAndTabBar(numberOfItems: listSelectedItemsInEdittingMode.count)
        }else{
            markItemsAsRead(items: [viewModels[indexPath.row]])
            
            let id = viewModels[indexPath.row].modelID
            let chatViewController = ChatScreenViewController(with: id)
            
            //navigationController?.present(UINavigationController.init(rootViewController: chatViewController), animated: true)
            chatViewController.hidesBottomBarWhenPushed = true
            tabBarController?.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(chatViewController, animated: true)
        }
    }
    
    func tableNode(_ table: InboxsTableNode, didDeselectRowAt indexPath: IndexPath) {
        if isEdittingMode{
            let item = viewModels[indexPath.row]
            let indexOfItem = listSelectedItemsInEdittingMode.firstIndex { (m) -> Bool in
                return m.model.id == item.model.id
            }
            if indexOfItem != nil{
                listSelectedItemsInEdittingMode.remove(at: indexOfItem!)
            }
            
            editView.updateButtonInNavigationBarAndTabBar(numberOfItems: listSelectedItemsInEdittingMode.count)
            
            if listSelectedItemsInEdittingMode.count == 0{
                exitEdittingMode()
            }
        }else{
            
        }
    }
    
    func tableNodeBeginEdittingMode(_ table: InboxsTableNode) {
        if isEdittingMode == false{
            isEdittingMode = true
            
            editView.addSubNodeIntoNavigationBar(navigationController!.navigationBar,
                                                 tabBar: tabBarController!.tabBar)
        }
    }
}

// MARK: - TableNode DataSource
extension InboxesViewController : InboxsDataSource{
    func tableNode(_ table: InboxsTableNode) -> Array<ChatInboxViewModel> {
        return viewModels 
    }
}

// MARK: - Navigation In Editting mode
extension InboxesViewController{
    
    @objc func leftTopButtonAction(button : ASButtonNode){
        exitEdittingMode()
    }
    
    @objc func rightTopButtonAction(button : ASButtonNode){
        self.alertDeleteItems(items: self.listSelectedItemsInEdittingMode, completion: {
            self.exitEdittingMode()
        })
    }
    
    @objc func leftBottomButtonAction(button : ASButtonNode){
        let action = UIAlertAction(title: "OK", style: .cancel, handler: { action in })
        self.displayAlert(title: "Thông báo", message: "Tính năng đang cập nhật", actions: [action], preferredStyle: .actionSheet)
    }
    
    @objc func rightBottomButtonAction(button : ASButtonNode){
        self.alertMarkItemsAsRead(items: listSelectedItemsInEdittingMode, completion: {
            self.exitEdittingMode()
        })
    }
}

// MARK: - Observer Delegate
extension InboxesViewController : DataManagerListenerDelegate{
    func messageChanged(_ msg : MessageModel, updateType : UpdateType, oldValue : MessageModel?) {
        
    }
    
   func conversationChanged(_ cvs : InboxModel, updateType : UpdateType, oldValue : InboxModel?) {
                
        switch updateType {
        case .new:
            print(1)
            
        case .changed:
            guard oldValue != nil, let index = viewModels.firstIndex(where: { (a) -> Bool in
                return a.modelID == cvs.id
            }) else {
                return
            }
            
            if cvs.lastMessage.id != oldValue!.lastMessage.id{
                
            }else{
                tableNode.reloadDataInCellNode(at: index)
            }
            
            numberOfNewMsg -= oldValue!.isUnread() ? 1 : 0
            
        case .delete:
            guard let index = viewModels.firstIndex(where: { (a) -> Bool in
                return a.modelID == cvs.id
            }) else {
                return
            }

            viewModels.remove(at: index)
            tableNode.deleteRow(at: index)
            numberOfNewMsg -= cvs.isUnread() ? 1 : 0
        }
    }
    
    func userChanged(_ user : UserModel, updateType : UpdateType, oldValue : UserModel?) {
        
    }
    
}


extension InboxesViewController{
    private func reloadUI(){
        tableNode.reloadData()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        reloadUI()
    }
}
