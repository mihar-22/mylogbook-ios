
import UIKit
import JVFloatLabeledTextField

class ContactUsController: UIViewController, ActivityView {
    
    var selectedOption = 0
    
    let topics = [
        "I need some help",
        "I'd like to give some feedback",
        "Reporting a bug"
    ]
    
    // MARK: Outlets
    
    @IBOutlet weak var aboutTextField: TextField!
    @IBOutlet weak var messageTextView: JVFloatLabeledTextView!
    
    @IBOutlet var sendButton: UIBarButtonItem!
    
    // MARK: View Lifecycles
    
    override func viewDidLoad() {
        messageTextView.delegate = self
        
        sendButton.isEnabled = false
        
        setupAboutPicker()
    }
    
    // MARK: Actions
    
    @IBAction func didTapCancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapSend(_ sender: UIBarButtonItem) {
        
    }
}

// MARK: Text View Delegate

extension ContactUsController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        sendButton.isEnabled = (textView.text?.characters.count ?? 0) > 0
    }
}

// MARK: Picker View - Delegate + Data Source

extension ContactUsController: UIPickerViewDelegate, UIPickerViewDataSource {
    func setupAboutPicker() {
        let typePicker = UIPickerView()
        
        typePicker.delegate = self
        typePicker.dataSource = self
        
        aboutTextField.text = topics[0]
        aboutTextField.inputView = typePicker
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return topics.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return topics[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        aboutTextField.text = topics[row]
        
        selectedOption = row
    }
}
