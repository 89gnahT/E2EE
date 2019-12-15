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
    
    let topDefaultContentInset = CGFloat(15)
    
    let scrollDownBtn = ASButtonNode()
    
    override init() {
        super.init()
        
        automaticallyManagesSubnodes = true
        tableNode.inverted = true
        tableNode.dataSource = self
        tableNode.delegate = self
        tableNode.view.separatorStyle = .none
        tableNode.automaticallyAdjustsContentOffset = false
        tableNode.view.contentInsetAdjustmentBehavior = .never
        
        //tableNode.leadingScreensForBatching = 3
        
        scrollDownBtn.setImage(UIImage(named: "double_down_arrow")?.maskWithColor(color: .black), for: .normal)
        scrollDownBtn.imageNode.style.preferredSize = CGSize(squareEdge: 17)
        scrollDownBtn.setBackgroundImage(UIImage(named: "dot-1")?.maskWithColor(color: .white), for: .normal)
        let insets = CGFloat(12)
        scrollDownBtn.contentEdgeInsets = UIEdgeInsets(top: insets, left: insets, bottom: insets, right: insets)
    }
    
    override func didLoad() {
        super.didLoad()
        
        scrollDownBtn.addTarget(self, action: #selector(scrollDownBtnPressed(_:)), forControlEvents: .touchUpInside)
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        scrollDownBtn.style.layoutPosition = CGPoint(x: constrainedSize.max.width * 6.5/8,
                                                     y: constrainedSize.max.height * 8/9)
        
        let absoluteLayout = ASAbsoluteLayoutSpec(children: [tableNode, scrollDownBtn])
        
        return absoluteLayout
    }
}

extension ConversationTableNode{
    func reloadData(){
        tableNode.reloadData()
        
    }
    
    func scrollToRow(at row: Int){
        scrollToRow(at: IndexPath(row: row, section: 0))
    }
    
    func scrollToRow(at indexPath: IndexPath){
        tableNode.scrollToRow(at: indexPath, at: UITableView.ScrollPosition.top, animated: false)
    }
    
    func insertRows(at: [Int]){
        var indexPaths = [IndexPath]()
        for i in at{
            indexPaths.append(IndexPath(row: i, section: 0))
        }
        tableNode.insertRows(at: indexPaths, with: .automatic)
    }
    
    func insertRows(at: [IndexPath]){
        tableNode.insertRows(at: at, with: .automatic)
    }
    
    func deleteRows(at: [IndexPath]){
        tableNode.deleteRows(at: at, with: .automatic)
    }
    
    func deleteRows(at: [Int]){
        var indexPaths = [IndexPath]()
        for i in at{
            indexPaths.append(IndexPath(row: i, section: 0))
        }
        tableNode.deleteRows(at: indexPaths, with: .automatic)
    }
    
    func nodeForRowAt(_ index: Int) -> ASCellNode? {
        return tableNode.nodeForRow(at: IndexPath(row: index, section: 0))
    }
    
    func nodeForRowAt(_ indexPath: IndexPath) -> ASCellNode? {
        return tableNode.nodeForRow(at: indexPath)
    }
    
    func performBatch(animated: Bool, updates: (() -> Void)?, completion: ((Bool) -> Void)?){
        tableNode.performBatch(animated: animated, updates: updates, completion: completion)
    }
    
    func raiseFrameByHeight(_ height: CGFloat){
        view.frame.origin.y -= height
        tableNode.contentInset.bottom += height
    }
}

// MARK: - Delegate
extension ConversationTableNode: ASTableDelegate{
    func tableNode(_ tableNode: ASTableNode, constrainedSizeForRowAt indexPath: IndexPath) -> ASSizeRange {
        return ASSizeRangeMake(CGSize.init(width: self.view.frame.width, height: 0),
                               CGSize.init(width: self.view.frame.width, height: self.view.frame.height))
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
        
        delegate?.tableNode(self, willBeginBatchFetchWith: context)
    }
    
    func tableNode(_ tableNode: ASTableNode, willDisplayRowWith node: ASCellNode) {
        guard let lastIndex = tableNode.indexPathsForVisibleRows().min()?.row else {
            scrollDownBtn.isHidden = true
            return
        }
        scrollDownBtn.isHidden = lastIndex > 10 ? false : true
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
        dataSource?.tableNode(self, numberOfRowsInSection: section) ?? 0
    }
}

extension ConversationTableNode{
    @objc func scrollDownBtnPressed(_ button: ASButtonNode){
        scrollToRow(at: 0)
    }
}
