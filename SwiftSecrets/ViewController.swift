//
//  ViewController.swift
//  SwiftSecrets
//
//  Created by Atin Agnihotri on 31/08/21.
//

import UIKit
import SwiftKeychainWrapper
import LocalAuthentication

class ViewController: UIViewController {
    
    let SECRET_KEY = "SWIFT_SECRETS_MESSAGE"
    let AUTH_PASS_KEY = "SWIFT_SECRETS_PWD"

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
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Identify yourself"
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { [weak self] success, authError in
                DispatchQueue.main.async {
                    if success {
                        self?.unlockSecretMessage()
                    } else {
                        self?.showError(title: "Authentication Failed", message: "You could not be verified. Please try again!")
                    }
                }
            }
        } else {
            let ok = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
                self?.handlePasswordValidation()
            }
            showAlert(title: "Biometry Unavailable", message: "Your device is not configured for biometric authentication", actions: [ok])
        }
    }
    
    func handlePasswordValidation() {
        if let pwd = KeychainWrapper.standard.string(forKey: AUTH_PASS_KEY) {
            let ac = UIAlertController(title: "Enter Password", message: nil, preferredStyle: .alert)
            ac.addTextField()
            let confirm = UIAlertAction(title: "Confirm", style: .default) { [weak self, weak ac] _ in
                guard let userInput = ac?.textFields?[0].text else {
                    self?.showError(title: "Authentication Failed", message: "Password cannot be empty")
                    return
                }
                if pwd == userInput {
                    self?.unlockSecretMessage()
                } else {
                    self?.showError(title: "Authentication Failed", message: "You could not be verified. Please try again!")
                }
            }
            ac.addAction(confirm)
            present(ac, animated: true)
        } else {
            promptPasswordCreation()
        }
    }
    
    func promptPasswordCreation() {
        let ac = UIAlertController(title: "Create Password", message: "Enter your password. Use at least 6 characters.", preferredStyle: .alert)
        ac.addTextField()
        
        let confirm = UIAlertAction(title: "Confirm", style: .default) { [weak self, weak ac] _ in
            guard let userInput = ac?.textFields?[0].text else {
                fatalError("Password Creation Alert has no text fields")
            }
            guard !userInput.isEmpty else {
                self?.showError(title: "Password Creation Failed", message: "Password cannot be empty")
                return
            }
            guard userInput.count > 5 else {
                self?.showError(title: "Password Creation Failed", message: "Password should have at least 6 characters")
                return
            }
            self?.promptPasswordConfirmation(for: userInput)
        }
        
        ac.addAction(confirm)
        present(ac, animated: true)
    }
    
    func promptPasswordConfirmation(for firstInput: String) {
        let ac = UIAlertController(title: "Create Password", message: "Confirm your password", preferredStyle: .alert)
        ac.addTextField()
        
        let confirm = UIAlertAction(title: "Confirm", style: .default) { [weak self, weak ac] _ in
            guard let userInput = ac?.textFields?[0].text else {
                fatalError("Password Creation Alert has no text fields")
            }
            guard !userInput.isEmpty else {
                self?.showError(title: "Password Creation Failed", message: "Password cannot be empty")
                return
            }
            guard userInput == firstInput  else {
                self?.showError(title: "Password Creation Failed", message: "The confirmation input not the same as first input")
                return
            }
            if let AUTH_PASS_KEY = self?.AUTH_PASS_KEY {
                KeychainWrapper.standard.set(userInput, forKey: AUTH_PASS_KEY)
            }
        }
        
        ac.addAction(confirm)
        present(ac, animated: true)
    }
    
    func unlockSecretMessage() {
        secretsTextView.isHidden = false
        title = "Swift Secrets"
        
        let text = KeychainWrapper.standard.string(forKey: SECRET_KEY) ?? ""
        secretsTextView.text = text
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(saveSecretMessage))
    }
    
    @objc func saveSecretMessage() {
        guard !secretsTextView.isHidden else { return }
        navigationItem.rightBarButtonItem = nil
        KeychainWrapper.standard.set(secretsTextView.text, forKey: SECRET_KEY)
        secretsTextView.resignFirstResponder()
        secretsTextView.isHidden = true
        title = "Nothing to see here"
    }
    
    func showError(title: String, message: String? = nil) {
        showAlert(title: "🚨 " + title, message: message)
    }
    
    func showAlert(title: String, message: String? = nil, actions: [UIAlertAction] = []) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        if actions.isEmpty {
            let ok = UIAlertAction(title: "OK", style: .default)
            ac.addAction(ok)
        } else {
            actions.forEach { [weak ac] action in
                ac?.addAction(action)
            }
        }
        
        present(ac, animated: true)
    }
    
}

