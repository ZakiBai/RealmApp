//
//  TaskListViewController.swift
//  RealmApp
//
//  Created by Zaki on 31.05.2023.
//

import UIKit
import RealmSwift

final class TaskListViewController: UITableViewController {

    private var taskLists: Results<TaskList>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let addBarButton = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addButtonPressed)
        )
        
        navigationItem.rightBarButtonItem = addBarButton
        navigationItem.leftBarButtonItem = editButtonItem
        
        //methods
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    // MARK: UITableViewDataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        taskLists.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskListCell", for: indexPath)
        let taskList = taskLists[indexPath.row]
        cell.configure(with: taskList)
        return cell
    }
    
    // UITableViewDelegate
    
    
    @objc func addButtonPressed(){
        // method
    }
    

}

