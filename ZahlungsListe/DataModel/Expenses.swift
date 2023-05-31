//
//  Expenses.swift
//  ZahlungList
//
//  Created by Hiba Agha on 18.05.23.
//

import Foundation

class Expenses {
    
    var expensesDictionay = [String:Int]()
    
    func all()->[String:Int]{
        
        return self.expensesDictionay
    }
    
    func total ()-> Int {
        let totalExpenses = Array(expensesDictionay.values).reduce(0, +)
        return totalExpenses        
    }
    
}



