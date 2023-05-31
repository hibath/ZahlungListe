//
//  Category.swift
//  ZahlungList
//
//  Created by Heba Thabet Agha on 03.02.23.
//

import Foundation
import RealmSwift

class Category : Object{
    
    @objc dynamic var name: String = ""
    @objc dynamic var color: String = ""
    var payings = List<PayingAct>()
}
