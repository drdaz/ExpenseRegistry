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
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        Task.init {
            expenses = try await Persistence.getExpenses()
            tableView.reloadData()
            Persistence.onExpenseAdded = { [unowned self] exp in
                self.expenses.append(exp)
                self.tableView.reloadRows(at: [IndexPath(item: expenses.endIndex - 1, section: 0)], with: .automatic)
            }
        }
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
    
}
