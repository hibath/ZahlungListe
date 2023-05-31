//
//  CategoryRepositoryInterface.swift
//  ZahlungList
//
//  Created by Hiba Agha on 18.05.23.
//

import Foundation


protocol CategoryRepositoryProtocol  {
    
    func loadCategories() -> [Category]
    
    func getPaying(category: Category) -> Int
    
    func getExpenses() -> Expenses
    
    func saveData(category: Category)

}
