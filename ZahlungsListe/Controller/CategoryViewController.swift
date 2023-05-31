//
//  ViewController.swift
//  ZahlungList
//
//  Created by Heba Thabet Agha on 24.01.23.
//
//hi

import UIKit
import RealmSwift
import SwipeCellKit
import ChameleonFramework

//customizing the cell
class CaregoryCell: SwipeTableViewCell{
    
    @IBOutlet weak var name: UILabel!
    
    @IBOutlet weak var value: UILabel!
}


class CategoryViewController: UITableViewController, SwipeTableViewCellDelegate{
//    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("cat.plist")
//    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
  //  var categoryArray : Results<Category>?
    var categoryArray : [Category]?
    var payingactArray = [PayingAct]()
    var totalPaying = 0
    let realm = try! Realm()
    let userDefaults = UserDefaults.standard
    let categoryMG = CategoryManager()

    

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 80
        categoryArray = categoryMG.loadCategories()
        tableView.reloadData()
        
        //loadCategories()

        print(Realm.Configuration.defaultConfiguration.fileURL)
      //  print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        // Do any additional setup after loading the view.
        
        print("*****************")
        getExpenses()
    }
    
//in order to refrech data when adding new item and going back
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
//load in core data
//    func  loadCategories() {
//        // Create a fetch request for a specific Entity type
//        let fetchRequest: NSFetchRequest<Category> = Category.fetchRequest()
//
//        // Fetch all objects of one Entity type
//        do {
//        categoryArray = try context.fetch(fetchRequest)
//        }
//        catch {
//            print("error fetching data")
//        }
//        tableView.reloadData()
//    }
  
//    func  loadCategories() -> [Category] {
//        categoryArray = realm.objects(Category.self)
//        return Array(categoryArray!)
//        tableView.reloadData()
//    }
    
    func saveData(cat: Category) {
        do {
            try  realm.write {
                 realm.add(cat)
            }
        } catch {
            print("error trying save data")
        }
    }
    
    
    @IBAction func addCatButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "adding", style: .default) { action1 in
           //what will happen when the user click the adding button on our alert
            let newCat = Category()
            newCat.name = textField.text!
            newCat.color = UIColor.randomFlat().hexValue()
            self.saveData(cat: newCat)
            self.tableView.reloadData()
        }
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "add new Category here"
            textField = alertTextField
        }

        alert.addAction(action)
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: {
            action in
                 // Called when user taps outside
        }))
        present(alert, animated: true, completion: nil)
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray?.count ?? 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath) as! CaregoryCell
        
        cell.delegate = self
        if let cat = categoryArray?[indexPath.row]{
            let p = getPaying(category: cat)
            cell.name.text = cat.name
            cell.value.text = String(p)+" $"
           // cell.backgroundColor = UIColor(hexString: cat.color)
           // cell.name.textColor = ContrastColorOf(backgroundColor: cell.backgroundColor!, returnFlat: true)
           // cell.value.textColor  = ContrastColorOf(backgroundColor: cell.backgroundColor!, returnFlat: true)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }

        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            // handle action by updating model with deletion
            self.updateModel(at: indexPath)
            print("deleted")
          //  tableView.reloadData()
        }

        // customize the action appearance
        deleteAction.image = UIImage(named: "delete-icon")

        return [deleteAction]
    }
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .destructive
        options.transitionStyle = .border
        return options
    }
    
     func updateModel(at indexPath: IndexPath) {
        do {
            try self.realm.write {
                self.realm.delete(self.categoryArray![indexPath.row])
            }
        } catch {
            print("error deleting Category,\(error)")
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToPayingAct", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! PayingActTableViewController
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categoryArray?[indexPath.row]
        }
    }
        
    
//    func savedata() {
//    do {
//        try  context.save()
//        }
//        catch {
//            print ("error saving msg, \(error)")
//
//        }
//        self.tableView.reloadData()
//    }
    
    
//    func calculateSum() {
//        var sume : Int = 0
//        for i in payingActArry {
//            if i.parentCat?.name == selectedCategory?.name {
//                sume = sume + Int(i.amount)
//            }
//        }
//        Sum.text = String(sume)
//
//    }
 //core data
//    func getPaying(category: Category) -> Int {
//        var sum : Int = 0
//        // Create a fetch request for a specific Entity type
//        let fetchRequest: NSFetchRequest<PayingAct> = PayingAct.fetchRequest()
//        let categoryPredicate = NSPredicate(format: "parentCat.name MATCHES %@", category.name!)
//        fetchRequest.predicate = categoryPredicate
//        // Fetch all objects of one Entity type
//        do {
//            payingactArray = try context.fetch(fetchRequest)
//            if let payingArray = payingactArray as [PayingAct]? {
//
//                for i in payingArray {
//                    if i.parentCat?.name == category.name {
//                        sum = sum + Int(i.amount)
//                    }
//                }
//
//            }
//        }
//        catch {
//            print("error fetching data")
//        }
//        return sum
//    }
    
    
    
    func getPaying(category: Category) -> Int {
        var sum : Int = 0
        let payingArray = category.payings
                for i in payingArray{
                    sum = sum + Int(i.value)
                }
        return sum
    }
    
    
    func getExpenses() -> [String:Int]
    {
        var cat : [Category]
        var expensesDic:[String:Int] = [:]
        //  var expenses = [("":0)]
        
        categoryArray = categoryMG.loadCategories()
        // need to add if statment for the first run (in case nil)
        cat = Array(categoryArray!)
        for i in 0 ..< cat.count {
            // print(cat[i].name)
            var catPaying = getPaying(category: cat[i])
            expensesDic[cat[i].name] = catPaying
            //expenses.append((cat[i].name, catPaying))
        }
        // print Dictionary
        return expensesDic
    }
    
    
    
    @IBAction func setBudgetPressed(_ sender: UIButton) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Set Budget", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "set", style: .default) { action1 in
            let bud = Budget()
            bud.value  = Int(textField.text!)!
            do {
                try  self.realm.write {
                     self.realm.add(bud)
                }
            } catch {
                print("error trying save data")
            }
        }
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "add Budget here"
            textField = alertTextField
        }
        
        alert.addAction(action)
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: {
            action in
                 // Called when user taps outside
        }))
        present(alert, animated: true, completion: nil)
        
    }
    
    
    
}

