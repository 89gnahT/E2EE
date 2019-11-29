//
//  ChatScreenViewController.swift
//  E2EE
//
//  Created by Truong Nguyen on 11/19/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class ChatScreenViewController: ASViewController<ASDisplayNode> {
    var tableNode = ConversationTableNode()
    
    var viewModels = [MessageViewModel]()
    
    var currentBatchContext : ASBatchContext = ASBatchContext()
    
    var inboxID : InboxID!
    
    var chatBox : ChatBoxView!
    
    init(with inboxID : InboxID) {
        self.inboxID = inboxID
        
        super.init(node: tableNode)
        
        tableNode.delegate = self
        tableNode.dataSource = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DataManager.shared.fetchMessageModels(with: inboxID, { (models) in
            for i in models{
                if i.type == .text{
                    self.viewModels.append(TextMessageViewModel(model: i as! TextMessageModel))
                }else if i.type == .image{
                    self.viewModels.append(ImageMessageViewModel(model: i as! ImageMessageModel))
                }
            }
            
            self.tableNode.reloadData()
        }, callbackQueue: DispatchQueue.main)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardAppear(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDisappear(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.chatBox = ChatBoxView(target: self, chatboxFrame: tabBarController!.tabBar.frame, sendAction: #selector(tapSendButton(_:)))
        
        self.view.addSubnode(chatBox.chatBox)
    }
}

extension ChatScreenViewController: ConversationTableNodeDelegate{
    
    func tableNode(_ tableNode: ConversationTableNode, willBeginBatchFetchWith context: ASBatchContext) {
        DataManager.shared.fetchMessageModels(with: self.inboxID, { (models) in
            context.completeBatchFetching(true)
            
            var insertIndexs = [IndexPath]()
            
            var index = self.viewModels.count
            for i in models{
                if i.type == .text{
                    self.viewModels.append(TextMessageViewModel(model: i as! TextMessageModel))
                }else if i.type == .image{
                    self.viewModels.append(ImageMessageViewModel(model: i as! ImageMessageModel))
                }
                insertIndexs.append(IndexPath(row: index, section: 0))
                index += 1
            }
            
            self.tableNode.insertRows(at: insertIndexs)
            
        }, callbackQueue: DispatchQueue.main)
    }
}

extension ChatScreenViewController: ConversationTableNodeDataSource{
    func tableNode(_ tableNode: ConversationTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        let viewModel = self.viewModels[indexPath.row]
        if indexPath.row == 0{
            viewModel.setUIWithAfterItem(nil)
        }else{
            let after = self.viewModels[indexPath.row - 1]
            viewModel.setUIWithAfterItem(after)
            
            after.setUIWithPreviousItem(viewModel)
        }
        
        return {
            if viewModel.model.type == .text{
                return TextMessageCell(viewModel: viewModel as! TextMessageViewModel)
            }else{
                return ImagesMessageCell(viewModel: viewModel as! ImageMessageViewModel)
            }
        }
    }
    
    func tableNode(_ tableNode: ConversationTableNode, numberOfRowsInSection section: Int) -> Int {
        return viewModels.count
    }
}

extension ChatScreenViewController{
    @objc func tapSendButton(_ sender: ASButtonNode) {
        view.endEditing(true)
        DataManager.shared.sendTextMessage(inboxID: inboxID, withContent: "Xin chao HEHE") { (model) in
            ASPerformBlockOnMainThread {
                let viewModel = TextMessageViewModel(model: model)
                self.viewModels.insert(viewModel, at: 0)
                self.tableNode.insertRows(at: [IndexPath(row: 0, section: 0)])
            }
            
        }
    }
    
    @objc func keyboardAppear(notification: NSNotification) {
        self.chatBox.keyboardWillChange(notification: notification)
    }
    
    @objc func keyboardDisappear(notification: NSNotification) {
        self.chatBox.keyboardWillChange(notification: notification)
    }
}
