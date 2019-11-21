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
    
    init() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 1
        layout.minimumInteritemSpacing = 1
        
        collectionNode = ASCollectionNode(collectionViewLayout: layout)
        
        super.init(node: self.collectionNode)
        
        collectionNode.delegate = self
        collectionNode.dataSource = self
        
        self.view.backgroundColor = .black
  
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
        return 3
    }
 
    
    func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
        return {
            let a = ASTextCellNode()
            a.text = "ahha"
            //return a
            return MessageViewCell()
        }
    }
    

}
