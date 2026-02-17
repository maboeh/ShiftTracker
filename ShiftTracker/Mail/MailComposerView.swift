//
//  MailComposerView.swift
//  ShiftTracker
//
//  Created by Matthias Böhnke on 16.02.26.
//

import MessageUI
import SwiftUI

struct MailComposerView: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    let recipient: String?
    let subject: String
    let body: String
    let attachmentURL: URL?
    let attachmentMimeType: String
    
    init(
        isPresented: Binding<Bool>,
        recipient: String? = nil,
        subject: String,
        body: String,
        attachmentURL: URL? = nil,
        attachmentMimeType: String = "text/csv"
    ) {
        self._isPresented = isPresented
        self.recipient = recipient
        self.subject = subject
        self.body = body
        self.attachmentURL = attachmentURL
        self.attachmentMimeType = attachmentMimeType
    }
    
    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let composer = MFMailComposeViewController()
        
        if let recipient = recipient {
            composer.setToRecipients([recipient])
        }
        
        composer.setSubject(subject)
        composer.setMessageBody(body, isHTML: false)
        
        if let url = attachmentURL {
            do {
                let data = try Data(contentsOf: url)
                composer.addAttachmentData(data, mimeType: attachmentMimeType, fileName: url.lastPathComponent)
            } catch {
                ErrorHandler.shared.handle(
                    ShiftTrackerError.exportError("Anhang konnte nicht geladen werden: \(error.localizedDescription)")
                )
            }
        }
        
        composer.mailComposeDelegate = context.coordinator
        return composer
    }
    
    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(isPresented: $isPresented)
    }
    
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        @Binding var isPresented: Bool
        
        init(isPresented: Binding<Bool>) {
            _isPresented = isPresented
        }
        
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            if result == .sent {
                HapticFeedback.success()
            } else if result == .failed {
                HapticFeedback.error()
                if let error {
                    ErrorHandler.shared.handle(
                        ShiftTrackerError.exportError("E-Mail konnte nicht gesendet werden: \(error.localizedDescription)")
                    )
                }
            }
            isPresented = false
        }
    }
    
    static func canSendMail() -> Bool {
        MFMailComposeViewController.canSendMail()
    }
}
