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
    
    lazy var editMessageView: MessageCellEditView = {
        let frame = self.view.frame
        
        return MessageCellEditView(target: self, frame: frame, removeBtnAction: #selector(removeMessageBtnPressed))
    }()
    
    init(with inboxID : InboxID) {
        self.inboxID = inboxID
        
        super.init(node: tableNode)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableNode.delegate = self
        tableNode.dataSource = self
      
        DataManager.shared.addObserver(for: .messageChanged, target: self, callBackQueue: DispatchQueue.main)
        
        DataManager.shared.fetchMessageModels(with: self.inboxID, { (models) in
            var viewModels = [MessageViewModel]()
            for i in models{
                let viewModel = MessageViewModelFactory.viewModel(i)
                viewModels.append(viewModel)
            }
            
            ASPerformBlockOnMainThread {
                self.insertIntoLastWithMessages(viewModels: viewModels)
            }
            
        }, callbackQueue: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardAppear(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDisappear(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(tapEventInView(_:)))
        self.view.addGestureRecognizer(gesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tabBarController?.tabBar.isHidden = true
        
        self.chatBox = ChatBoxView(target: self, chatboxFrame: tabBarController!.tabBar.frame)
        chatBox.delegate = self
        self.view.addSubnode(chatBox.chatBox)
    }
    
    @objc func tapEventInView(_ gesture: UITapGestureRecognizer){
        self.editMessageView.removeFromSupernode()       
    }
    
    @objc func removeMessageBtnPressed(_ button: ASButtonNode){
        editMessageView.removeFromSupernode()
        guard let messageCell = editMessageView.messageCell else {
            return
        }
        self.removeMessageCell(messageCell)
    }
    
    func removeMessageCell(_ cell: MessageCell) {
        let messageID = cell.getViewModel().model.id
        var index = 0
        for i in 0..<self.viewModels.count{
            if self.viewModels[i].model.id == messageID{
                index = i
                break
            }
        }
        
        self.removeMessage(at: index)
    }
}

extension ChatScreenViewController: ConversationTableNodeDelegate{
    
    func tableNode(_ tableNode: ConversationTableNode, willBeginBatchFetchWith context: ASBatchContext) {
//        DataManager.shared.fetchMessageModels(with: self.inboxID, { (models) in
//            context.completeBatchFetching(true)
//
//            var viewModels = [MessageViewModel]()
//            for i in models{
//                let viewModel = MessageViewModelFactory.viewModel(i)
//                viewModels.append(viewModel)
//            }
//
//            ASPerformBlockOnMainThread {
//                self.insertIntoLastWithMessages(viewModels: viewModels)
//            }
//
//        }, callbackQueue: nil)
    }
}

extension ChatScreenViewController: ConversationTableNodeDataSource{
    func tableNode(_ tableNode: ConversationTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        let viewModel = viewModels[indexPath.row]
        let rootViewController = self
        let messageCellDelegate: MessageCellDelegate = self
        return {
            if viewModel.model.type == .text{
                let cell = TextMessageCell(viewModel: viewModel as! TextMessageViewModel, rootViewController: rootViewController)
                cell.delegate = messageCellDelegate
                return cell
            }else{
                return ImagesMessageCell(viewModel: viewModel as! ImageMessageViewModel)
            }
        }
    }
    
    func tableNode(_ tableNode: ConversationTableNode, numberOfRowsInSection section: Int) -> Int {
        return viewModels.count
    }
}

extension ChatScreenViewController: ChatBoxDelegate{
    func sendButtonPressed(_ text: String) {
        view.endEditing(true)
        DataManager.shared.sendTextMessage(inboxID: inboxID, withContent: text) { (model) in
            ASPerformBlockOnMainThread {
//                let viewModel = TextMessageViewModel(model: model)
//                
//                self.insertMessage(viewModel: viewModel, at: 0)
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


extension ChatScreenViewController{
    
    private func removeMessage(at pos: Int){
        let count = self.viewModels.count
        guard pos >= 0 && pos < count else {
            return
        }
        
        let previous = count > pos + 1 ? self.viewModels[pos + 1] : nil
        let after = pos > 0 ? self.viewModels[pos - 1] : nil
        
        if previous != nil{
            previous!.setupPositionWith(previous: count > pos + 2 ? self.viewModels[pos + 2] : nil, andAfter: after)
            
            let preNode: MessageCell = tableNode.nodeForRowAt(IndexPath(row: pos + 1, section: 0)) as! MessageCell
            preNode.updateUI()
        }
        
        if after != nil{
            after!.setupPositionWith(previous: previous, andAfter: pos > 1 ? self.viewModels[pos - 2] : nil)
                        
            let afterNode: MessageCell = tableNode.nodeForRowAt(IndexPath(row: pos - 1, section: 0)) as! MessageCell
            afterNode.updateUI()
        }
                
        self.viewModels.remove(at: pos)
        self.tableNode.deleteRows(at: [IndexPath(row: pos, section: 0)])
    }
    
    private func insertMessage(viewModel : MessageViewModel, at pos: Int){
        
        if pos < 0 && pos > viewModels.count{
            return
        }
        
        let previous = viewModels.count > pos ? viewModels[pos] : nil
        if previous != nil{
            previous?.setupPositionWith(previous: viewModels.count > pos + 1 ? viewModels[pos + 1] : nil, andAfter: viewModel)
            
            let preNode: MessageCell = tableNode.nodeForRowAt(IndexPath(row: pos, section: 0)) as! MessageCell
            preNode.updateUI()
        }
        
        let after =  pos > 0 ? viewModels[pos - 1] : nil
        
        if after != nil{
            after?.setupPositionWith(previous: viewModel, andAfter: pos >= 2 ? viewModels[pos - 2] : nil)
            
            let afterNode: MessageCell = tableNode.nodeForRowAt(IndexPath(row: pos - 1, section: 0)) as! MessageCell
            afterNode.updateUI()
        }
        
        viewModel.setupPositionWith(previous: previous, andAfter: after)
        
        self.viewModels.insert(viewModel, at: pos)
        self.tableNode.insertRows(at: [IndexPath(row: pos, section: 0)])
    }
    
    private func insertIntoLastWithMessages(viewModels : [MessageViewModel]){
        if viewModels.isEmpty{
            return
        }
        
        var previous1: MessageViewModel?
        var previous2: MessageViewModel?
        
        for v in viewModels{
            previous1?.setupPositionWith(previous: previous2, andAfter: v)
            v.setupPositionWith(previous: previous1, andAfter: nil)
            
            previous2 = previous1
            previous1 = v
        }
        let after = self.viewModels.last
        if after != nil{
            let count = self.viewModels.count
            after?.setupPositionWith(previous: viewModels.last!, andAfter: count > 1 ? self.viewModels[count - 2] : nil)
            let afterNode: MessageCell = tableNode.nodeForRowAt(IndexPath(row: count - 1, section: 0)) as! MessageCell
            afterNode.updateUI()
        }
        
        tableNode.performBatch(animated: false, updates: {
            var indexPaths = [IndexPath]()
            var index = viewModels.count - 1
            while index >= 0{
                self.viewModels.append(viewModels[index])
                indexPaths.append(IndexPath(row: index, section: 0))
                index -= 1
            }
            
            self.tableNode.insertRows(at: indexPaths)
        }, completion: nil)
    }
}

extension ChatScreenViewController: DataManagerListenerDelegate{
    func messageChanged(_ msg: MessageModel, updateType: UpdateType, oldValue: MessageModel?) {
        let viewModel = MessageViewModelFactory.viewModel(msg)
        
        switch updateType {
        case .new:
            insertMessage(viewModel: viewModel, at: 0)        
            
        case .changed:
            break
        case .delete:
            var index = 0
            
            for i in 0..<viewModels.count{
                if viewModels[i].model.id == viewModel.model.id{
                    index = i
                    break
                }
            }
            
            viewModels.remove(at: index)
            tableNode.deleteRows(at: [IndexPath(row: index, section: 0)])
        }
    }
    
    func conversationChanged(_ cvs: InboxModel, updateType: UpdateType, oldValue: InboxModel?) {
        
    }
    
    func userChanged(_ user: UserModel, updateType: UpdateType, oldValue: UserModel?) {
        
    }
}

extension ChatScreenViewController: MessageCellDelegate{
    func messageCell(_ cell: MessageCell, contentClicked contentNode: ASDisplayNode) {
        
    }
    
    func messageCell(_ cell: MessageCell, longPressGesture: UILongPressGestureRecognizer) {
        if longPressGesture.state == .began{
            self.view.addSubnode(editMessageView)
            editMessageView.messageCell = cell
        }
    }
    
    func messageCell(_ cell: MessageCell, avatarClicked avatarNode: ASImageNode) {
        
    }
    
    func messageCell(_ cell: MessageCell, subFunctionClicked subFunctionNode: ASImageNode) {
        
    }
    
}
