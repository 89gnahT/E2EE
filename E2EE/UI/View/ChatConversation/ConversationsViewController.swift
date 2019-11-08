//
//  ListConversationViewController.swift
//  LearnTextureKit
//
//  Created by CPU12015 on 11/1/19.
//  Copyright © 2019 CPU12015. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class ConversationsViewController: ASViewController<ASDisplayNode>{
    
    let tableNode = ConversationsTableNode()
    
    var modelViews = Array<ZAConversationViewModel>()
    
    var listSelectedItemsInEdittingMode = Array<ZAConversationViewModel>()
    
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
    
    func setup(){
        tableNode.dataSource = self
        tableNode.delegate = self
        tableNode.setNeedsLayout()
        tableNode.layoutIfNeeded()
        
        var t = DataManager.shared.conversations
        t.sort { (a, b) -> Bool in
            if a.lastMsg.time.sent < b.lastMsg.time.sent{
                return false
            }
            return true
        }
        
        for c in t{
            modelViews.append(ZAConversationViewModel(conversation: c as! ChatConversation))
        }
        
        tableNode.reloadData()
    }
    
    func markItemsAsRead(items : [ZAConversationViewModel]){
        var indexPaths = Array<IndexPath>()
        
        for item in items {
            let indexOfItem = self.modelViews.firstIndex(of: item)
            if indexOfItem != nil{
                indexPaths.append(IndexPath(row: indexOfItem!, section: 0))
            }
            
            DataManager.shared.markConversationAsRead(cvs: item.model!)
        }
        
        tableNode.reloadRows(at: indexPaths, with: .automatic)
    }
    
    
    
    func exitEdittingMode(){
        if isEdittingMode{
            isEdittingMode = false
            
            listSelectedItemsInEdittingMode.removeAll()
            
            editView.removeFromSupernode()
        }
    }
    
    func deleteItems(items : Array<ZAConversationViewModel>){
        var indexPaths = Array<IndexPath>()
        
        for item in items {
            let indexOfItem = self.modelViews.firstIndex(of: item)
            if indexOfItem != nil{
                indexPaths.append(IndexPath(row: indexOfItem!, section: 0))
            }
        }
        
        for indexPath in indexPaths{
            self.modelViews.remove(at: indexPath.row)
        }
        
        self.tableNode.deleteRows(at: indexPaths, withAnimation: .automatic)
    }
    
    
    func muteItem(at indexPath : IndexPath, time : TimeInterval){
        let cvsID = modelViews[indexPath.row].model?.id
        DataManager.shared.muteConversation(cvsID: cvsID!, time: time)
        
        tableNode.reloadRows(at: [indexPath], with: .automatic)
    }
    
    func unmuteItem(at indexPath : IndexPath){
        let cvsID = modelViews[indexPath.row].model?.id
        DataManager.shared.unmuteConversation(cvsID: cvsID!)
        
        tableNode.reloadRows(at: [indexPath], with: .automatic)
    }
    
    
}

// MARK: Display alert
extension ConversationsViewController{
    
    func alertMarkItemsAsRead(items : [ZAConversationViewModel], completion: (() -> Void)?){
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
    
    func alertDeleteItems(items : Array<ZAConversationViewModel>, completion: (() -> Void)?){
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
            self.muteItem(at: indexPath, time: Date.timeIntervalSinceReferenceDate + HOURS)
        })
        let mute4h = UIAlertAction(title: "Trong 4 tiếng", style: .default, handler: { action in
            self.muteItem(at: indexPath, time: Date.timeIntervalSinceReferenceDate + 4 * HOURS)
        })
        let mute8h = UIAlertAction(title: "Trong 8 tiếng", style: .default, handler: { action in
            self.muteItem(at: indexPath, time: Date.timeIntervalSinceReferenceDate + 8 * HOURS)
        })
        let muteUnlimited = UIAlertAction(title: "Cho đến khi được mở lại", style: .default, handler: { action in
            self.muteItem(at: indexPath, time: 2 * Date.timeIntervalSinceReferenceDate)
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


// MARK: Delegate
extension ConversationsViewController : ConversationsDelegate{
    
    func tableNode(_ table: ConversationsTableNode, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
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
            if self.modelViews[indexPath.row].isMute{
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
            self.alertDeleteItems(items: [self.modelViews[indexPath.row]], completion: nil)
        })
        delete.backgroundColor = UIColor.systemRed
        
        return [delete, hide, more]
    }
    
    func tableNode(_ table: ConversationsTableNode, didSelectRowAt indexPath: IndexPath) {
        if isEdittingMode{
            listSelectedItemsInEdittingMode.append(modelViews[indexPath.row])
            
            editView.updateButtonInNavigationBarAndTabBar(numberOfItems: listSelectedItemsInEdittingMode.count)
        }else{
            markItemsAsRead(items: [modelViews[indexPath.row]])
        }
    }
    
    func tableNode(_ table: ConversationsTableNode, didDeselectRowAt indexPath: IndexPath) {
        if isEdittingMode{
            let indexOfItem = listSelectedItemsInEdittingMode.firstIndex(of: modelViews[indexPath.row])
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
    
    func tableNodeBeginEdittingMode(_ table: ConversationsTableNode) {
        if isEdittingMode == false{
            isEdittingMode = true
            
            editView.addSubNodeIntoNavigationBar(navigationController!.navigationBar,
                                                           tabBar: tabBarController!.tabBar)
        }
    }
}

// MARK: DataSource
extension ConversationsViewController : ConversationsDataSource{
    func tableNode(_ table: ConversationsTableNode) -> Array<ZAConversationViewModel> {
        return modelViews 
    }
}

// MARK: Navigation In Editting mode
extension ConversationsViewController{
    
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