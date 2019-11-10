//
//  ContactViewController.swift
//  LearnTextureKit
//
//  Created by CPU12015 on 11/7/19.
//  Copyright © 2019 CPU12015. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class ContactViewController: ASViewController<ASDisplayNode>{
    
    let tableNode = ContactTableNode()
    
    var viewModels = Array<Array<ZAContactViewModel>>()
    var keyViewModels = Array<String>()
    
    init() {
        super.init(node: tableNode)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    func setup(){
        tableNode.dataSource = self
        tableNode.delegate = self
        tableNode.setNeedsLayout()
        tableNode.layoutIfNeeded()

        DataManager.shared.fetchContacts (completion: { (friends) in
            func handleInputModel(input : inout Array<ZAContactViewModel>){
                input.sort { (a, b) -> Bool in
                    return (a.title?.first)!.uppercased() < (b.title?.first)!.uppercased()
                }
                
                var lastKey : String = ""
                for m in input {
                    let c = String((m.title?.first?.uppercased())!)
                    if (c != lastKey){
                        lastKey = c
                        self.keyViewModels.append(c)
                        self.viewModels.append(Array<ZAContactViewModel>())
                    }
                    self.viewModels[self.viewModels.count - 1].append(m)
                }
            }
            
            var modelViewsTemp = Array<ZAContactViewModel>()
            for i in friends{
                modelViewsTemp.append(ZAContactViewModel(model: i))
            }
            handleInputModel(input: &modelViewsTemp)
            
            DispatchQueue.main.async {
                self.tableNode.reloadData()
            }
        })
        
    }
    
    
    
    func deleteItem(at indexPath : IndexPath){
        let section = indexPath.section
        viewModels[section].remove(at: indexPath.row)
        
        if viewModels[section].count == 0{
            keyViewModels.remove(at: section)
            viewModels.remove(at: section)
        }
        self.tableNode.deleteRow(at: indexPath, withAnimation: .automatic)
    }
    
    func alertDeleteItem(at indexPath : IndexPath, completion: (() -> Void)?){
        let name = viewModels[indexPath.section][indexPath.row].title!
        let message = "Bạn có muốn xoá bạn với " + name + "?"
        
        let delete = UIAlertAction(title: "Không", style: .cancel, handler: { action in })

        let dontDelete = UIAlertAction(title: "Có", style: .destructive, handler: { action in
            self.deleteItem(at: indexPath)

            if (completion != nil){
                completion!()
            }
        })

        displayAlert(title: "Xác nhận", message: message, actions: [delete, dontDelete], preferredStyle: .alert)
    }
    
    func displayAlert(title : String, message : String, actions : [UIAlertAction], preferredStyle: UIAlertController.Style, completion: (() -> Void)? = nil){
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
            for action in actions{
                alert.addAction(action)
            }
            self.present(alert, animated: true, completion: completion)
        }
    }
}

// MARK: Delegate
extension ContactViewController : ContactDelegate{
    func tableNode(_ table: ContactTableNode, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let more = UITableViewRowAction(style: .normal, title: "More", handler: { (viewAction, indexPath) in
            let action = UIAlertAction(title: "OK", style: .cancel, handler: { action in })
            self.displayAlert(title: "Thông báo", message: "Tính năng đang cập nhật", actions: [action], preferredStyle: .actionSheet)
        })
        more.backgroundColor = UIColor.lightGray
        
        let hide = UITableViewRowAction(style: .default, title: "Nhật kí", handler: { (viewAction, indexPath) in
            let action = UIAlertAction(title: "OK", style: .cancel, handler: { action in })
            self.displayAlert(title: "Thông báo", message: "Tính năng đang cập nhật", actions: [action], preferredStyle: .actionSheet)
        })
        hide.backgroundColor = UIColor.systemPurple
        
        let delete = UITableViewRowAction(style: .destructive, title: "Delete", handler: { (viewAction, indexPath) in
            self.alertDeleteItem(at: indexPath, completion: nil)
        })
        delete.backgroundColor = UIColor.systemRed
        
        return [delete, hide, more]
    }
}

// MARK: DataSource
extension ContactViewController : ContactDataSource{
    func sectionIndexTitles(for table: ContactTableNode) -> [String]? {
        return keyViewModels
    }
    
    func modelViews(for table: ContactTableNode) -> Array<Array<ZAContactViewModel>> {
        return viewModels
    }
    
}

extension ContactViewController{
    private func reloadUI(){
        tableNode.reloadData()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        reloadUI()
    }
}
