//
//  Shared.swift
//  ExpenseRegistry
//
//  Created by Darren Black on 07/09/2022.
//

import UIKit

struct Shared {
    struct UI {
        static func presentError(error: Error, presenter: UIViewController) {
            let alert = UIAlertController(title: "Uh-oh", message: "Something went wrong: \(error.localizedDescription)", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { _ in
                alert.dismiss(animated: false)
            }))
            presenter.present(alert, animated: false)
        }
    }
}

