//
//  File.swift
//  
//
//  Created by KHJ on 2024/05/03.
//

import Foundation
import UIKit


class ReportAlert: UIView {
    init(lastAccessTime: String, arrCnt: Int, emergencyCnt: Int) {
        super.init(frame: UIScreen.main.bounds)
        setupView(lastAccessTime, arrCnt, emergencyCnt)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView(
        _ lastAccessTime: String,
        _ arrCnt: Int,
        _ emergencyCnt: Int
    ) {
        // Create
        let backgroundView = propCreateUI.backgroundLabel(
            backgroundColor: UIColor.black.withAlphaComponent(0.5),
            borderColor: UIColor.clear.cgColor,
            borderWidth: 0,
            cornerRadius: 10
        )
        
        // addSubView
        addSubview(backgroundView)
        
        // Constraints
        backgroundView.frame = bounds
    }
}
