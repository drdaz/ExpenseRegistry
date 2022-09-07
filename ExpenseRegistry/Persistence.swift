//
//  Persistence.swift
//  ExpenseRegistry
//
//  Created by Darren Black on 02/09/2022.
//

import Foundation
import CoreData
import UIKit

struct Persistence {
    
    static var container: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "ExpenseRegistry")
        container.loadPersistentStores { _, err in
            if let err = err as NSError? {
                fatalError("Unexpected error \(err), \(err.userInfo)")
            }
        }
        return container
    }()
    
    fileprivate static var context: NSManagedObjectContext = {
        return container.newBackgroundContext()
    }()

    static var onExpenseAdded: ((Expense) -> Void)? {
        didSet {
            listener = onExpenseAdded != nil ? FetchedResultsListener() : nil
        }
    }
    fileprivate static var listener: FetchedResultsListener?
    
    static func addExpense(expense: Expense) async throws {
        
        // Persist the image to disk
        let filename = UUID().uuidString
        let url = URL(fileURLWithPath: dirPath).appendingPathComponent(filename)
        let imgData = expense.image.pngData()!
        try imgData.write(to: url)
        
        let bgContext = context
        try await bgContext.perform(schedule: .immediate) {
            
            let persistentExpense = PersistentExpense(context: bgContext)
            persistentExpense.currency = expense.currency
            persistentExpense.total = expense.total
            persistentExpense.note = expense.note
            persistentExpense.filename = filename
            persistentExpense.date = expense.date
            persistentExpense.title = expense.title
            
            try bgContext.save()
        }
    }
    
    static func getExpenses() async throws -> [Expense] {
        let bgContext = context
        let fetchRequest = PersistentExpense.fetchRequest()
        
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "date", ascending: true)
        ]
        
        let persistentExpenses = try await bgContext.perform(schedule: .immediate, {
            return try bgContext.fetch(fetchRequest)
        })
        
        return persistentExpenses.map { $0.expense }
    }
    
    static func getExpense(index: Int) async throws -> Expense {
        fatalError("Not implemented yet")
    }
    
    
    static var dirPath: String {
        return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
    }
    
    static func image(filename: String) -> UIImage {
        let url = URL(fileURLWithPath: dirPath).appendingPathComponent(filename)
        let data = try! Data(contentsOf: url)
        return UIImage(data: data)!
    }
    
}

fileprivate class FetchedResultsListener: NSObject, NSFetchedResultsControllerDelegate {
    
    var frc: NSFetchedResultsController<PersistentExpense>
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch (type) {
        case .insert:
            let persistentExpense = anObject as! PersistentExpense
            if let handler = Persistence.onExpenseAdded {
                handler(persistentExpense.expense)
            }
        case .delete:
            fatalError("Not implemented")
        case .move:
            fatalError("Not implemented")
        case .update:
            fatalError("Not implemented")
        @unknown default:
            fatalError("Not implemented")
        }
    }
    
    override init() {
        let fetchRequest = PersistentExpense.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        frc = NSFetchedResultsController(fetchRequest: fetchRequest,
                                         managedObjectContext: Persistence.context,
                                         sectionNameKeyPath: nil,
                                         cacheName: nil)
        super.init()
        frc.delegate = self
        try! frc.performFetch()
    }
    
}

fileprivate extension PersistentExpense {
    
    var expense: Expense {
        return Expense(currency: currency,
                       date: date!,
                       note: note,
                       title: title!,
                       total: total,
                       filename: filename)
    }
    
}
