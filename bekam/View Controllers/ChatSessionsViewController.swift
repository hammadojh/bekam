//
//  ChatListViewController.swift
//  bekam
//
//  Created by Omar on 24/11/2018.
//  Copyright © 2018 Omar. All rights reserved.
//

import UIKit
import Firebase

class ChatSessionsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //model
    var sessions:[ChatSession]?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noSessionsLabel: UILabel!
    
    //flags
    var loaded = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // check loging
        guard checkLogin(self) else {
            return
        }
        
        self.title = "Chats"        
        loadSessions()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        // check loging
        guard checkLogin(self) else {
            return
        }
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        // check loging
        guard checkLogin(self) else {
            return
        }
        
        // check if the sessions are nil load them
        if sessions == nil && !loaded {
            loadSessions()
        }
        
        if(tableView != nil){
            tableView.reloadData()
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sessions?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "chatCell") as! SessionCell
        
        cell.session = sessions![indexPath.item]
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 72
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let nextVC = storyboard?.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
        
        let selectedCell = tableView.cellForRow(at: indexPath) as! SessionCell
        
        if nextVC.chatSession == nil {
           nextVC.chatSession = selectedCell.session
        }
        
        nextVC.product = selectedCell.product
        nextVC.otherUser = selectedCell.otherUser
        nextVC.profileImage = selectedCell.reciverImageView.image
        
        navigationController?.pushViewController(nextVC, animated: true)
        
    }
    
    private func loadSessions(){
        
        loaded = true
        
        guard let id = appUser?.id else{
            print("user has no id ")
            setupEmptyScreen()
            return
        }
        
        ApiServices.getInstance().getAllSessionForUser(userId: id) { (snapshot, error) in
            
            if error != nil {
                self.setupEmptyScreen()
                return
            }
            
            guard let sessionDict = snapshot?.value as? [String:Any] else {
                return
            }
            
            if self.sessions == nil {
                self.sessions = [ChatSession]()
                self.setupTableView()
            }

            let session = ChatSession(dict:sessionDict)
            session.id = (snapshot as! DataSnapshot).key
            self.sessions?.insert(session, at: 0)
            self.tableView.reloadData()
            
        }
        
        
    }
    
    private func setupTableView(){
        
        noSessionsLabel.isHidden = true
        tableView.isHidden = false
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    private func setupEmptyScreen() {
        
        noSessionsLabel.isHidden = false
        tableView.isHidden = true
        
    }
    
    

}
