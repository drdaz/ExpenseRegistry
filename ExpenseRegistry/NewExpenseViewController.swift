//
//  NewExpenseViewController.swift
//  ExpenseRegistry
//
//  Created by Darren Black on 06/09/2022.
//

import UIKit

class NewExpenseViewController: UIViewController {

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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        Task.init {
            let capture = PhotoCapture()
            image = await capture.captureImage(presenter: self)
            if image == nil {
                dismiss(animated: true)
            }
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
            let filename = UUID().uuidString
            let expense = Expense(filename: filename,
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
                    print("TODO: Display a persistence error: \(e.localizedDescription)")
                }

            }
        }
        else {
            // Display an error
            print("TODO: Display a validation error")
        }
    }
    
}


fileprivate class PhotoCapture: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    private typealias PhotoContinuation = CheckedContinuation<UIImage?, Never>
    private var photoChosenContinuation: PhotoContinuation!
    
    func captureImage(presenter: UIViewController) async -> UIImage? {
        return await withCheckedContinuation({ [unowned self] cont in
            photoChosenContinuation = cont
            let picker = UIImagePickerController()
            picker.sourceType = .camera
            picker.delegate = self
            presenter.present(picker, animated: true)
        })
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let photo = info[.originalImage] as? UIImage
        photoChosenContinuation.resume(returning: photo)
        picker.dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        photoChosenContinuation.resume(returning: nil)
        picker.dismiss(animated: true)
    }
    
}
