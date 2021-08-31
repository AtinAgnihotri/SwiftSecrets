//
//  ViewController.swift
//  SwiftSecrets
//
//  Created by Atin Agnihotri on 31/08/21.
//

import UIKit
import SwiftKeychainWrapper

class ViewController: UIViewController {
    
    let SECRET_KEY = "SWIFT_SECRETS_MESSAGE"

    @IBOutlet var secretsTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        setupNotificationObservers()
    }
    
    func setupNavBar() {
        title = "Nothing to see here"
    }
    
    func setupNotificationObservers() {
        let notificationCenter = NotificationCenter.default
        
        // Keyboard notification observers to adjust secretsTextView insets
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        // Save stuff when user's leaving the app, or going in multitasking mode
        notificationCenter.addObserver(self, selector: #selector(saveSecretMessage), name: UIApplication.willResignActiveNotification, object: nil)
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
        unlockSecretMessage()
    }
    
    func unlockSecretMessage() {
        secretsTextView.isHidden = false
        title = "Swift Secrets"
        
        let text = KeychainWrapper.standard.string(forKey: SECRET_KEY) ?? ""
        secretsTextView.text = text
    }
    
    @objc func saveSecretMessage() {
        guard !secretsTextView.isHidden else { return }
        KeychainWrapper.standard.set(secretsTextView.text, forKey: SECRET_KEY)
        secretsTextView.resignFirstResponder()
        secretsTextView.isHidden = true
        title = "Nothing to see here"
    }
    
}

