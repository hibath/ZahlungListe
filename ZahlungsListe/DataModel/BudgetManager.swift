//
//  BudgetManager.swift
//  ZahlungList
//
//  Created by Hiba Agha on 18.05.23.
//

import Foundation
import RealmSwift

class BudgetManager {
    
    func getBudget()-> Budget {
        var bud = Budget()
        
        do {
            bud = try Realm().objects(Budget.self).first!
        } catch {
            print("No budget")
        }
        print(String(bud.value))
        return bud
        
    }
}
