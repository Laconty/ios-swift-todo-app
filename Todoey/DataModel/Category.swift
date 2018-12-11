//
//  Category.swift
//  Todoey
//
//  Created by Roman Maklakov on 12/7/18.
//  Copyright © 2018 Roman Maklakov. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var colorHexString: String = "FFFFFF"
    let items = List<Item>()
}
