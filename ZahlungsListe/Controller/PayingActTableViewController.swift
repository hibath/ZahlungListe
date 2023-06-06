//
//  PayingActTableViewController.swift
//  ZahlungList
//
//  Created by Heba Thabet Agha on 24.01.23.
//

import UIKit
import RealmSwift
import SwipeCellKit
import ChameleonFramework


class PayingCell: SwipeTableViewCell {
    
    @IBOutlet weak var name: UILabel!
    
    @IBOutlet weak var value: UILabel!
}


class PayingActTableViewController: UITableViewController, SwipeTableViewCellDelegate {
    
    let realm = try! Realm()
    @IBOutlet weak var sum: UILabel!
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("payingAct.plist")
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var payingActArry : Results<PayingAct>?
    var selectedCategory : Category?
    var payingActManager = PayingActManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadPayingact()
        let totalPaying = payingActManager.calculateSum(parentCategory: selectedCategory!)
        sum.text = "Total: "+String(totalPaying)+" $"
        tableView.rowHeight = 80
    }
    
    
    // MARK: - Table view data source

    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return payingActArry?.count ?? 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PayingActCell", for: indexPath) as! PayingCell
        cell.delegate = self
        if let payingAct = payingActArry?[indexPath.row] {
            cell.name.text = payingAct.title
            cell.value.text = String(payingAct.value)+" $"
        }
        return cell
        
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }

        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            // handle action by updating model with deletion
            self.updateModel(at: indexPath)
            print("deleted")
            // handle action by updating model with deletion
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
               self.realm.delete(self.payingActArry![indexPath.row])
           }
       } catch {
           print("error deleting Category,\(error)")
       }
   }
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField1 = UITextField()
        var textField2 = UITextField()
        let alert = UIAlertController(title: "Add New paying", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "adding", style: .default) { action1 in
           //what will happen when the user click the adding button on our alert
            do {
                try self.realm.write{
                    let newpay = PayingAct()
                    newpay.title = textField1.text!
                    newpay.value = Int(textField2.text!) ?? 0
                    self.selectedCategory?.payings.append(newpay)
                }
            }
            catch{
                print("error saving pays")
            }
            self.tableView.reloadData()
            self.calculateSum()
        }
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "add new paying here"
            textField1 = alertTextField
        }

        alert.addTextField { alertTextField in
            alertTextField.placeholder = "add the value here"
            textField2 = alertTextField
        }

        alert.addAction(action)
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: {
            action in
                 // Called when user taps outside
        }))
        present(alert, animated: true, completion: nil)
    }
    
    func loadPayingact(){
        payingActArry = selectedCategory?.payings.sorted(byKeyPath: "title")
        tableView.reloadData()
    }
    

    func calculateSum() {
        var sume : Int = 0
        if let paying = selectedCategory?.payings {
            for i in paying{
                    sume = sume + Int(i.value)
                }
            }
        sum.text = "Total: "+String(sume)+" $"
    }
    
}
