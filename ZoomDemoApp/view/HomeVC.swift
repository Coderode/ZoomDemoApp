//
//  ViewController.swift
//  ZoomDemoApp
//
//  Created by Sandeep on 17/05/21.
//

import UIKit
import MobileRTC

class HomeVC : UIViewController {
    
    @IBOutlet weak var joinMeetingButton: UIButton!
    @IBOutlet weak var instantMeetingButton: UIButton!
    
    var spinner = SpinnerViewController()
    override func viewDidLoad() {
        super.viewDidLoad()
        MobileRTC.shared().setMobileRTCRootController(self.navigationController)
        self.joinMeetingButton.addTarget(self, action: #selector(didTapJoinMeetingButton), for: .touchUpInside)
        self.instantMeetingButton.addTarget(self, action: #selector(didTapInstantMeetingButton), for: .touchUpInside)
        NotificationCenter.default.addObserver(self, selector: #selector(userLoggedIn), name: NSNotification.Name(rawValue: "userLoggedIn"), object: nil)
    }
    @objc func didTapJoinMeetingButton(){
        presentJoinMeetingAlert()
    }
    @objc func didTapInstantMeetingButton(){
        if let authorizationService = MobileRTC.shared().getAuthService(), authorizationService.isLoggedIn() {
            startMeeting()
        } else {
            presentLogInAlert()
        }
    }
    
    
    func joinMeeting(meetingNumber: String, meetingPassword: String) {
        if let meetingService = MobileRTC.shared().getMeetingService() {
            meetingService.delegate = self
            let joinMeetingParameters = MobileRTCMeetingJoinParam()
            joinMeetingParameters.meetingNumber = meetingNumber
            joinMeetingParameters.password = meetingPassword
            meetingService.joinMeeting(with: joinMeetingParameters)
        }
    }
    
    func logIn(email: String, password: String, handler : (() -> Void)?){
        self.present(spinner, animated: true, completion: nil)
        if let authorizationService = MobileRTC.shared().getAuthService() {
           authorizationService.login(withEmail: email, password: password, rememberMe: false)
        }
    }
    
    func startMeeting() {
        if let meetingService = MobileRTC.shared().getMeetingService() {
            meetingService.delegate = self
            let startMeetingParameters = MobileRTCMeetingStartParam4LoginlUser()
            meetingService.startMeeting(with: startMeetingParameters)
        }
    }
    @objc func userLoggedIn(){
        self.dismiss(animated: true, completion: nil)
        self.startMeeting()
    }
}

extension HomeVC : MobileRTCMeetingServiceDelegate {
    func onMeetingError(_ error: MobileRTCMeetError, message: String?) {
        switch error {
        case .passwordError:
            print("Could not join or start meeting because the meeting password was incorrect.")
        default:
            print("Could not join or start meeting with MobileRTCMeetError: \(error) \(message ?? "")")
        }
    }
    
    func onJoinMeetingConfirmed() {
        print("Join meeting confirmed.")
    }
    
    func onMeetingStateChange(_ state: MobileRTCMeetingState) {
        print("Current meeting state: \(state)")
        if state == .ended{
            DispatchQueue.main.async {
                NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "userLoggedIn"), object: nil)
                self.navigationController?.navigationBar.isHidden = false
                self.tabBarController?.tabBar.isHidden = false
                self.navigationController?.popViewController(animated: true)
            }
        }
        if state == .disconnecting {
            
        }
        
        if state == .inMeeting {
            
        }
        
        if state == .connecting {
            
        }
        
    }
    
    
    
}

extension HomeVC {
    func presentJoinMeetingAlert() {
        let alertController = UIAlertController(title: "Join meeting", message: "", preferredStyle: .alert)
        
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Meeting number"
            textField.keyboardType = .phonePad
        }
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Meeting password"
            textField.keyboardType = .asciiCapable
            textField.isSecureTextEntry = true
        }
        
        let joinMeetingAction = UIAlertAction(title: "Join meeting", style: .default, handler: { alert -> Void in
            let numberTextField = alertController.textFields![0] as UITextField
            let passwordTextField = alertController.textFields![1] as UITextField
            
            if let meetingNumber = numberTextField.text, let password = passwordTextField.text {
                self.joinMeeting(meetingNumber: meetingNumber, meetingPassword: password)
            }
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: { (action : UIAlertAction!) -> Void in })
        
        alertController.addAction(joinMeetingAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    func presentLogInAlert() {
        let alertController = UIAlertController(title: "Log in", message: "login with your zoom id", preferredStyle: .alert)
        
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Email"
            textField.keyboardType = .emailAddress
        }
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Password"
            textField.keyboardType = .asciiCapable
            textField.isSecureTextEntry = true
        }
        
        let logInAction = UIAlertAction(title: "Login", style: .default, handler: { alert -> Void in
            let emailTextField = alertController.textFields![0] as UITextField
            let passwordTextField = alertController.textFields![1] as UITextField
            
            if let email = emailTextField.text, let password = passwordTextField.text {
                self.logIn(email: email, password: password,handler: nil)
                
            }
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: { (action : UIAlertAction!) -> Void in })
        
        alertController.addAction(logInAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
}

