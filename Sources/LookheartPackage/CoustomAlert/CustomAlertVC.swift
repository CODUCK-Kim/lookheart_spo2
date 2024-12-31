//
//  File.swift
//  
//
//  Created by KHJ on 11/6/24.
//

import Foundation
import UIKit

public class CustomAlertVC: UIViewController {
    private let alertType: AlertType
    private var safeAreaView = UIView()
    private lazy var alertView: UIView = getView()
    
    //
    private let alertTitle: String
    private let alertBody: String
    private let alertOk: String
    private let alertCancel: String
    
    private let heightMultiplier: CGFloat
    private let widthMultiplier: CGFloat
    private let tapEventEnable: Bool
    
    //
    public var backgroundTapped: (() -> Void)?
    public var onOkButtonTapped: (() -> Void)?
    public var onCancelButtonTapped: (() -> Void)?
    
    // MARK: - init
    public init(
        type: AlertType,
        title: String,
        body: String,
        ok: String = "msg_ok".localized(),
        cancel: String = "msg_cancel_upper".localized(),
        height: CGFloat = 0.3,
        width: CGFloat = 0.8,
        tapDismiss: Bool = true
    ) {
        self.alertType = type
        self.alertTitle = title
        self.alertBody = body
        self.alertOk = ok
        self.alertCancel = cancel
        
        self.heightMultiplier = height
        self.widthMultiplier = width
        self.tapEventEnable = tapDismiss
        
        super.init(nibName: nil, bundle: nil)
        
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        setupView()
        
        setTapEvent()
        
        addTarget()
    }
    
    private func setTapEvent() {
        if tapEventEnable {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped(_:)))
            view.addGestureRecognizer(tapGesture)
        }
    }
    
    @objc private func backgroundTapped(_ sender: UITapGestureRecognizer) {
        backgroundTapped?()
    }
    
    private func setupView() {
        // 배경 설정
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        // AlertView 추가
        view.addSubview(alertView)
        
        // AlertView 레이아웃 설정
        alertView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(widthMultiplier)
            make.height.equalToSuperview().multipliedBy(heightMultiplier)
        }
    }
    
    
    private func getView() -> UIView {
        switch alertType {
        case .basic, .cancel:
            return BasicAlertView(type: alertType, title: alertTitle, body: alertBody, ok: alertOk, cancel: alertCancel)
        }
    }
    
    private func addTarget() {
        switch alertType {
        case .basic:
            (alertView as! BasicAlertView).okButton.addTarget(self, action: #selector(okButtonTapped), for: .touchUpInside)
        case .cancel:
            (alertView as! BasicAlertView).okButton.addTarget(self, action: #selector(okButtonTapped), for: .touchUpInside)
            (alertView as! BasicAlertView).cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        }
    }
    
    @objc private func okButtonTapped() {
        onOkButtonTapped?()
    }
    
    @objc private func cancelButtonTapped() {
        onCancelButtonTapped?()
    }
}
