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
    
    var editNavigationView : EditNavigationView!
    
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
        
        var t = FakeData.shared.conversations
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
        var more, hide, delete : UITableViewRowAction
        more = UITableViewRowAction(style: .normal, title: "More", handler: { (viewAction, indexPath) in
            print("More")
        })
        more.backgroundColor = UIColor.lightGray
        
        hide = UITableViewRowAction(style: .default, title: "Hide", handler: { (viewAction, indexPath) in
            print("Hide")
        })
        hide.backgroundColor = UIColor.systemPurple
        
        delete = UITableViewRowAction(style: .destructive, title: "Delete", handler: { (viewAction, indexPath) in
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
            
            let navigationViewFrame = (navigationController?.navigationBar.bounds)!
            let toolBarViewFrame = (tabBarController?.tabBar.bounds)!
            editNavigationView = EditNavigationView(target: self,
                                                    navigationViewFrame: navigationViewFrame,
                                                    toolBarViewFrame: toolBarViewFrame,
                                                    leftTopButtonAction: #selector(leftTopButtonAction(button:)),
                                                    rightTopButtonAction: #selector(rightTopButtonAction(button:)),
                                                    leftBottomButtonAction: #selector(leftBottomButtonAction(button:)),
                                                    rightBottomButtonAction: #selector(rightBottomButtonAction(button:)))
            
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
    }
    
    @objc func rightBottomButtonAction(button : ASButtonNode){
    }
}
