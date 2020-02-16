//
//  LoginViewController.swift
//  DOITTarasenko
//
//  Created by Valeiia Tarasenko on 2/11/20.
//  Copyright © 2020 Mac. All rights reserved.
//

import UIKit

class LoginViewController: BasicViewController {

    @IBOutlet private weak var emailTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    @IBOutlet private weak var confirmPasswordTextField: UITextField!
    @IBOutlet private weak var loginSwitch: UISwitch!
    @IBOutlet private weak var loginDescriptionLabel: UILabel!
    @IBOutlet private weak var loginTitleLabel: UILabel!
    @IBOutlet private weak var lodinButton: UIButton!
    
    private var userManager: UserManager?

    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        userManager = DIContainer.defaultResolver.resolve(UserManager.self)!
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if userManager?.user != nil {
            presentTaskList()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        emailTextField.text = ""
        passwordTextField.text = ""
        confirmPasswordTextField.text = ""
    }
    
    @IBAction func switchLoginTap(_ sender: Any) {
        if loginSwitch.isOn {
            loginTitleLabel.text = "Sign up"
            lodinButton.setTitle("REGISTER", for: .normal)
            confirmPasswordTextField.isHidden = false
            passwordTextField.returnKeyType = .next
            passwordTextField.textContentType = .newPassword
        } else {
            loginTitleLabel.text = "Sign in"
            lodinButton.setTitle("LOG IN", for: .normal)
            confirmPasswordTextField.isHidden = true
            passwordTextField.returnKeyType = .done
            passwordTextField.textContentType = .password
        }
    }
    
    @IBAction private func loginButtonTap(_ sender: Any) {
        guard let mail = emailTextField.text, isValidEmail(mail), !mail.isEmpty  else {
            showErrorMessage("Enter valid email")
            return
        }
        guard let password = passwordTextField.text, !password.isEmpty else {
            showErrorMessage("Enter password")
            return
        }
        let _ = loginSwitch.isOn ? signUpAuth(mail: mail, password: password) : loginAuth(mail: mail, password: password)
    }
    
    private func loginAuth(mail: String, password: String) {
        userManager?.login(mail: mail, password: password) { [weak self] (result) in
            guard let `self` = self else { return }
            self.autentification(result: result)
        }
    }
    
    private func signUpAuth(mail: String, password: String) {
        guard let confirmPassword = confirmPasswordTextField.text, !confirmPassword.isEmpty,
            password == confirmPassword else {
            showErrorMessage("Your password and confirmation password do not match")
            return
        }
        
        userManager?.signUp(mail: mail, password: password) { [weak self] (result) in
            guard let `self` = self else { return }
            self.autentification(result: result)
        }
    }
    
    private func autentification(result: Result<User, AppError>) {
        switch result {
        case .success(_):
            self.presentTaskList()
        case let .failure(error):
            self.showErrorMessage(error.localizedDescription)
        }
    }
    
    private func presentTaskList() {
        let storyBoard: UIStoryboard = UIStoryboard(name: "TasksList", bundle: nil)
        guard let navigationController = storyBoard.instantiateViewController(withIdentifier: "NavController") as? UINavigationController else { return }
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true)
    }
    
    private func isValidEmail(_ mail: String) -> Bool {
        guard !mail.isEmpty else { return true }
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: mail)
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case emailTextField:
            passwordTextField.becomeFirstResponder()
        case passwordTextField:
            if loginSwitch.isOn {
                confirmPasswordTextField.becomeFirstResponder()
            } else {
                view.endEditing(true)
                loginButtonTap(textField)
            }
        case confirmPasswordTextField:
            view.endEditing(true)
            loginButtonTap(textField)
        default:
            return false
        }
        
        return true
    }
}
