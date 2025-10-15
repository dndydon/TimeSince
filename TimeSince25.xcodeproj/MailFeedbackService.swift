import Foundation
import MessageUI

// A simple wrapper for presenting a Mail compose sheet with prefilled templates.
final class MailFeedbackService: NSObject, MFMailComposeViewControllerDelegate {
    func makeComposer(subject: String, body: String, to recipients: [String]) -> MFMailComposeViewController? {
        guard MFMailComposeViewController.canSendMail() else { return nil }
        let vc = MFMailComposeViewController()
        vc.setSubject(subject)
        vc.setToRecipients(recipients)
        vc.setMessageBody(body, isHTML: false)
        vc.mailComposeDelegate = self
        return vc
    }

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}

extension MailFeedbackService {
    static func bugReportTemplate(appVersion: String, deviceInfo: String) -> String {
        """
        Bug Report
        
        App Version: \(appVersion)
        Device: \(deviceInfo)
        Steps to Reproduce:
        1.
        2.
        3.
        
        Expected:
        
        Actual:
        
        Additional Notes:
        """
    }

    static func featureRequestTemplate(appVersion: String, deviceInfo: String) -> String {
        """
        Feature Request
        
        App Version: \(appVersion)
        Device: \(deviceInfo)
        Description:
        
        Use Cases:
        
        Additional Notes:
        """
    }
}
