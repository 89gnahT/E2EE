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
    
    var chatInputNode = ChatInputNode()
    
    var viewModels = [MessageViewModel]()
    
    var inboxID : InboxID!
    
    var selectedCell: MessageCell?
    
    var currentOrientation: UIDeviceOrientation = UIDevice.current.orientation
    
    lazy var editMessageView: MessageCellEditView = {
        let frame = self.view.frame
        
        return MessageCellEditView(target: self, frame: frame, removeBtnAction: #selector(removeMessageBtnPressed))
    }()
    
    init(with inboxID : InboxID) {
        self.inboxID = inboxID
        
        super.init(node: ASDisplayNode())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableNode.delegate = self
        tableNode.dataSource = self
        tableNode.frame = view.frame
        view.addSubnode(tableNode)
        
        chatInputNode.frame = tabBarController!.tabBar.frame
        chatInputNode.delegate = self
        view.addSubnode(chatInputNode)
        
        switch currentOrientation {
        case .faceDown, .faceDown, .portraitUpsideDown, .unknown:
            currentOrientation = .portrait
        default:
            break
        }
        
        DataManager.shared.addObserver(for: .messageChanged, target: self, callBackQueue: DispatchQueue.main)
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(tapEventInView(_:)))
        self.view.addGestureRecognizer(gesture)
    }
    
    
    @objc func deviceOrientationDidChange(_ notification: Notification) {
        let orientation = UIDevice.current.orientation
        switch orientation {
        case .portrait, .landscapeLeft, .landscapeRight:
            if currentOrientation != orientation{
                currentOrientation = orientation
                
                self.editMessageView.frame = self.view.frame
                
                self.chatInputNode.frame = self.tabBarController!.tabBar.frame
                
                self.tableNode.frame = self.view.frame
                self.tableNode.reloadData()
                
            }
            
        default:
            break
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardAppear(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDisappear(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(deviceOrientationDidChange), name: UIDevice.orientationDidChangeNotification, object: nil)
        
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
        
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func tapEventInView(_ gesture: UITapGestureRecognizer){
        self.editMessageView.removeFromSupernode()
        self.view.endEditing(true)
    }
    
    @objc func removeMessageBtnPressed(_ button: ASButtonNode){
        editMessageView.removeFromSupernode()
        guard let messageCell = editMessageView.messageCell else {
            return
        }
        self.removeMessageCell(messageCell)
    }
    
    func removeMessageCell(_ cell: MessageCell) {
        let model = cell.getViewModel().model
        DataManager.shared.deleteMessage(withInboxID: model.conversationID, messageID: model.id, completion: nil)
    }
}

extension ChatScreenViewController: ConversationTableNodeDelegate{
    func shouldBatchFetch(for tableNode: ConversationTableNode) -> Bool {
        true
    }
    
    func tableNode(_ tableNode: ConversationTableNode, willBeginBatchFetchWith context: ASBatchContext) {
        DataManager.shared.fetchMessageModels(with: self.inboxID, currentNumberMessages: viewModels.count, howManyMessageReceive: 40, { (models) in
            
            var viewModels = [MessageViewModel]()
            for i in models{
                let viewModel = MessageViewModelFactory.createViewModel(i)
                viewModels.append(viewModel)
            }
            
            ASPerformBlockOnMainThread {
                self.insertIntoLastWithMessages(viewModels: viewModels) { (success) in
                    context.completeBatchFetching(true)
                }
            }
            
        }, callbackQueue: nil)
    }
}

// MARK: ConversationTableNodeDataSource
extension ChatScreenViewController: ConversationTableNodeDataSource{
    func tableNode(_ tableNode: ConversationTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        let viewModel = viewModels[indexPath.row]
        
        return {
            var cell: MessageCell
            if viewModel.model.type == .text{
                cell = TextMessageCell(viewModel: viewModel as! TextMessageViewModel)
            }else{
                cell = ImagesMessageCell(viewModel: viewModel as! ImageMessageViewModel)
            }
            
            cell.delegate = self
            
            return cell
        }
    }
    
    func tableNode(_ tableNode: ConversationTableNode, numberOfRowsInSection section: Int) -> Int {
        return viewModels.count
    }
}

extension ChatScreenViewController: ChatInputNodeDelegate{
    func chatInputNode(_ chatInputNode: ChatInputNode, sendText text: String) {
        DataManager.shared.sendTextMessage(inboxID: inboxID, withContent: text, nil)
    }
    
    func chatInputNodeFrameDidChange(_ chatInputNode: ChatInputNode, newFrame nf: CGRect, oldFrame of: CGRect) {
        self.tableNode.changeSize(withHeight: nf.height - of.height)
    }
    
    @objc func keyboardAppear(notification: NSNotification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            
            self.tableNode.changeSize(withHeight: keyboardRectangle.height)
            self.chatInputNode.frame.origin.y -= keyboardRectangle.height
        }
    }
    
    @objc func keyboardDisappear(notification: NSNotification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            
            self.tableNode.changeSize(withHeight: -keyboardRectangle.height)
            self.chatInputNode.frame.origin.y += keyboardRectangle.height
        }
    }
}

// MARK: Handle Message
extension ChatScreenViewController{
    
    private func removeMessage(_ msg: MessageModel){
        var index = -1
        for i in 0..<viewModels.count{
            if viewModels[i].model.id == msg.id{
                index = i
                break
            }
        }
        removeMessage(at: index)
    }
    
    private func removeMessage(at pos: Int){
        if pos < 0{
            return
        }
        
        let count = self.viewModels.count
        guard pos >= 0 && pos < count else {
            return
        }
        
        let previous = count > pos + 1 ? self.viewModels[pos + 1] : nil
        let after = pos > 0 ? self.viewModels[pos - 1] : nil
        
        if previous != nil{
            previous!.setupPositionWith(previous: count > pos + 2 ? self.viewModels[pos + 2] : nil, andAfter: after)
            
            let preNode: MessageCell = self.tableNode.nodeForRowAt(IndexPath(row: pos + 1, section: 0)) as! MessageCell
            preNode.updateUI()
        }
        
        if after != nil{
            after!.setupPositionWith(previous: previous, andAfter: pos > 1 ? self.viewModels[pos - 2] : nil)
            
            let afterNode: MessageCell = self.tableNode.nodeForRowAt(IndexPath(row: pos - 1, section: 0)) as! MessageCell
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
    
    private func insertIntoLastWithMessages(viewModels : [MessageViewModel], completion: ((_ success: Bool) -> Void)?){
        if viewModels.isEmpty{
            completion?(false)
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
                indexPaths.append(IndexPath(row: self.viewModels.count - 1, section: 0))
                index -= 1
            }
            
            self.tableNode.insertRows(at: indexPaths)
        }, completion: { (success) in
            completion?(success)
        })
    }
}

// MARK: DataManagerListenerDelegate
extension ChatScreenViewController: DataManagerListenerDelegate{
    func messageChanged(_ msg: MessageModel, updateType: UpdateType, oldValue: MessageModel?) {
        let viewModel = MessageViewModelFactory.createViewModel(msg)
        
        switch updateType {
        case .new:
            insertMessage(viewModel: viewModel, at: 0)        
            tableNode.scrollToRow(at: 0)
            
        case .changed:
            break
        case .delete:
            removeMessage(msg)
        }
    }
    
    func conversationChanged(_ cvs: InboxModel, updateType: UpdateType, oldValue: InboxModel?) {
        
    }
    
    func userChanged(_ user: UserModel, updateType: UpdateType, oldValue: UserModel?) {
        
    }
}

// MARK: MessageCellDelegate
extension ChatScreenViewController: MessageCellDelegate{
    func messageCell(_ cell: MessageCell, contentClicked contentNode: ASDisplayNode) {
        if selectedCell != nil{
            if selectedCell === cell{
                selectedCell = nil
            }else{
                selectedCell?.isHideDetails = true
                selectedCell = cell
            }
        }else{
            selectedCell = cell
        }
    }
    
    func messageCell(_ cell: MessageCell, longPressGesture: UILongPressGestureRecognizer) {
        if longPressGesture.state == .began{
            editMessageView.messageCell = cell
            self.view.addSubnode(self.editMessageView)
        }
    }
    
    func messageCell(_ cell: MessageCell, avatarClicked avatarNode: ASImageNode) {
        
    }
    
    func messageCell(_ cell: MessageCell, subFunctionClicked subFunctionNode: ASImageNode) {
        
    }
    
}
