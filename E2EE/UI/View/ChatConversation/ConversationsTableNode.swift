//
//  MeetupFeedViewController.swift
//  LearnTextureKit
//
//  Created by CPU12015 on 10/18/19.
//  Copyright © 2019 CPU12015. All rights reserved.
//

import UIKit
import AsyncDisplayKit

@objc protocol ConversationsDelegate: NSObjectProtocol{
    @objc optional func tableNode(_ table: ConversationsTableNode, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]?
    
    @objc optional func tableNode(_ table: ConversationsTableNode, didSelectRowAt indexPath: IndexPath)
    
    @objc optional func tableNode(_ table: ConversationsTableNode, didDeselectRowAt indexPath: IndexPath)
    
    @objc optional func tableNodeBeginEdittingMode(_ table: ConversationsTableNode)
}


protocol ConversationsDataSource: NSObjectProtocol {
    
    func tableNode(_ table: ConversationsTableNode) -> Array<ZAConversationViewModel>
}


class ConversationsTableNode: ASDisplayNode, UIGestureRecognizerDelegate {
    
    weak public var delegate : ConversationsDelegate?
    weak public var dataSource : ConversationsDataSource?
    
    private let tableNode = ASTableNode()
    private var modelViews = Array<ZAConversationViewModel>()
    
    public var isInEdittingMode : Bool = false{
        didSet{
            self.setEditing(self.isInEdittingMode, animated: true)
        }
    }
    
    override init() {
        super.init()
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
           return ASInsetLayoutSpec.init(insets: UIEdgeInsets.zero, child: tableNode)
       }
    
    private func setup() {
        self.view.addSubnode(tableNode)
        self.displaysAsynchronously = false;
        
        tableNode.delegate = self
        tableNode.dataSource = self
        tableNode.allowsMultipleSelection = false
        
        // LongPressGesture
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        longPressGesture.minimumPressDuration = 0.5
        longPressGesture.delegate = self
        tableNode.view.addGestureRecognizer(longPressGesture)
    }
    
    private func setEditing(_ editing: Bool, animated: Bool){
        tableNode.allowsMultipleSelectionDuringEditing = true
        tableNode.view.setEditing(editing, animated: animated)
    }
    
    public func reloadData(){
        modelViews = (dataSource?.tableNode(self))!
        tableNode.reloadData()
    }
    
    public func reloadRow(at indexPath : IndexPath, with animation : UITableView.RowAnimation){
        tableNode.reloadRows(at: [indexPath], with: animation)
    }
    
    public func deleteRow(at indexPath : IndexPath, withAnimation animation : UITableView.RowAnimation){
        modelViews.remove(at: indexPath.row)
        tableNode.deleteRows(at: [indexPath], with: animation)
    }
    
    public func insertRow(at indexPath : IndexPath, withAnimation animation : UITableView.RowAnimation){
        modelViews = (dataSource?.tableNode(self))!
        tableNode.insertRows(at: [indexPath], with: animation)
    }
}

// MARK: Delegate
extension ConversationsTableNode: ASTableDelegate{
    func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
        delegate?.tableNode?(self, didSelectRowAt: indexPath)
    }
    
    func tableNode(_ tableNode: ASTableNode, didDeselectRowAt indexPath: IndexPath) {
        delegate?.tableNode?(self, didDeselectRowAt: indexPath)
    }
    
    func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        return {
            let cellNode  = ZAConversationTableCellNode(viewModel: self.modelViews[indexPath.row])
            return cellNode
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        return delegate?.tableNode!(self, editActionsForRowAt: indexPath)
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    func tableNode(_ tableNode: ASTableNode, constrainedSizeForRowAt indexPath: IndexPath) -> ASSizeRange {
        return ASSizeRangeMake(CGSize.init(width: self.frame.width, height: 0),
                               CGSize.init(width: self.frame.width, height: self.frame.height))
    }
    
}

    // MARK: DataSource
extension ConversationsTableNode: ASTableDataSource{
    func numberOfSections(in tableNode: ASTableNode) -> Int {
        return 1
    }
    
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        return modelViews.count
    }
}

// MARK: Handle long press
extension ConversationsTableNode{
    @objc func handleLongPress(longPressGesture: UILongPressGestureRecognizer) {
        if isInEdittingMode {
            return
        }
        
        let p = longPressGesture.location(in: self.tableNode.view)
        
        let indexPath = self.tableNode.indexPathForRow(at: p)
        
        if indexPath == nil {
         
        } else
            if longPressGesture.state == UIGestureRecognizer.State.began {
                isInEdittingMode = true
                
                delegate?.tableNodeBeginEdittingMode?(self)
                
                tableNode.selectRow(at: indexPath!, animated: true, scrollPosition: .none)
                
                delegate?.tableNode?(self, didSelectRowAt: indexPath!)
        }
    }
}



