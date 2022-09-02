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

    static func saveExpense(expense: Expense) async throws {
        fatalError("Not implemented yet")
    }
    
    static func getExpenses() async throws -> [Expense] {
        fatalError("Not implemented yet")
    }
    
    static func getExpense(index: Int) async throws -> Expense {
        fatalError("Not implemented yet")
    }
    
    static func getExpense(id: Int64) async throws -> Expense {
        fatalError("Not implemented yet")
    }
}


