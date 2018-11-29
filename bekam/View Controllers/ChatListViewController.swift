//
//  ChatListViewController.swift
//  bekam
//
//  Created by Omar on 24/11/2018.
//  Copyright © 2018 Omar. All rights reserved.
//

import UIKit

class ChatSessionsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //model
    var sessions:[String] = [ChatSession(),ChatSession(),ChatSession()]
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //setup table view
        tableView.delegate = self
        tableView.dataSource = self

        // if user has no sessions
        
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sessions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "chatCell") as! SessionCell
        cell.session = sessions[indexPath.item]
        
        return cell
        
    }
    
    
    

}
