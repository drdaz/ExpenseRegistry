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
        let expense = generateExpense()
                              
        try! await Persistence.addExpense(expense: expense)
        
        let bgContext = Persistence.container.newBackgroundContext()
        
        let fetchRequest = PersistentExpense.fetchRequest()
        
        let savedExpenses = try! await bgContext.perform(schedule: .immediate) { () -> [PersistentExpense] in
            let results = try bgContext.fetch(fetchRequest)
            return results
        }
        
        // This [].first! will crash if local storage contains no exactly matching objects
        let _ = savedExpenses.filter { savedExpense in
            return (
                savedExpense.filename == expense.filename &&
                savedExpense.date == expense.date &&
                savedExpense.note == expense.note &&
                savedExpense.title == expense.title &&
                savedExpense.total == expense.total &&
                savedExpense.currency == expense.currency
            )
        }.first!
        
    }
    
    func testGetExpenses() async throws {
        // Add some expenses, make sure they're in the output of the get method
        var expenses = [Expense]()
        
        for _ in 1...5 { expenses.append(generateExpense()) }
        
        await withThrowingTaskGroup(of: Void.self, returning: Void.self) { group in
            for expense in expenses {
                group.addTask {
                    try await Persistence.addExpense(expense: expense)
                }
            }
        }

        
        let savedExpenses = try await Persistence.getExpenses()
        
        let savedSet = Set(savedExpenses)
        let inputSet = Set(expenses)
        
        XCTAssert(inputSet.isSubset(of: savedSet))
        
    }
    
    func testAddExpenseTriggersCallback() async throws {
        // Save an expense and catch the callback
        
        let expense = generateExpense()
        
        let expect = expectation(description: "Added callback should fire")
        Persistence.onExpenseAdded = { exp in
            XCTAssert(expense == exp)
            expect.fulfill()
        }
        
        try await Persistence.addExpense(expense: expense)
        
        await waitForExpectations(timeout: 5)
        
        Persistence.onExpenseAdded = nil
    }
}


// MARK: Helpers

extension ExpenseRegistryTests {
    
    func generateExpense() -> Expense {
        let fileName = UUID().uuidString
        let date = Date.now
        let note = UUID().uuidString
        let title = UUID().uuidString
        let total = Float.random(in: 0...1337)
        let currency = ["EUR", "USD", "DKK", "GBP"].randomElement()
        
        let expense = Expense(filename: fileName,
                              currency: currency,
                              date: date,
                              note: note,
                              title: title,
                              total: total)
        return expense
    }
    
}
