//
//  Persistence.swift
//  ExpenseRegistry
//
//  Created by Darren Black on 02/09/2022.
//

import Foundation
import CoreData

struct Persistence {
    
    internal static var container: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "ExpenseRegistry")
        container.loadPersistentStores { _, err in
            if let err = err as NSError? {
                fatalError("Unexpected error \(err), \(err.userInfo)")
            }
        }
        return container
    }()

    static func addExpense(expense: Expense) async throws {
        let bgContext = container.newBackgroundContext()
        try await bgContext.perform(schedule: .immediate) {
            
            let persistentExpense = PersistentExpense(context: bgContext)
            persistentExpense.currency = expense.currency
            persistentExpense.total = expense.total
            persistentExpense.note = expense.note
            persistentExpense.filename = expense.filename
            persistentExpense.date = expense.date
            persistentExpense.title = expense.title
            
            try bgContext.save()
        }
    }
    
    static func getExpenses() async throws -> [Expense] {
        fatalError("Not implemented yet")
    }
    
    static func getExpense(index: Int) async throws -> Expense {
        fatalError("Not implemented yet")
    }
    
}
