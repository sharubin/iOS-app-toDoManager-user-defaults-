//
//  Task.swift
//  To Do manager
//
//  Created by Artsem Sharubin on 06.12.2021.
//

import Foundation


//тип задачи
enum TaskPriority {
    //текущая
    case normal
    //важная
    case important
}

enum TaskStatus: Int {
    //запланированная
    case planed
    //завершенная
    case completed
}

protocol TaskProtocol {
    // название
    var title: String {get set}
    //тип
    var type: TaskPriority {get set}
    // статус
    var status: TaskStatus {get set}
}

//сущность "задача"
struct Task: TaskProtocol {
    var title: String
    var type: TaskPriority
    var status: TaskStatus
}
