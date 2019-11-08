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
    
    var modelViews = NSMutableArray()
    
    var listSelectedItemsInEdittingMode = NSMutableArray()
    
    var isEdittingMode : Bool = false{
        didSet{
            tableNode.isInEdittingMode = self.isEdittingMode
        }
    }
    
    lazy var editNavigationView : EditNavigationView = {
        let navigationViewFrame = (navigationController?.navigationBar.bounds)!
        let toolBarViewFrame = (tabBarController?.tabBar.bounds)!
        return EditNavigationView(target: self,
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
            modelViews.add(ZAConversationViewModel(conversation: c as! ChatConversation))
        }

        tableNode.reloadData()
    }
    
    func markItemsAsRead(at indexPaths : [IndexPath]){
        for indexPath in indexPaths{
            let conversation = (modelViews[indexPath.row] as! ZAConversationViewModel).model
            DataManager.shared.markConversationAsRead(cvs: conversation!)
        }
    
        tableNode.reloadRows(at: indexPaths, with: .automatic)
    }
    
    func alertMarkItemsAsRead(at indexPaths : [IndexPath], completion: (() -> Void)?){
        let message = "Đánh dấu đã đọc " + String(indexPaths.count) + " cuộc trò chuyện này?"
        
        let delete = UIAlertAction(title: "Không", style: .cancel, handler: { action in })
        
        let dontDelete = UIAlertAction(title: "Có", style: .destructive, handler: { action in
            self.markItemsAsRead(at: indexPaths)
            
            if (completion != nil){
                completion!()
            }
        })
        
        displayAlert(title: "Xác nhận", message: message, actions: [delete, dontDelete], preferredStyle: .alert)
    }
    
    func exitEdittingMode(){
        if isEdittingMode{
            isEdittingMode = false
            
            listSelectedItemsInEdittingMode.removeAllObjects()
            
            editNavigationView.editNavigationView.removeFromSupernode()
            editNavigationView.editTabBarView.removeFromSupernode()
        }
    }
    
    func deleteItems(items : NSMutableArray){
        var indexPaths = Array<IndexPath>()
        
        for ob in items {
            indexPaths.append(IndexPath(row: self.modelViews.index(of: ob), section: 0))
        }
        
        for indexPath in indexPaths{
            self.modelViews.removeObject(at: indexPath.row)
        }
        
        self.tableNode.deleteRows(at: indexPaths, withAnimation: .automatic)
    }
    
    func alertDeleteItems(items : NSMutableArray, completion: (() -> Void)?){
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
        let more = UITableViewRowAction(style: .normal, title: "More", handler: { (viewAction, indexPath) in
            let action = UIAlertAction(title: "OK", style: .cancel, handler: { action in })
            self.displayAlert(title: "Thông báo", message: "Tính năng đang cập nhật", actions: [action], preferredStyle: .actionSheet)
        })
        more.backgroundColor = UIColor.systemGray
        
        let hide = UITableViewRowAction(style: .default, title: "Hide", handler: { (viewAction, indexPath) in
            let action = UIAlertAction(title: "OK", style: .cancel, handler: { action in })
            self.displayAlert(title: "Thông báo", message: "Tính năng đang cập nhật", actions: [action], preferredStyle: .actionSheet)
        })
        hide.backgroundColor = UIColor.systemPurple
        
        let delete = UITableViewRowAction(style: .destructive, title: "Delete", handler: { (viewAction, indexPath) in
            let itemsDelete = NSMutableArray(object: self.modelViews.object(at: indexPath.row))
            self.alertDeleteItems(items: itemsDelete, completion: {
                itemsDelete.removeAllObjects()
            })
        })
        delete.backgroundColor = UIColor.systemRed
        
        return [delete, hide, more]
    }
    
    func tableNode(_ table: ConversationsTableNode, didSelectRowAt indexPath: IndexPath) {
        if isEdittingMode{
            listSelectedItemsInEdittingMode.add(modelViews[indexPath.row])
            editNavigationView.updateRightButtonInEditNavigation(numberOfItems: listSelectedItemsInEdittingMode.count)
            editNavigationView.updateRightButtonInEditToolBar(numberOfItems: listSelectedItemsInEdittingMode.count)
        }else{
            markItemsAsRead(at: [indexPath])
        }
    }
    
    func tableNode(_ table: ConversationsTableNode, didDeselectRowAt indexPath: IndexPath) {
        if isEdittingMode{
            listSelectedItemsInEdittingMode.remove(modelViews[indexPath.row])
            editNavigationView.updateRightButtonInEditNavigation(numberOfItems: listSelectedItemsInEdittingMode.count)
            editNavigationView.updateRightButtonInEditToolBar(numberOfItems: listSelectedItemsInEdittingMode.count)
        }else{
            
        }
    }
    
    // MARK: Editting Mode
    func tableNodeBeginEdittingMode(_ table: ConversationsTableNode) {
        if isEdittingMode == false{
            isEdittingMode = true
            
            navigationController?.navigationBar.addSubnode(editNavigationView.editNavigationView);
            tabBarController?.tabBar.addSubnode(editNavigationView.editTabBarView)
        }
    }
}

// MARK: DataSource
extension ConversationsViewController : ConversationsDataSource{
    func tableNode(_ table: ConversationsTableNode) -> NSMutableArray {
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
        var indexPaths = Array<IndexPath>()
        for item in listSelectedItemsInEdittingMode{
            let indexPath = IndexPath(row: modelViews.index(of: item), section: 0)
            indexPaths.append(indexPath)
        }
        
        self.alertMarkItemsAsRead(at: indexPaths) {
            self.exitEdittingMode()
        }
    }
}
