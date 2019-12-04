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
}


protocol ConversationTableNodeDataSource: NSObjectProtocol {
    func tableNode(_ tableNode: ConversationTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock
    
    func tableNode(_ tableNode: ConversationTableNode, numberOfRowsInSection section: Int) -> Int
}

class ConversationTableNode: ASDisplayNode {
    private var tableNode = ASTableNode()
    
    var delegate : ConversationTableNodeDelegate?
    var dataSource : ConversationTableNodeDataSource?
    
    var currentBatchContext : ASBatchContext = ASBatchContext()
    
    override init() {
        super.init()
        
        automaticallyManagesSubnodes = true
        tableNode.inverted = true
        tableNode.dataSource = self
        tableNode.delegate = self
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
    
    func insertRows(at: [IndexPath]){
        tableNode.insertRows(at: at, with: .automatic)
    }
    
    func deleteRows(at: [IndexPath]){
        tableNode.deleteRows(at: at, with: .automatic)
    }
    
    func nodeForRowAt(_ indexPath: IndexPath) -> ASCellNode? {
        return tableNode.nodeForRow(at: indexPath)
    }
}

extension ConversationTableNode: ASTableDelegate{
    func tableNode(_ tableNode: ASTableNode, constrainedSizeForRowAt indexPath: IndexPath) -> ASSizeRange {
        return ASSizeRangeMake(CGSize.init(width: self.view.frame.width, height: 0),
                               CGSize.init(width: self.view.frame.width, height: self.view.frame.height))
    }
    
    func shouldBatchFetch(for tableNode: ASTableNode) -> Bool {
         return !currentBatchContext.isFetching()
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
