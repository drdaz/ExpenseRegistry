//
//  Expense.swift
//  ExpenseRegistry
//
//  Created by Darren Black on 02/09/2022.
//

import Foundation
import UIKit

struct Expense: Hashable {
    
    var image: UIImage {
        get {
            if let filename = filename {
                return Persistence.image(filename: filename)
            }
            else {
                return _img!
            }
        }
    }
    let currency: String?
    let date: Date
    let note: String?
    let title: String
    let total: Float
    
    let filename: String?
    let _img: UIImage?
    
    init(image: UIImage? = nil,
         currency: String?,
         date: Date,
         note: String?,
         title: String,
         total: Float,
         filename: String? = nil) {
        self.currency = currency
        self.date = date
        self.note = note
        self.title = title
        self.total = total
        self.filename = filename
        self._img = image
    }

    static func ==(a: Expense, b: Expense) -> Bool {
        
        let eval = a.image.pngData() == b.image.pngData() &&
        a.currency == b.currency &&
        a.date == b.date &&
        a.note == b.note &&
        a.title == b.title &&
        a.total == b.total

        return eval
        
    }
    
    
}
