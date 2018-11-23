//
//  AuthenticationViewController.swift
//  WebAuthnKitDemo
//
//  Created by Lyo Kato on 2018/11/21.
//  Copyright © 2018 Lyo Kato. All rights reserved.
//

import UIKit
import WebAuthnKit
import PromiseKit
import CryptoSwift

class AuthenticationViewController: UIViewController {
    
    var webAuthnClient: WebAuthnClient!
    var userConsentUI: UserConsentUI!
    
    private func setupWebAuthnClient() {
        
        self.userConsentUI = UserConsentUI(viewController: self)
        
        // Registration Phase: These messages are shown for UserVerification/UserPresenceCheck popup.
        self.userConsentUI.confirmationPopupTitle = "Use Key"
        self.userConsentUI.confirmationPopupMessageBuilder = { rp, user in
            return "Create new key for \(user.displayName)?"
        }
        
        // Registration Phase: These messages are shown for confirmation popup when 'exclude' list is set.
        self.userConsentUI.newCredentialPopupTitle = "New Key"
        self.userConsentUI.newCredentialPopupMessage = "Create New Key for this service?"
        
        // Authentication Phase: These messages are shown for key-selection popup.
        self.userConsentUI.selectionPopupTitle = "Key Selection"
        self.userConsentUI.selectionPopupMessage = "Key Selection"
        
        let authenticator = InternalAuthenticator(
            ui:            self.userConsentUI,
            encryptionKey: Bytes.fromString("hogehogehogehoge") // 16byte
        )
        
        self.webAuthnClient = WebAuthnClient(
            origin:        "https://example.org",
            authenticator: authenticator
        )
    }
    
    private func startAuthentication() {
        
        guard let challenge = self.challengeText.text else {
            self.showErrorPopup(FormError.missing("challenge"))
            return
        }
        
        if challenge.isEmpty {
            self.showErrorPopup(FormError.empty("challenge"))
            return
        }
        
        guard let rpId = self.rpIdText.text else {
            self.showErrorPopup(FormError.missing("rpId"))
            return
        }
        
        if rpId.isEmpty {
            self.showErrorPopup(FormError.empty("rpId"))
            return
        }
        
        let verification = [
            UserVerificationRequirement.required,
            UserVerificationRequirement.preferred,
            UserVerificationRequirement.discouraged
        ][self.userVerification.selectedSegmentIndex]
        
        var options = PublicKeyCredentialRequestOptions()
        options.challenge = Bytes.fromHex(challenge)
        options.rpId = rpId
        options.userVerification = verification
        
        if let credId = self.credentialIdText.text {
            if !credId.isEmpty {
                options.addAllowCredential(
                    credentialId: Bytes.fromHex(credId),
                    transports:   [.internal_]
                )
            }
        }
        //options.timeout = UInt64(120)
        
        firstly {
            
            self.webAuthnClient.get(options)
            
        }.done { assertion in

            self.showResult(assertion)

        }.catch { error in
                
            self.showErrorPopup(error)
        }
        
    }

    private func showErrorPopup(_ error: Error) {
        
        let alert = UIAlertController.init(
            title:          "ERROR",
            message:        "failed: \(error)",
            preferredStyle: .alert
        )
        
        let okAction = UIAlertAction.init(title: "OK", style: .default)
        alert.addAction(okAction)

        self.present(alert, animated: true, completion: nil)
    }
    
    var credentialIdText: UITextView!
    var rpIdText:         UITextView!
    var challengeText:    UITextView!
    var userVerification: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        WAKLogger.available = true
        
        view.backgroundColor = UIColor.black
        self.view.addSubview(ViewCatalog.createBackground())
        self.navigationItem.title = "Authentication"

        var offset: CGFloat = 100
        
        self.newLabel(text: "Relying Party Id", top: offset)
        self.rpIdText = self.newTextView(height: 30, top: offset + 30, text: "https://example.org")

        offset = offset + 70
        
        self.newLabel(text: "Challenge (Hex)", top: offset)
        self.challengeText = self.newTextView(height: 30, top: offset + 30, text: "aed9c789543b")
        
        offset = offset + 70
        
        self.newLabel(text: "User Verification", top: offset)
        self.userVerification = self.newSegmentedControl(top: offset + 30, list: ["Required", "Preferred", "Discouraged"])
        
        offset = offset + 70
        
        self.newLabel(text: "Credential Id (Hex) (Optional)", top: offset)
        self.credentialIdText = self.newTextView(height: 120, top: offset + 30, text: "")
        

        self.setupWebAuthnClient()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Start", style: .plain, target: self, action: #selector(AuthenticationViewController.onStartButtonTapped))
    }
    
    private func newLabel(text: String, top: CGFloat) {
        let label = ViewCatalog.createLabel(text: text)
        label.height(20)
        label.fitScreenW(10)
        label.centerizeScreenH()
        label.top(top)
        label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        label.textColor = UIColor.white
        view.addSubview(label)
    }
    
    private func newSegmentedControl(top: CGFloat, list: [String]) -> UISegmentedControl {
        let seg = UISegmentedControl(items: list)
        seg.fitScreenW(20)
        seg.selectedSegmentIndex = 0
        seg.top(top)
        seg.tintColor = UIColor.fromRGB(0xff8c00)
        seg.backgroundColor = UIColor.black
        view.addSubview(seg)
        seg.centerizeScreenH()
        return seg
    }
    
    private func newTextView(height: CGFloat, top: CGFloat, text: String) -> UITextView {
        let view = ViewCatalog.createTextView()
        view.text = text
        view.fitScreenW(20)
        view.height(height)
        view.layer.cornerRadius = 5.0
        view.top(top)
        view.autocorrectionType = .no
        view.autocapitalizationType = .none
        view.backgroundColor = UIColor.white
        view.textColor = UIColor.black
        self.view.addSubview(view)
        view.centerizeScreenH()
        return view
    }
    
    @objc func onStartButtonTapped(_ sender: UIButton) {
        self.startAuthentication()
    }
    
    private func showResult(_ result: WebAuthnClient.GetResponse) {
        
        let user: [UInt8] = result.response.userHandler ?? []
        let userName = String(data: Data(bytes: user), encoding: .utf8) ?? ""
        
        let vc = ResultViewController(
            rawId:             result.rawId.toHexString(),
            credId:            result.id,
            clientDataJSON:    result.response.clientDataJSON,
            authenticatorData: Base64.encodeBase64URL(result.response.authenticatorData),
            signature:         result.response.signature.toHexString(),
            userHandle:        userName
        )
        
        self.present(vc, animated: true, completion: nil)
        
    }
}