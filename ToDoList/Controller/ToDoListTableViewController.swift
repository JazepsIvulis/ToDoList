//
//  ToDoListTableViewController.swift
//  ToDoList
//
//  Created by jazeps.ivulis on 19/04/2023.
//

import UIKit
import CoreData

class ToDoListTableViewController: UITableViewController {
    
    var manageObjectContext: NSManagedObjectContext?
    var toDoLists = [ToDo]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        manageObjectContext = appDelegate.persistentContainer.viewContext
        
        loadData()
    }
    
    func loadData() {
        let request: NSFetchRequest<ToDo> = ToDo.fetchRequest()
        
        do {
            let result = try manageObjectContext?.fetch(request)
            toDoLists = result!
            tableView.reloadData()
        }catch{
            fatalError("Error in saving item into ToDo")
        }
    }
    
    func saveData() {
        do {
            try manageObjectContext?.save()
        }catch{
            fatalError("Error in saving item into ToDo")
        }
        loadData()
    }
    
    func deleteAllCoreData() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ToDo")
        
        let entityRequest: NSBatchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try manageObjectContext?.execute(entityRequest)
            saveData()
        }catch let error{
            print(error.localizedDescription)
            fatalError("Error in deleting core data")
        }
    }

    @IBAction func addNewItemTapped(_ sender: Any) {
        let alertController = UIAlertController(title: "To Do List", message: "Do you want to add a new to do item?", preferredStyle: .alert)
        alertController.addTextField { textInfo in
            textInfo.placeholder = "Main title"
            print(textInfo)
        }
        alertController.addTextField { subtextInfo in
            subtextInfo.placeholder = "Task description"
        }
        
        let addActionButton = UIAlertAction(title: "Add", style: .default) { alertAction in
            let textField = alertController.textFields?.first
            let subtextField = alertController.textFields?.last
            let entity = NSEntityDescription.entity(forEntityName: "ToDo", in: self.manageObjectContext!)
            let list = NSManagedObject(entity: entity!, insertInto: self.manageObjectContext)
            
            list.setValue(textField?.text, forKey: "item")
            list.setValue(subtextField?.text, forKey: "subitem")
            self.saveData()
        }
        
        let cancelButton = UIAlertAction(title: "Cancel", style: .destructive)
        
        alertController.addAction(addActionButton)
        alertController.addAction(cancelButton)
        
        present(alertController, animated: true)
    }//addNewItemTapped
    
    @IBAction func deleteAllItemsTapped(_ sender: Any) {
        let alertController = UIAlertController(title: "Delete all data", message: "Do you want to delete your list?", preferredStyle: .actionSheet)
        
        let deleteActionButton = UIAlertAction(title: "Delete", style: .default) { deleteAction in
            self.deleteAllCoreData()
        }
        
        let cancelActionButton = UIAlertAction(title: "Cancel", style: .destructive)
        
        alertController.addAction(deleteActionButton)
        alertController.addAction(cancelActionButton)
        
        present(alertController, animated: true)
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return toDoLists.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "toDoCell", for: indexPath)

        let toDoItem = toDoLists[indexPath.row]
        cell.textLabel?.text = toDoItem.value(forKey: "item") as? String
        cell.detailTextLabel?.text = toDoItem.value(forKey: "subitem") as? String
        cell.accessoryType = toDoItem.completed ? .checkmark : .none

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        toDoLists[indexPath.row].completed = !toDoLists[indexPath.row].completed
        saveData()
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            manageObjectContext?.delete(toDoLists[indexPath.row])
        }
        saveData()
    }

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
