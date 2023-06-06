//
//  CategoryManager.swift
//  ZahlungList
//
//  Created by Heba Thabet Agha on 15.05.23.
//

import Foundation
import RealmSwift

class CategoryManager  {
    let realm = try! Realm()
    
    func  loadCategories() -> [Category] {

        let categoryArray = realm.objects(Category.self)
        return Array(categoryArray)
    }
    
    func getPaying(category: Category) -> Int {
        var sum : Int = 0
        // // Iterate through the category to calculate4 the total expense
        let payingArray = category.payings
                for i in payingArray{
                    sum = sum + Int(i.value)
                }
        return sum
    }
    
    
    func getExpenses() -> Expenses
    {
        let expenses = Expenses()
        // dictionary, key: category name, value: total expenses for the category
        var expensesDic:[String:Int] = [:]
        let categoryArray = loadCategories()
        // need to add if statment for the first run (in case nil) 
        // Iterate through each category and get the expense
        //Adds an entry to the `expensesDic` dictionary with the category name as the key and the total expense as the value.
        for i in 0 ..< categoryArray.count {
            let catPaying = getPaying(category: categoryArray[i])
            expensesDic[categoryArray[i].name] = catPaying
        }
        expenses.expensesDictionay = expensesDic
        return expenses
    }
    
    
    func saveData(category: Category) {
        do {
            try  realm.write {
                realm.add(category)
            }
        } catch {
            print("error trying save data")
        }
    }

    
}
