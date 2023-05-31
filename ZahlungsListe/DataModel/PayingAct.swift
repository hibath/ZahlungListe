//
//  PayingAct.swift
//  ZahlungList
//
//  Created by Hiba Agha on 03.02.23.
//

import Foundation
import RealmSwift

class PayingAct : Object {
    @objc dynamic var title: String = ""
    @objc dynamic var value: Int = 0
    var parentCategory = LinkingObjects(fromType: Category.self, property: "payings")
}
