//
//  File.swift
//  
//
//  Created by KHJ on 2024/04/11.
//

import Foundation
import UIKit

@available(iOS 13.0, *)
extension UIViewController {
    func showLoadingOverlay() {
        let overlayView = UIView(frame: view.bounds)
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        overlayView.tag = 999 // 임의의 태그 값으로 식별
        overlayView.isUserInteractionEnabled = true // 사용자 입력 막기

        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.center = overlayView.center
        activityIndicator.startAnimating()
        
        overlayView.addSubview(activityIndicator)
        view.addSubview(overlayView)
    }
    
    func removeLoadingOverlay() {
        if let overlayView = view.viewWithTag(999) {
            overlayView.removeFromSuperview()
        }
    }
}
