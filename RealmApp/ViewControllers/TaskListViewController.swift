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
    private let storageManager = StorageManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let addBarButton = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addButtonPressed)
        )
        
        navigationItem.rightBarButtonItem = addBarButton
        navigationItem.leftBarButtonItem = editButtonItem
        
        taskLists = storageManager.realm.objects(TaskList.self)
        createTempData()
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
    
    // MARK: -UITableViewDelegate
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let taskList = taskLists[indexPath.row]
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [unowned self] _, _, _ in
            storageManager.delete(taskList)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        
        let editAction = UIContextualAction(style: .normal, title: "Edit") { [unowned self] _, _, isDone in
            showAlert(with: taskList) {
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
            isDone(true)
        }
        
        let doneAction = UIContextualAction(style: .normal, title: "Done") { [unowned self] _, _, isDone in
            storageManager.done(taskList)
            tableView.reloadRows(at: [indexPath], with: .automatic)
            isDone(true)
        }
        
        editAction.backgroundColor = .orange
        doneAction.backgroundColor = .systemGreen
        
        return UISwipeActionsConfiguration(actions: [doneAction, editAction, deleteAction])
    }
    
    // MARK: -Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let indexPath = tableView.indexPathForSelectedRow else { return }
        guard let tasksVC = segue.destination as? TasksViewController else { return }
        let taskList = taskLists[indexPath.row]
        tasksVC.taskList = taskList
    }
    
    
    @IBAction func sortingList(_ sender: UISegmentedControl) {
        taskLists = sender.selectedSegmentIndex == 0
        ? taskLists.sorted(byKeyPath: "date")
        : taskLists.sorted(byKeyPath: "title")
        tableView.reloadData()
    }
    
    
    @objc func addButtonPressed(){
        showAlert()
    }
    
    private func createTempData() {
        if !UserDefaults.standard.bool(forKey: "done") {
            DataManager.shared.createTempData { [unowned self] in
                UserDefaults.standard.set(true, forKey: "done")
                tableView.reloadData()
            }
        }
    }
}
    
    
    // MARK: - AlertController
    extension TaskListViewController {
        private func showAlert(with taskList: TaskList? = nil, completion: (() -> Void)? = nil) {
            let alertBuilder = AlertControllerBuilder(
                title: taskList != nil ? "Edit List" : "New List",
                message: "Please set title for new task list"
            )
            
            alertBuilder
                .setTextField(taskList?.title)
                .addAction(title: taskList != nil ? "Update List" : "Save List", style: .default) { [weak self] newValue, _ in
                    if let taskList, let completion {
                        self?.storageManager.edit(taskList, newValue: newValue)
                        completion()
                        return
                    }
                    
                    self?.save(taskList: newValue)
                }
                .addAction(title: "Cancel", style: .destructive)
            
            let alertController = alertBuilder.build()
            present(alertController, animated: true)
        }
        
        private func save(taskList: String) {
            storageManager.save(taskList) { taskList in
                let rowIndex = IndexPath(row: taskLists.index(of: taskList) ?? 0, section: 0)
                tableView.insertRows(at: [rowIndex], with: .automatic)
            }
        }
    }


