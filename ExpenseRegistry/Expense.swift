//
//  Expense.swift
//  ExpenseRegistry
//
//  Created by Darren Black on 02/09/2022.
//

import Foundation

struct Expense: Hashable {
    
    var filename: String
    var currency: String?
    var date: Date
    var note: String?
    var title: String
    var total: Float
    
}
