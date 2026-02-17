//
//  ShareSheetView.swift
//  ShiftTracker
//
//  Created by Matthias Böhnke on 16.02.26.
//

import SwiftUI
import UIKit

struct ShareSheetView: UIViewControllerRepresentable {
    let items: [Any]
    let completion: (() -> Void)?
    
    init(items: [Any], completion: (() -> Void)? = nil) {
        self.items = items
        self.completion = completion
    }
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: items,
            applicationActivities: nil
        )
        
        controller.excludedActivityTypes = [
            .postToFacebook,
            .postToTwitter,
            .postToWeibo,
            .postToVimeo,
            .postToFlickr,
            .postToTencentWeibo
        ]
        
        controller.completionWithItemsHandler = { activityType, completed, _, _ in
            if completed {
                HapticFeedback.success()
            }
            self.completion?()
        }
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
