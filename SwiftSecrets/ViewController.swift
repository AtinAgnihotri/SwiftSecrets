//
//  ViewController.swift
//  SwiftSecrets
//
//  Created by Atin Agnihotri on 31/08/21.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var secretsTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI() {
        setupNavBar()
        setupKeyboardAdjustment()
    }
    
    func setupNavBar() {
        title = "Nothing to see here"
    }
    
    func setupKeyboardAdjustment() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    @objc func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            secretsTextView.contentInset = .zero
        } else {
            let adjustedBottomInset = keyboardViewEndFrame.height - view.safeAreaInsets.bottom
            secretsTextView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: adjustedBottomInset, right: 0)
        }
        
        secretsTextView.scrollIndicatorInsets = secretsTextView.contentInset
    }
    

    @IBAction func autheticateTapped(_ sender: UIButton) {
    }
    
}

