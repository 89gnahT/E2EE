//
//  ConversationTableNode.swift
//  E2EE
//
//  Created by CPU12015 on 11/29/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import UIKit
import AsyncDisplayKit

@objc protocol ConversationTableNodeDelegate: NSObjectProtocol{
    func tableNode(_ tableNode: ConversationTableNode, willBeginBatchFetchWith context: ASBatchContext)
    
    func shouldBatchFetch(for tableNode: ConversationTableNode) -> Bool
}


protocol ConversationTableNodeDataSource: NSObjectProtocol {
    func tableNode(_ tableNode: ConversationTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock
    
    func tableNode(_ tableNode: ConversationTableNode, numberOfRowsInSection section: Int) -> Int
}

class ConversationTableNode: ASDisplayNode {
    var tableNode = ASTableNode()
    
    var delegate : ConversationTableNodeDelegate?
    var dataSource : ConversationTableNodeDataSource?
    
    var currentBatchContext : ASBatchContext = ASBatchContext()
    
    var contentInset: UIEdgeInsets{
        set{
            tableNode.contentInset = newValue
        }
        get{
            return tableNode.contentInset
        }
    }
    
    var actualFrame: CGRect!
    
    override init() {
        super.init()
        
        automaticallyManagesSubnodes = true
        tableNode.inverted = true
        tableNode.dataSource = self
        tableNode.delegate = self
        tableNode.view.separatorStyle = .none
        
        //tableNode.leadingScreensForBatching = 3
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return ASInsetLayoutSpec(insets: UIEdgeInsets.zero, child: tableNode)
    }
}

extension ConversationTableNode{
    func reloadData(){
        tableNode.reloadData()
        
    }
    
    func scrollToRow(at indexPath: IndexPath){
        tableNode.scrollToRow(at: indexPath, at: UITableView.ScrollPosition.top, animated: false)
    }
    
    func insertRows(at: [IndexPath]){
        tableNode.insertRows(at: at, with: .automatic)
    }
    
    func deleteRows(at: [IndexPath]){
        tableNode.deleteRows(at: at, with: .automatic)
    }
    
    func nodeForRowAt(_ indexPath: IndexPath) -> ASCellNode? {
        return tableNode.nodeForRow(at: indexPath)
    }
    
    func performBatch(animated: Bool, updates: (() -> Void)?, completion: ((Bool) -> Void)?){
        tableNode.performBatch(animated: animated, updates: updates, completion: completion)
    }
    
    func keyboardWillAppear(withHeight height: CGFloat){
        contentInset.top = height
        scrollToRow(at: IndexPath(row: 0, section: 0))
    }
    
    func keyboardWillDisappear(){
        contentInset.top = 0
        scrollToRow(at: IndexPath(row: 0, section: 0))
    }
}

// MARK: - Delegate
extension ConversationTableNode: ASTableDelegate{
    func tableNode(_ tableNode: ASTableNode, constrainedSizeForRowAt indexPath: IndexPath) -> ASSizeRange {
        return ASSizeRangeMake(CGSize.init(width: self.view.frame.width, height: 0),
                               CGSize.init(width: self.view.frame.width, height: self.view.frame.height))
    }
    
    func tableView(_ tableView: ASTableView, willDisplay node: ASCellNode, forRowAt indexPath: IndexPath) {
        guard actualFrame != nil else {
            return
        }
        
//        if indexPath.row == 0{
//            if tableNode.view.contentSize.height < actualFrame.height{
//                var totalHeight: CGFloat = 0
//                let numberOfCell = tableNode.numberOfRows(inSection: 0)
//                for i in 0..<numberOfCell{
//                    totalHeight += (tableNode.nodeForRow(at: IndexPath(row: i, section: 0))!.frame.height)
//                }
//                if totalHeight < actualFrame.height{
//                    let topInset = actualFrame.height - totalHeight
//
//                    contentInset.top = topInset
//                }
//
//            }else{
//                contentInset.top = 0
//            }
//        }
    }
    
    
    func shouldBatchFetch(for tableNode: ASTableNode) -> Bool {
        return delegate?.shouldBatchFetch(for: self) ?? true && !currentBatchContext.isFetching()
    }
    
    func tableNode(_ tableNode: ASTableNode, willBeginBatchFetchWith context: ASBatchContext) {
        context.beginBatchFetching()
        if currentBatchContext.isFetching(){
            currentBatchContext.cancelBatchFetching()
        }
        currentBatchContext = context
        
        delegate!.tableNode(self, willBeginBatchFetchWith: context)
    }
}

// MARK: - DataSource
extension ConversationTableNode: ASTableDataSource{
    func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        return (dataSource?.tableNode(self, nodeBlockForRowAt: indexPath))!
    }
    
    func numberOfSections(in tableNode: ASTableNode) -> Int {
        return 1
    }
    
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        dataSource!.tableNode(self, numberOfRowsInSection: section)
    }
}
