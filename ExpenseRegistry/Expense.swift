//
//  Expense.swift
//  ExpenseRegistry
//
//  Created by Darren Black on 02/09/2022.
//

import Foundation
import UIKit

struct Expense: Hashable {
    
    var image: UIImage
    var currency: String?
    var date: Date
    var note: String?
    var title: String
    var total: Float
    
}
