//
//  Extension + UITableViewCell.swift
//  RealmApp
//
//  Created by Zaki on 01.06.2023.
//

import UIKit

extension UITableViewCell {
    func configure(with taskList: TaskList) {
        let currentTask = taskList.tasks.filter("isComplete = false")
        var content = defaultContentConfiguration()
        
        content.text = taskList.title
        
        if taskList.tasks.isEmpty {
            content.secondaryText = "0"
            accessoryType = .none
        } else if currentTask.isEmpty {
            content.secondaryText = nil
            accessoryType = .checkmark
        } else {
            content.secondaryText = currentTask.count.formatted()
            accessoryType = .none
        }
        
        contentConfiguration = content
    }
}
