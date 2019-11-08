//
//  ContactTableNode.swift
//  LearnTextureKit
//
//  Created by CPU12015 on 11/7/19.
//  Copyright © 2019 CPU12015. All rights reserved.
//

import UIKit
import AsyncDisplayKit

@objc protocol ContactDelegate: NSObjectProtocol{
    @objc optional func tableNode(_ table: ContactTableNode, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]?
    
    @objc optional func tableNode(_ table: ContactTableNode, didSelectRowAt indexPath: IndexPath)
}


protocol ContactDataSource: NSObjectProtocol {
    
    func sectionIndexTitles(for table: ContactTableNode) -> [String]?
    func modelViews(for table: ContactTableNode) -> Array<Array<ZAContactViewModel>>
}


class ContactTableNode: ASDisplayNode {
    
    weak public var delegate : ContactDelegate?
    weak public var dataSource : ContactDataSource?
    
    private let tableNode = ASTableNode()
    private var modelViews = Array<Array<ZAContactViewModel>>()
    private var keyModelViews = Array<String>()
    
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
    }
    
    public func reloadData(){
        modelViews = (dataSource?.modelViews(for: self))!
        keyModelViews = (dataSource?.sectionIndexTitles(for: self))!
        
        tableNode.reloadData()
    }
    
    public func deleteRow(at indexPath : IndexPath, withAnimation animation : UITableView.RowAnimation){
        let section = indexPath.section
        modelViews[section].remove(at: indexPath.row)
        
        if modelViews[section].count == 0{
            keyModelViews.remove(at: section)
            modelViews.remove(at: section)
            
            tableNode.deleteSections(IndexSet(integer: section), with: animation)
        }else{
            tableNode.deleteRows(at: [indexPath], with: animation)
        }
    }
    
    public func insertRow(at indexPath : IndexPath, withAnimation animation : UITableView.RowAnimation){
        modelViews = (dataSource?.modelViews(for: self))!
        keyModelViews = (dataSource?.sectionIndexTitles(for: self))!
        tableNode.insertRows(at: [indexPath], with: animation)
    }
}

// MARK: Delegate
extension ContactTableNode: ASTableDelegate{
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        return delegate?.tableNode!(self, editActionsForRowAt: indexPath)
    }
    
    func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
        delegate?.tableNode?(self, didSelectRowAt: indexPath)
    }
    
    func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        return {
            let cellNode  = ZAContactTableCellNode(viewModel: self.modelViews[indexPath.section][indexPath.row])
            return cellNode
        }
    }
    
    func tableNode(_ tableNode: ASTableNode, constrainedSizeForRowAt indexPath: IndexPath) -> ASSizeRange {
        return ASSizeRangeMake(CGSize.init(width: self.frame.width, height: 0),
                               CGSize.init(width: self.frame.width, height: self.frame.height))
    }
    
}

// MARK: DataSource
extension ContactTableNode: ASTableDataSource{
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return keyModelViews[section]
    }
    func numberOfSections(in tableNode: ASTableNode) -> Int {
        return keyModelViews.count
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return keyModelViews
    }
    
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        return modelViews[section].count
    }
}
