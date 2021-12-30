//
//  TaskListController.swift
//  To Do manager
//
//  Created by Artsem Sharubin on 07.12.2021.
//

import UIKit

class TaskListController: UITableViewController {
    //хранилише задач
    var tasksStorage: TasksStorageProtocol = TasksStorage()
    var tasksStatusPosition: [TaskStatus] = [.planed, .completed]
        //сортировка списка задач
    //коллекции задач
    var tasks: [TaskPriority:[TaskProtocol]] = [:] {
        didSet {
            
            for (tasksGroupPriority, tasksGroup) in tasks {
             tasks[tasksGroupPriority] = tasksGroup.sorted { task1, task2 in
                    let task1position = tasksStatusPosition.firstIndex(of: task1.status) ?? 0
                    let task2posotion = tasksStatusPosition.firstIndex(of: task2.status) ?? 0
                    return task1position < task2posotion
                        }
                    }
            
            //сохранение задач
            var savingArray: [TaskProtocol] = []
            tasks.forEach { _, value in
                savingArray += value
            }
            tasksStorage.saveTasks(savingArray)
    }
    }

    //порядок отображения секции по типам
    //индекс в массиве соответсвует индексу секции в таблице
    var sectionsTypesPosition: [TaskPriority] = [.important, .normal]
        
        override func viewDidLoad() {
            super.viewDidLoad()
            // загрузка задач
            loadTasks()
            //кнопка активации режима редактирования
            navigationItem.leftBarButtonItem = editButtonItem
        }
        
        private func loadTasks() {
            // подготовка коллекции с задачами
            //будем использовать только те задачи, для которых определена секция в таблице
            sectionsTypesPosition.forEach { taskType in
                tasks[taskType] = []
            }
            // загрузка и разбор задач из хранилища
            tasksStorage.loadTasks().forEach { task in
                tasks[task.type]?.append(task)
            }
        }
    
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return tasks.count
    }
// колличество строк в определенной секции
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // определяем приоритет задач, соответсвующий текущей секции
        let taskType = sectionsTypesPosition[section]
        guard let currentTasksType = tasks[taskType] else {
            return 0
        }
        return currentTasksType.count
    }
    
    // ячейка для строки таблицы
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // ячейка на основе констрейтов
        //return getConfiguredTaskCell_constraints(for: indexPath)
        
        //ячейка на основе стека
        return getConfiguredTaskCell_stack(for: indexPath)
    }
    
    //ячейка на основе ограничений
    private func getConfiguredTaskCell_constraints(for indexPath: IndexPath) -> UITableViewCell {
        // загружаем прототип ячейки по идентификатору
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCellConstraints", for: indexPath)
        //получаем данные о задаче,  которую необходимо вывести в ячейке
        let taskType = sectionsTypesPosition[indexPath.section]
        guard let currentTask = tasks[taskType]?[indexPath.row] else {
            return cell
        }
        
        //текстовая метка символа
        let symbolLabel = cell.viewWithTag(1) as? UILabel
        //текстовая метка названия задачи
        let textLabel = cell.viewWithTag(2) as? UILabel
        
        //изменяем символ в ячейке
        symbolLabel?.text = getSymbolForTask(with: currentTask.status)
        //изменеяем текст в ячейке
        textLabel?.text = currentTask.title
        
        //изменеяем цвет текста и символа
        if currentTask.status == .planed {
            textLabel?.textColor = .black
            symbolLabel?.textColor = .black
        } else {
            textLabel?.textColor = .lightGray
            symbolLabel?.textColor = .lightGray
        }
        return cell
    }
    
    //ячейка на основе стека
    private func getConfiguredTaskCell_stack(for indexPath: IndexPath) -> UITableViewCell {
        //загружаем прототип ячейки по идентификатору
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCellStack", for: indexPath) as! TaskCell
        //получаем данные о задаче, которую необходимо вывести в ячейке
        let taskType = sectionsTypesPosition[indexPath.section]
        guard let currentTask = tasks[taskType]?[indexPath.row] else {
            return cell
        }
        
        //изменяем текст в ячейке
        cell.title.text = currentTask.title
        //изменяем символ в ячейке
        cell.symbol.text = getSymbolForTask(with: currentTask.status)
        
        //изменяем цвет текста
        if currentTask.status == .planed {
            cell.title.textColor = .black
            cell.symbol.textColor = .black
        } else {
            cell.title.textColor = .lightGray
            cell.symbol.textColor = .lightGray
        }
        return cell
    }
    
    //возвращаем символ для соответсвующего типа задачи
    private func getSymbolForTask(with status: TaskStatus) -> String {
        var resultSymbol: String
        if status == .planed {
            resultSymbol = "\u{25CB}"
        } else if status == .completed {
            resultSymbol = "\u{25C9}"
        } else {
            resultSymbol = ""
        }
        return resultSymbol
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var title: String?
        let tasksType = sectionsTypesPosition[section]
        if tasksType == .important {
            title = "Важные"
        } else if tasksType == .normal {
            title = "Текущие"
        }
         return title
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //1) проверяем существование задачи
        let taskType = sectionsTypesPosition[indexPath.section]
        guard let _ = tasks[taskType]?[indexPath.row] else {
            return
        }
        //2)убеждаемся что задача не является выполненной
        guard tasks[taskType]![indexPath.row].status == .planed else {
            //снимаем выделение со строки
            tableView.deselectRow(at: indexPath, animated: true)
            return
        }
        //3) отмечаем задачу как выполненую
        tasks[taskType]![indexPath.row].status = .completed
        //4) перезагружаем секцию таблицы
        tableView.reloadSections(IndexSet(arrayLiteral: indexPath.section), with: .automatic)
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        //получаем данные о задаче,по которой осуществлен свайп
        let taskType = sectionsTypesPosition[indexPath.section]
        guard let _ = tasks[taskType]?[indexPath.row] else {
            return nil
        }
       
        //создаем дейсвтие после изменения статуса
        let actionSwipeInstance = UIContextualAction(style: .normal, title: "не выполнена") { _, _, _ in
            self.tasks[taskType]![indexPath.row].status = .planed
            self.tableView.reloadSections(IndexSet(arrayLiteral: indexPath.section), with: .automatic)
        }
        //действие для перехода к экрану редактирования
        let actionEditInstance = UIContextualAction(style: .normal, title: "изменить") { _, _ ,_ in
            //загрузка сцены со сториборд
            let editScreen = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TaskEditController") as! TaskEditController
            //передача значений редактируемой задачи
            editScreen.taskText = self.tasks[taskType]![indexPath.row].title
            editScreen.taskType = self.tasks[taskType]![indexPath.row].type
            editScreen.taskStatus = self.tasks[taskType]![indexPath.row].status
            //передача обработчика для сохранения задачи
        editScreen.doAfterEdit = { [self] title, type, status in
            let editedTask = Task(title: title, type: type, status: status)
            tasks[taskType]![indexPath.row] = editedTask
            tableView.reloadData()
            }
        // переход к экрану редактирования
            self.navigationController?.pushViewController(editScreen, animated: true)
        }
        //изменяем цвет фона кнопки с действием
        actionEditInstance.backgroundColor = .darkGray
        
        //создаем обьект описывающий доступные действия
        //в зависимости от статуса задачи будет отображено 1 или 2 действия
        let actionConfiguration: UISwipeActionsConfiguration
        if tasks[taskType]![indexPath.row].status == .completed {
            actionConfiguration = UISwipeActionsConfiguration(actions: [actionSwipeInstance, actionEditInstance])
        } else {
            actionConfiguration = UISwipeActionsConfiguration(actions: [actionEditInstance])
        }
        return actionConfiguration
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        //удаляем строку, соответсвующую задаче
        //tableView.deleteRows(at: [indexPath], with: .automatic)
        let taskType = sectionsTypesPosition[indexPath.section]
        //удаляем задачу
        tasks[taskType]?.remove(at: indexPath.row)
        //удаляем строку соответсвующую задаче
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        //секция из которой происходит перемещение
        let taskTypeFrom = sectionsTypesPosition[sourceIndexPath.section]
        //секция в которую происходит перемещение
        let taskTypeTo = sectionsTypesPosition[destinationIndexPath.section]
        
        //,безопасно извлекаем задачу и тем самым копируем ее
        guard let movedTask = tasks[taskTypeFrom]?[sourceIndexPath.row] else {
            return
        }
        //удаляем задачу с места откуда она перенесена
        tasks[taskTypeFrom]!.remove(at: sourceIndexPath.row)
        //вставляем задачу на новую позицию
        tasks[taskTypeTo]!.insert(movedTask, at: destinationIndexPath.row)
        // если секция изменилась, изменяем тип задачи в соответсвии с новой позицией
        if taskTypeFrom != taskTypeTo {
            tasks[taskTypeTo]![destinationIndexPath.row].type = taskTypeTo
        }
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toCreateScreen" {
            let destination = segue.destination as! TaskEditController
    destination.doAfterEdit = { [unowned self] title, type, status in
        let newTask = Task(title: title, type: type, status: status)
        tasks[type]?.append(newTask)
        tableView.reloadData()
            }
        }
    }
    
    // получение списка задач, их разбор и установка в свойство tasks
    func setTasks(_ tasksCollection: [TaskProtocol]) {
    // подготовка коллекции с задачами
    // будем использовать только те задачи, для которых определена секция
        sectionsTypesPosition.forEach { taskType in
    tasks[taskType] = [] }
    // загрузка и разбор задач из хранилища
        tasksCollection.forEach { task in
    tasks[task.type]?.append(task) }
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
