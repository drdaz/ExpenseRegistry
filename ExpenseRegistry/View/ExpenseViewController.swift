//
//  ExpenseViewController.swift
//  ExpenseRegistry
//
//  Created by Darren Black on 06/09/2022.
//

import UIKit

class ExpenseViewController: UIViewController {

    var image: UIImage? {
        didSet {
            imageView.image = image
        }
    }
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var currencyField: UITextField!
    @IBOutlet weak var totalField: UITextField!
    @IBOutlet weak var noteField: UITextField!
    
    var mode: Mode = .new
    
    enum Mode {
        case new
        case view(expense: Expense)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        switch (mode) {
        case .new:
            Task.init {
                let capture = PhotoCapture()
                
                do {
                    image = try await capture.captureImage(presenter: self)
                    if image == nil {
                        dismiss(animated: true)
                    }
                }
                catch let e {
                    Shared.UI.presentError(error: e, presenter: self)
                }
                
            }
        case .view(expense: let expense):
            // Populate the fields, switch off interaction
            imageView.image = expense.image
            titleField.text = expense.title
            currencyField.text = expense.currency
            totalField.text = String(expense.total)
            noteField.text = expense.note
            
            [titleField, currencyField, totalField, noteField].forEach { field in
                field?.isUserInteractionEnabled = false
            }
            
            navigationItem.setRightBarButton(nil, animated: false)
            navigationItem.setLeftBarButton(nil, animated: false)
            navigationItem.title = "View Expense"
        }
        
    }

    @IBAction func cancelButtonPressed(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        if let image = image,
           let title = titleField.text,
           let currency = currencyField.text,
           let total = totalField.text,
           let totalFloat = Float(total)
        {
            let expense = Expense(image: image,
                                  currency: currency,
                                  date: Date.now,
                                  note: noteField.text,
                                  title: title,
                                  total: totalFloat)
            Task.init {
                do {
                    try await Persistence.addExpense(expense: expense)
                    dismiss(animated: true)
                }
                catch let e {
                    // Display an error
                    Shared.UI.presentError(error: e, presenter: self)
                }

            }
        }
        else {
            // Display an error
            Shared.UI.presentError(error: Error.missingArgs, presenter: self)
        }
    }
    
    enum Error: LocalizedError {
        case missingArgs
        case missingCamera
        
        var errorDescription: String? {
            switch (self) {
            case .missingArgs:
                return "Please provide values for title, currency and total."
            case .missingCamera:
                return "Sorry, your device needs a camera"
            }
        }
        
    }
    
}


fileprivate class PhotoCapture: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    private typealias PhotoContinuation = CheckedContinuation<UIImage?, Error>
    private var photoChosenContinuation: PhotoContinuation!
    
    func captureImage(presenter: UIViewController) async throws -> UIImage? {
        return try await withCheckedThrowingContinuation({ [unowned self] cont in
            photoChosenContinuation = cont
            let picker = UIImagePickerController()
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                picker.sourceType = .camera
                picker.delegate = self
                presenter.present(picker, animated: true)
            }
            else {
                cont.resume(throwing: ExpenseViewController.Error.missingCamera)
            }
        })
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let photo = info[.originalImage] as! UIImage
        photoChosenContinuation.resume(returning: photo)
        picker.dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        photoChosenContinuation.resume(returning: nil)
        picker.dismiss(animated: true)
    }
    

}
