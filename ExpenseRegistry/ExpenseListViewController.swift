//
//  ViewController.swift
//  ExpenseRegistry
//
//  Created by Darren Black on 02/09/2022.
//

import UIKit

class ExpenseListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var expenses = [Expense]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Persistence.onExpenseAdded = { [unowned self] exp in
            DispatchQueue.main.async {
                self.expenses.append(exp)
                self.tableView.reloadData()
            }
        }
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        Task.init {
            expenses = try await Persistence.getExpenses()
            tableView.reloadData()
        }
        
    }

    @IBAction func addButtonPressed(_ sender: Any) {
        // Show New Expense popover
        performSegue(withIdentifier: "ShowNewExpense", sender: nil)
    }
    
    
}

extension ExpenseListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return expenses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ExpenseCell", for: indexPath)
        var config = cell.defaultContentConfiguration()
        let expense = expenses[indexPath.item]
        config.text = expense.title
        config.secondaryText = expense.date.description
        cell.contentConfiguration = config
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}
