//
//  TasksStorage.swift
//  To Do manager
//
//  Created by Artsem Sharubin on 06.12.2021.
//

import Foundation
//протокол описывающий сущность хранилище задач
protocol TasksStorageProtocol {
    func loadTasks() -> [TaskProtocol]
    func saveTasks(_ tasks: [TaskProtocol])
}
//сущность хранилище задач
class TasksStorage: TasksStorageProtocol {
    //ссылка на хранилище
    private var storage = UserDefaults.standard
    //ключ по которому будет происходить сохранение и загрузка хранилища из user defaults
    var storageKey: String = "tasks"
    
    //перечисление с ключами для записи в user defaults
    private enum taskKey: String {
        case title
        case type
        case status
    }
    
    func loadTasks() -> [TaskProtocol] {
        var resultTasks: [TaskProtocol] = []
        let tasksFromStorage = storage.array(forKey: storageKey) as? [[String:String]] ?? []
        
        for task in tasksFromStorage {
            guard let title = task[taskKey.title.rawValue],
                  let typeRaw = task[taskKey.type.rawValue],
                  let statusRaw = task[taskKey.status.rawValue] else {
                      continue
                  }
            
            let type: TaskPriority = typeRaw == "important" ? .important : .normal
            let status: TaskStatus = statusRaw == "planned" ? .planed : .completed
            resultTasks.append(Task(title: title, type: type, status: status))
        }
        return resultTasks
    }
    
    func saveTasks(_ tasks: [TaskProtocol]) {
        var arrayForStorage: [[String:String]] = []
        tasks.forEach { task in
            var newElementForStorage: Dictionary<String, String> = [:]
            newElementForStorage[taskKey.title.rawValue] = task.title
            newElementForStorage[taskKey.type.rawValue] = (task.type == .important) ? "important" : "normal"
            newElementForStorage[taskKey.status.rawValue] = (task.status == .planed) ? "planned" : "completed"
            arrayForStorage.append(newElementForStorage)
        }
        storage.set(arrayForStorage, forKey: storageKey)
    }
}
