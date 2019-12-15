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
    var conversationTableNode = ConversationTableNode()
    
    var chatInputNode = ChatInputNode()
    
    var viewModels = [BaseMessageViewModel]()
    
    var outOfData: Bool = false
    
    var numberOfMessageTitle: Int = 0
    
    let numberOfAdditionalMessagesLoaded = 40
    
    var inboxID : InboxID!
    
    var selectedCell: MessageCell?
    
    var currentOrientation: UIDeviceOrientation = UIDevice.current.orientation
    
    var keyboardAppeared: Bool = false
    
    var currentKeyboardFrame: CGRect = CGRect.zero
    
    lazy var editMessageView: MessageEditView = {
        let frame = self.view.frame
        
        return MessageEditView(target: self, frame: frame, removeBtnAction: #selector(removeMessageBtnPressed))
    }()
    
    var lastSafeAreaInsets: UIEdgeInsets = UIEdgeInsets.zero
    
    init(with inboxID : InboxID) {
        self.inboxID = inboxID
        
        super.init(node: ASDisplayNode())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        
        let frame = view.frame
        conversationTableNode.delegate = self
        conversationTableNode.dataSource = self
        conversationTableNode.frame = frame
        conversationTableNode.frame.size.height -= chatInputNode.baseHeight
        view.addSubnode(conversationTableNode)
        
        chatInputNode.delegate = self
        chatInputNode.frame = CGRect(x: 0,
                                     y: frame.height - chatInputNode.baseHeight,
                                     width: frame.width,
                                     height: chatInputNode.baseHeight)
        view.addSubnode(chatInputNode)
        
        switch currentOrientation {
        case .faceDown, .faceUp, .portraitUpsideDown, .unknown:
            currentOrientation = .portrait
        default:
            break
        }
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(tapEventInView(_:)))
        self.view.addGestureRecognizer(gesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
     
        NotificationCenter.default.addObserver(self, selector: #selector(deviceOrientationDidChange), name: UIDevice.orientationDidChangeNotification, object: nil)
        
        chatInputNode.registerNotifications()
        
        DataManager.shared.addObserver(for: .messageChanged, target: self, callBackQueue: DispatchQueue.main)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        chatInputNode.unregisterNotifications()
        
        NotificationCenter.default.removeObserver(self)
        
        DataManager.shared.removeObserver(target: self)
    }
    
    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        let currentSafeAreaInsets = view.safeAreaInsets
        
        chatInputNode.safeAreaInsetsChange(view.safeAreaInsets)
        
        conversationTableNode.frame.size.height += lastSafeAreaInsets.bottom - currentSafeAreaInsets.bottom
        conversationTableNode.contentInset.bottom += -lastSafeAreaInsets.top + currentSafeAreaInsets.top
        conversationTableNode.contentInset.top = conversationTableNode.topDefaultContentInset
        
        lastSafeAreaInsets = currentSafeAreaInsets
    }
}

extension ChatScreenViewController: ConversationTableNodeDelegate{
    func shouldBatchFetch(for tableNode: ConversationTableNode) -> Bool {
        return !outOfData
    }
    
    func tableNode(_ tableNode: ConversationTableNode, willBeginBatchFetchWith context: ASBatchContext) {
        DataManager.shared.fetchMessageModels(with: self.inboxID, currentNumberMessages: viewModels.count - numberOfMessageTitle, howManyMessageReceive: numberOfAdditionalMessagesLoaded, { (models) in
            
            if models.count == 0{
                self.outOfData = true
            }
            
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
            return MessageCellFactory.createMessageCell(withMessageViewModel: viewModel, target: self)
        }
    }
    
    func tableNode(_ tableNode: ConversationTableNode, numberOfRowsInSection section: Int) -> Int {
        return viewModels.count
    }
}

// MARK: Handle Message
extension ChatScreenViewController{
    
    func removeMessageCell(_ cell: MessageCell) {
        let model = cell.getViewModel().model
        DataManager.shared.deleteMessage(withInboxID: model.inboxID, messageID: model.id, completion: nil)
    }
    
    private func removeMessage(_ msg: MessageModel){
        var index = -1
        
        for i in 0..<viewModels.count{
            if (viewModels[i] as? MessageViewModel)?.model.id == msg.id{
                index = i
                break
            }
        }
        removeMessage(at: index)
    }
    
    private func removeMessage(at pos: Int){
        let count = viewModels.count
        guard pos >= 0 && pos < count else {
            return
        }
        
        let previous = count > pos + 1 ? viewModels[pos + 1] : nil
        let after = pos > 0 ? viewModels[pos - 1] : nil
        
        if let previousMessage = previous as? MessageViewModel{
            previousMessage.setupPositionWith(previous: count > pos + 2 ? (viewModels[pos + 2] as? MessageViewModel) : nil, andAfter: after as? MessageViewModel)
            
            let preNode: MessageCell = self.conversationTableNode.nodeForRowAt(pos + 1) as! MessageCell
            preNode.updateUI()
        }
        
        if let afterMessage = after as? MessageViewModel{
            afterMessage.setupPositionWith(previous: previous as? MessageViewModel, andAfter: pos > 1 ? (viewModels[pos - 2] as? MessageViewModel) : nil)
            
            let afterNode: MessageCell = conversationTableNode.nodeForRowAt(pos - 1) as! MessageCell
            afterNode.updateUI()
        }
        
        if (previous as? MessageTitleViewModel) != nil{
            numberOfMessageTitle -= 1
            viewModels.remove(at: pos + 1)
            conversationTableNode.deleteRows(at: [pos + 1])
        }
        
        viewModels.remove(at: pos)
        conversationTableNode.deleteRows(at: [pos])
    }
    
    private func insertMessageAtFirst(viewModel : MessageViewModel){
        
        let previous = viewModels.count > 0 ? viewModels.first! : nil
        
        if viewModel.isBlockMessageWith(previous){
            if let previousMessage = previous as? MessageViewModel{
                previousMessage.setupPositionWith(previous: viewModels.count > 1 ? (viewModels[1] as? MessageViewModel) : nil, andAfter: viewModel)
                
                let preNode: MessageCell = conversationTableNode.nodeForRowAt(0) as! MessageCell
                preNode.updateUI()
            }
            
            viewModel.setupPositionWith(previous: previous as? MessageViewModel, andAfter: nil)
            
        }else{
            
            let title = MessageTitleViewModel(messageTime: viewModel.messageTime())
            viewModel.setupPositionWith(previous: nil, andAfter: nil)
            
            numberOfMessageTitle += 1
            viewModels.insert(title, at: 0)
            conversationTableNode.insertRows(at: [0])
        }
        
        self.viewModels.insert(viewModel, at: 0)
        self.conversationTableNode.insertRows(at: [0])
    }
    
    private func insertIntoLastWithMessages(viewModels : [MessageViewModel], completion: ((_ success: Bool) -> Void)?){
        if viewModels.isEmpty{
            completion?(false)
            return
        }
        
        var arrayTitle = [MessageTitleViewModel]()
        
        let length = self.viewModels.count
        var lastTitle: MessageTitleViewModel? = length > 1 ? self.viewModels.last as? MessageTitleViewModel : nil
        lastTitle?.resetCount()
        
        var after1: MessageViewModel? = length > 1 ? self.viewModels[length - 2] as? MessageViewModel : nil
        var after2: MessageViewModel? = length > 2 ? self.viewModels[length - 3] as? MessageViewModel : nil
        
        if lastTitle?.isBlockMessageWith(viewModels.first!) ?? false{
            arrayTitle.append(lastTitle!)
        }
        for v in viewModels{
            if lastTitle == nil{
                lastTitle = MessageTitleViewModel(messageTime: v.messageTime())
                arrayTitle.append(lastTitle!)
            }else{
                if lastTitle!.isBlockMessageWith(v){
                    lastTitle?.updateTime(newTime: v.messageTime())
                }else{
                    lastTitle = MessageTitleViewModel(messageTime: v.messageTime())
                    arrayTitle.append(lastTitle!)
                }
            }
            
            after1?.setupPositionWith(previous: v, andAfter: after2)
            v.setupPositionWith(previous: nil, andAfter: after1)
            
            after2 = after1
            after1 = v
        }
        
        if length > 1{
            let afterNode: MessageCell = conversationTableNode.nodeForRowAt(length - 2) as! MessageCell
            afterNode.updateUI()
        }
        
        conversationTableNode.performBatch(animated: false, updates: {
            var indexs = [Int]()
            if length > 1 && arrayTitle.first! === self.viewModels.last!{
                self.viewModels.removeLast()
                self.conversationTableNode.deleteRows(at: [length - 1])
                
                self.numberOfMessageTitle += arrayTitle.count
            }else{
                self.numberOfMessageTitle += arrayTitle.count
            }
            
            var count = 0
            for v in viewModels{
                count += 1
                self.viewModels.append(v)
                indexs.append(self.viewModels.count - 1)
                
                if count == arrayTitle.first!.count{
                    count = 0
                    self.viewModels.append(arrayTitle.removeFirst())
                    indexs.append(self.viewModels.count - 1)
                }
            }
            
            self.conversationTableNode.insertRows(at: indexs)
        }, completion: { (success) in
            completion?(success)
        })
    }
}

// MARK: DataManagerListenerDelegate
extension ChatScreenViewController: DataManagerListenerDelegate{
    func messageChanged(_ msg: MessageModel, updateType: UpdateType, oldValue: MessageModel?) {
        guard msg.inboxID == inboxID else {
            return
        }
        let viewModel = MessageViewModelFactory.createViewModel(msg)
        
        switch updateType {
        case .new:
            insertMessageAtFirst(viewModel: viewModel)
            conversationTableNode.scrollToRow(at: 0)
            
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

extension ChatScreenViewController: ChatInputNodeDelegate{
    func chatInputNode(_ chatInputNode: ChatInputNode, sendMessageWithContent content: String, type: MessageType) {
        DataManager.shared.sendMessage(inboxID: inboxID, withContent: content, type: type, nil)
    }
    
    func chatInputNodeFrameDidChange(_ chatInputNode: ChatInputNode, newFrame nf: CGRect, oldFrame of: CGRect) {
        self.conversationTableNode.raiseFrameByHeight(of.minY - nf.minY)
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
            if keyboardAppeared{
                view.endEditing(true)
            }
            
            editMessageView.messageCell = cell
            view.addSubnode(editMessageView)
            editMessageView.transitionLayout(withAnimation: true, shouldMeasureAsync: true, measurementCompletion: nil)
        }
    }
    
    func messageCell(_ cell: MessageCell, avatarClicked avatarNode: ASImageNode) {
        
    }
    
    func messageCell(_ cell: MessageCell, subFunctionClicked subFunctionNode: ASImageNode) {
        
    }
    
}

// MARK: Action
extension ChatScreenViewController{
    @objc func tapEventInView(_ gesture: UITapGestureRecognizer){
        editMessageView.removeFromSupernode()
        
        view.endEditing(true)
    }
    
    @objc func removeMessageBtnPressed(_ button: ASButtonNode){
        let messageCell = editMessageView.messageCell
        
        editMessageView.removeFromSupernode()
        
        if messageCell != nil{
            self.removeMessageCell(messageCell!)
        }
    }
    
    // The keyboard always disappears before this method is called
    @objc func deviceOrientationDidChange(_ notification: Notification) {
        let orientation = UIDevice.current.orientation
        
        switch orientation {
            
        case .portrait, .landscapeLeft, .landscapeRight:
            if currentOrientation != orientation{
                currentOrientation = orientation
                
                let frame = view.frame
                
                editMessageView.frame = frame
                
                chatInputNode.deviceOrientationDidChange(frame)
                
                // Store old position
                let additionHeight = -conversationTableNode.frame.minY
                conversationTableNode.frame = frame
                conversationTableNode.frame.size.height -= chatInputNode.baseHeight + lastSafeAreaInsets.bottom
                // Set content inset
                conversationTableNode.contentInset.bottom = lastSafeAreaInsets.top
                conversationTableNode.contentInset.top = conversationTableNode.topDefaultContentInset
                // Restore old position
                conversationTableNode.raiseFrameByHeight(additionHeight)
                
                conversationTableNode.reloadData()
            }
            
        default:
            break
        }
    }
}
