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
        
        conversationTableNode.tableNode.automaticallyAdjustsContentOffset = false
        conversationTableNode.tableNode.view.contentInsetAdjustmentBehavior = .never
        
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
    
    /**
     Follow: The system will automatically the methods in the following order:
     1. If keyboard disappeard: viewSafeAreaInsetsDidChange -> orientation changed
     2. If keyboard appeared: viewSafeAreaInsetsDidChange -> keyboard disappeared -> orientation changed -> keyboard appear
     
     With case 1, we handle it very easily
     Step 1: in safeAreaInsetsChange, We need to update height, position and contentInsets of the nodes (remove old value and update new value)
     Step 2: In orientationChange, we retains chatInputNode's height and change the remainning properties according to the new frame
     
     With case 2, we'll transform this case to case 1:
     We need handle Step 1 to 3 in safeAreaInsetsChange
     Step 1: First, we call keyboardDisappear with old safe area insets
     Step 2: Now, we do the same as Step 1 in case 1
     Step 3: We call keyboarAppear after update safe area insets
     Step 4: Do the same as step 2 in case 1
     */
    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        let currentSafeAreaInsets = view.safeAreaInsets
        
        // When safe area insets changed, we need to update the height, the position, the content insets of chatInputNode and tabeNode
        func handleSafeAreaInsetDidChangeWhenKeyboardDisappeared(){
            chatInputNode.frame.origin.y += lastSafeAreaInsets.bottom - currentSafeAreaInsets.bottom
            chatInputNode.frame.size.height += -lastSafeAreaInsets.bottom + currentSafeAreaInsets.bottom
            
            chatInputNode.contentInsets = currentSafeAreaInsets
            chatInputNode.contentInsets.top = 0
            
            conversationTableNode.frame.size.height += lastSafeAreaInsets.bottom - currentSafeAreaInsets.bottom
            conversationTableNode.contentInset.bottom += -lastSafeAreaInsets.top + currentSafeAreaInsets.top
            conversationTableNode.contentInset.top = conversationTableNode.topDefaultContentInset
        }
        
        if keyboardAppeared{
            handleFrameWhenKeyboardChanged(keyboardAppeard: false)
        }
        
        handleSafeAreaInsetDidChangeWhenKeyboardDisappeared()
        
        // Update new insets
        lastSafeAreaInsets = currentSafeAreaInsets
        
        if keyboardAppeared{
            handleFrameWhenKeyboardChanged(keyboardAppeard: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardAppear(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDisappear(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(deviceOrientationDidChange), name: UIDevice.orientationDidChangeNotification, object: nil)
        
        DataManager.shared.addObserver(for: .messageChanged, target: self, callBackQueue: DispatchQueue.main)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
        
        DataManager.shared.removeObserver(target: self)
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
            if (viewModels[i] as! MessageViewModel).model.id == msg.id{
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
        
        let previous = count > pos + 1 ? (self.viewModels[pos + 1] as! MessageViewModel) : nil
        let after = pos > 0 ? (self.viewModels[pos - 1] as! MessageViewModel) : nil
        
        if previous != nil{
            previous!.setupPositionWith(previous: count > pos + 2 ? (self.viewModels[pos + 2] as! MessageViewModel) : nil, andAfter: after)
            
            let preNode: MessageCell = self.conversationTableNode.nodeForRowAt(IndexPath(row: pos + 1, section: 0)) as! MessageCell
            preNode.updateUI()
        }
        
        if after != nil{
            after!.setupPositionWith(previous: previous, andAfter: pos > 1 ? (self.viewModels[pos - 2] as! MessageViewModel) : nil)
            
            let afterNode: MessageCell = self.conversationTableNode.nodeForRowAt(IndexPath(row: pos - 1, section: 0)) as! MessageCell
            afterNode.updateUI()
        }
        
        self.viewModels.remove(at: pos)
        self.conversationTableNode.deleteRows(at: [IndexPath(row: pos, section: 0)])
    }
    
    private func insertMessage(viewModel : MessageViewModel, at pos: Int){
        if pos < 0 && pos > viewModels.count{
            return
        }
        
        let previous = viewModels.count > pos ? (viewModels[pos] as! MessageViewModel) : nil
        if previous != nil{
            previous?.setupPositionWith(previous: viewModels.count > pos + 1 ? (viewModels[pos + 1] as! MessageViewModel) : nil, andAfter: viewModel)
            
            let preNode: MessageCell = conversationTableNode.nodeForRowAt(IndexPath(row: pos, section: 0)) as! MessageCell
            preNode.updateUI()
        }
        
        let after =  pos > 0 ? (viewModels[pos - 1] as! MessageViewModel) : nil
        
        if after != nil{
            after?.setupPositionWith(previous: viewModel, andAfter: pos >= 2 ? (viewModels[pos - 2] as! MessageViewModel) : nil)
            
            let afterNode: MessageCell = conversationTableNode.nodeForRowAt(IndexPath(row: pos - 1, section: 0)) as! MessageCell
            afterNode.updateUI()
        }
        
        viewModel.setupPositionWith(previous: previous, andAfter: after)
        
        self.viewModels.insert(viewModel, at: pos)
        self.conversationTableNode.insertRows(at: [IndexPath(row: pos, section: 0)])
    }
    
    private func insertIntoLastWithMessages(viewModels : [MessageViewModel], completion: ((_ success: Bool) -> Void)?){
        if viewModels.isEmpty{
            completion?(false)
            return
        }
        
        let length = self.viewModels.count
        var after1: MessageViewModel? = length > 0 ? (self.viewModels.last as! MessageViewModel) : nil
        var after2: MessageViewModel? = length > 1 ? (self.viewModels[length -  2] as! MessageViewModel) : nil
        
        for v in viewModels{
            after1?.setupPositionWith(previous: v, andAfter: after2)
            v.setupPositionWith(previous: nil, andAfter: after1)
            
            after2 = after1
            after1 = v
        }
        if length > 0{
            let afterNode: MessageCell = conversationTableNode.nodeForRowAt(IndexPath(row: length - 1, section: 0)) as! MessageCell
            afterNode.updateUI()
        }
        
        conversationTableNode.performBatch(animated: false, updates: {
            var indexPaths = [IndexPath]()
            for v in viewModels{
                self.viewModels.append(v)
                indexPaths.append(IndexPath(row: self.viewModels.count - 1, section: 0))
            }
            
            self.conversationTableNode.insertRows(at: indexPaths)
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
            insertMessage(viewModel: viewModel, at: 0)        
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
    func chatInputNode(_ chatInputNode: ChatInputNode, sendText text: String) {
        DataManager.shared.sendTextMessage(inboxID: inboxID, withContent: text, nil)
    }
    
    func chatInputNodeFrameDidChange(_ chatInputNode: ChatInputNode, newFrame nf: CGRect, oldFrame of: CGRect) {
        self.conversationTableNode.raiseFrameByHeight(nf.height - of.height)
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
    
    @objc func keyboardAppear(notification: NSNotification) {
        if !keyboardAppeared, let keyboardValue: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            keyboardAppeared = true
            currentKeyboardFrame = keyboardValue.cgRectValue
            
            handleFrameWhenKeyboardChanged(keyboardAppeard: keyboardAppeared)
        }
    }
    
    @objc func keyboardDisappear(notification: NSNotification) {
        if keyboardAppeared{
            keyboardAppeared = false
            
            handleFrameWhenKeyboardChanged(keyboardAppeard: keyboardAppeared)
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
                
                // Retains current chatInputNode's height and change the remainning properties according to the new frame
                let currentChatInputHeight = chatInputNode.frame.height
                chatInputNode.frame = CGRect(x: frame.minX,
                                             y: frame.maxY - currentChatInputHeight,
                                             width: frame.width,
                                             height: currentChatInputHeight)
                // Update content insets
                chatInputNode.contentInsets = lastSafeAreaInsets
                // We do not use top's content inset
                chatInputNode.contentInsets.top = 0
                
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

// MARK: Helper method
extension ChatScreenViewController{
    
    private func handleFrameWhenKeyboardChanged(keyboardAppeard appear: Bool){
        let height = currentKeyboardFrame.height - lastSafeAreaInsets.bottom
        
        if appear{
            self.conversationTableNode.raiseFrameByHeight(height)
            
            self.chatInputNode.frame.origin.y -= height
            self.chatInputNode.frame.size.height -= lastSafeAreaInsets.bottom
            
            self.chatInputNode.contentInsets.bottom -= lastSafeAreaInsets.bottom
        }else{
            self.conversationTableNode.raiseFrameByHeight(-height)
            
            self.chatInputNode.frame.origin.y += height
            self.chatInputNode.frame.size.height += lastSafeAreaInsets.bottom
            
            self.chatInputNode.contentInsets.bottom += lastSafeAreaInsets.bottom
        }
    }
}
