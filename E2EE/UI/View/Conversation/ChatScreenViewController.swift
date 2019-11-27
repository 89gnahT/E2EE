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
    var collectionNode : ASCollectionNode
    var viewModels = [TextMessageViewModel]()
    
    init(with inboxID : InboxID) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 1
        layout.minimumInteritemSpacing = 1
        
        collectionNode = ASCollectionNode(collectionViewLayout: layout)
        
        super.init(node: self.collectionNode)
        
        collectionNode.delegate = self
        collectionNode.dataSource = self
        collectionNode.inverted = true
        collectionNode.contentInset = UIEdgeInsets.zero
    
        
        DataManager.shared.fetchMessageModels(with: inboxID, { (models) in
            for i in models{
                if i.type == .text{
                    self.viewModels.append(TextMessageViewModel(model: i as! TextMessageModel))
                }
            }
            
            self.collectionNode.reloadData()
        }, callbackQueue: DispatchQueue.main)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ChatScreenViewController: ASCollectionDelegate{
    func collectionNode(_ collectionNode: ASCollectionNode, constrainedSizeForItemAt indexPath: IndexPath) -> ASSizeRange {
        return ASSizeRangeMake(CGSize.init(width: self.view.frame.width, height: 0),
                               CGSize.init(width: self.view.frame.width, height: self.view.frame.height))
    }
}

extension ChatScreenViewController: ASCollectionDataSource{
    func numberOfSections(in collectionNode: ASCollectionNode) -> Int {
        return 1
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        return viewModels.count
    }
    
    
    func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
        
        let viewModel = self.viewModels[indexPath.row]
        if indexPath.row == 0{
            viewModel.setUIWithAfterItem(nil)
        }else{
            let after = self.viewModels[indexPath.row - 1]
            viewModel.setUIWithAfterItem(after)
            
            after.setUIWithPreviousItem(viewModel)
        }
        
        return {
            return TextMessageCell(viewModel: viewModel)
        }
    }
    
    
}
