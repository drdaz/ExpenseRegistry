//
//  ExpenseRegistryTests.swift
//  ExpenseRegistryTests
//
//  Created by Darren Black on 02/09/2022.
//

import XCTest
import CoreData

@testable import ExpenseRegistry

class ExpenseRegistryTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testAddExpense() async throws {
        // Add an expense, ensure it's saved in the DB
        let fileName = UUID().uuidString
        let date = Date.now
        let note = UUID().uuidString
        let title = UUID().uuidString
        let total = Float.random(in: 0...1337)
        
        let expense = Expense(filename: fileName,
                              currency: "EUR",
                              date: date,
                              note: note,
                              title: title,
                              total: total)
                              
        try! await Persistence.saveExpense(expense: expense)
        
        try! await Persistence.container.newBackgroundContext().perform(schedule: NSManagedObjectContext.ScheduledTaskType.immediate) {
            
        }
    }

}
