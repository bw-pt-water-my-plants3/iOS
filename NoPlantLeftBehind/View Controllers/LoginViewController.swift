//
//  LoginViewController.swift
//  NoPlantLeftBehind
//
//  Created by Kenneth Jones on 10/22/20.
//

import UIKit

enum LoginType {
    case signUp
    case signIn
}

class LoginViewController: UIViewController {

    @IBOutlet weak var signUpSignInControl: UISegmentedControl!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var signInButton: UIButton!

    @IBOutlet weak var signUpStack: UIStackView!

    var plantController: PlantController?
    var loginType = LoginType.signUp

    override func viewDidLoad() {
        super.viewDidLoad()

        let imageView = UIImageView(frame: UIScreen.main.bounds)
        imageView.image = UIImage(named: "bush")
        imageView.contentMode = .scaleAspectFill
        self.view.insertSubview(imageView, at: 0)

        signUpStack.backgroundColor = UIColor(white: 1, alpha: 1)
        signUpStack.layer.cornerRadius = 10
        signUpStack.bounds = view.frame.insetBy(dx: 0.0, dy: 10.0)

        signInButton.backgroundColor = UIColor(hue: 190/360, saturation: 70/100, brightness: 80/100, alpha: 1.0)
        signInButton.tintColor = .white
        signInButton.layer.cornerRadius = 8.0
    }

    @IBAction func typeChanged(_ sender: UISegmentedControl) {
        self.view.endEditing(true)

        if sender.selectedSegmentIndex == 0 {
            loginType = .signUp
            signInButton.setTitle("Sign Up", for: .normal)
            phoneNumberTextField.isHidden = false
        } else {
            loginType = .signIn
            signInButton.setTitle("Sign In", for: .normal)
            phoneNumberTextField.isHidden = true
        }
    }

    @IBAction func buttonTapped(_ sender: UIButton) {
        self.view.endEditing(true)

        if let username = usernameTextField.text,
            !username.isEmpty,
            let password = passwordTextField.text,
            !password.isEmpty,
            let phoneNumber = phoneNumberTextField.text,
            !phoneNumber.isEmpty,
            let phoneNum = Int(phoneNumber) {
            let user = User(username: username, password: password, phoneNumber: phoneNum)
            if loginType == .signUp {
                plantController?.signUp(with: user, completion: { (result) in
                    do {
                        let success = try result.get()
                        if success {
                            DispatchQueue.main.async {
                                let alertController = UIAlertController(title: "Sign Up Successful", message: "Now please log in.", preferredStyle: .alert)
                                let alertAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                                alertController.addAction(alertAction)
                                self.present(alertController, animated: true) {
                                    self.loginType = .signIn
                                    self.signUpSignInControl.selectedSegmentIndex = 1
                                    self.signInButton.setTitle("Sign In", for: .normal)
                                    self.phoneNumberTextField.isHidden = true
                                }
                            }
                        }
                    } catch {
                        print("Error signing up: \(error)")
                    }
                })
            } else {
                plantController?.signIn(with: user, completion: { (result) in
                    do {
                        let success = try result.get()
                        if success {
                            DispatchQueue.main.async {
                                self.dismiss(animated: true, completion: nil)
                            }
                        }
                    } catch {
                        if let error = error as? PlantController.NetworkError {
                            switch error {
                            case .failedSignIn:
                                print("Sign in failed")
                            case .noData, .noToken:
                                print("No data received")
                            default:
                                print("Other error occurred")
                            }
                        }
                    }
                })
            }
        }
    }
}
