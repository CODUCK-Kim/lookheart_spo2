import UIKit
import SnapKit

public class KeyboardEventHandling {
    private(set) var isKeyboardVisible: Bool = false
    
    weak var scrollView: UIScrollView?
    weak var containerView: UIView?
    
    private var addHight: CGFloat?
    private var constraint: Constraint?
    
    public var backgroundTapped: (() -> Void)?
    
    // MARK: - init
    public init() { }
    
    public func initScrollView(
        scrollView: UIScrollView,
        addHight: CGFloat = 0
    ) {
        self.scrollView = scrollView
        self.addHight = addHight
    }
    
    public func initContainerView(
        containerView: UIView,
        addHight: CGFloat = 0,
        constraint: Constraint? = nil
    ) {
        self.containerView = containerView
        self.addHight = addHight
        self.constraint = constraint
    }
    
    // MARK: - observing
    public func startObserving() {
        // show keyboard
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        // hide keyboard
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    public func stopObserving() {
        // remove observer
        NotificationCenter.default.removeObserver(
            self,
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.removeObserver(
            self,
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    
    // event
    @objc private func keyboardWillShow(notification: NSNotification) {
        isKeyboardVisible = true
        
        // show
        if scrollView != nil {
            // scrollView
            scrollViewKeyboardWillShow(notification)
        } else {
            // containerView
            containerViewKeyboardWillShow(notification)
        }
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        isKeyboardVisible = false
        
        // hide
        if scrollView != nil {
            // scrollView
            scrollViewKeyboardWillHide(notification)
        } else {
            // containerView
            containerViewKeyboardWillHide(notification)
        }
    }

    
    // scrollView
    func scrollViewKeyboardWillShow(_ notification: NSNotification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let scrollView = scrollView else { return }
        
        let contentInset = UIEdgeInsets(
            top: 0.0,
            left: 0.0,
            bottom: keyboardFrame.size.height + (addHight ?? 0),
            right: 0.0
        )
        
        scrollView.contentInset = contentInset
        scrollView.scrollIndicatorInsets = contentInset
    }
    
    func scrollViewKeyboardWillHide(_ notification: NSNotification) {
        guard let scrollView = scrollView else { return }
        
        scrollView.contentInset = .zero
        scrollView.scrollIndicatorInsets = .zero
    }

    
    // containerView
    func containerViewKeyboardWillShow(_ notification: NSNotification) {
        guard let userInfo = notification.userInfo,
              let containerView = containerView,
              let keyboardFrameValue = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue,
              let animationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber,
              let animationCurveRawValue = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber else { return }

        let keyboardFrame = keyboardFrameValue.cgRectValue
        let keyboardHeight = keyboardFrame.height
        
        constraint?.update(offset: -keyboardHeight + (addHight ?? 0))

        UIView.animate(
            withDuration: animationDuration.doubleValue,
            delay: 0,
            options: UIView.AnimationOptions(rawValue: animationCurveRawValue.uintValue << 16),
            animations: { containerView.layoutIfNeeded() },
            completion: nil
        )
    }
    
    func containerViewKeyboardWillHide(_ notification: NSNotification) {
        guard let userInfo = notification.userInfo,
              let containerView = containerView,
              let constraint = constraint,
              let animationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber,
              let animationCurveRawValue = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber else { return }
        
        constraint.update(offset: 0)
        
        // 애니메이션 적용
        UIView.animate(withDuration: animationDuration.doubleValue,
                       delay: 0,
                       options: UIView.AnimationOptions(rawValue: animationCurveRawValue.uintValue << 16),
                       animations: {
            containerView.layoutIfNeeded()
        }, completion: nil)
    }
    
    
    
    
    // MARK: -
    public func setupKeybordEvent(view: UIView) {
        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(backgroundTapped(_:))
        )
        
        view.addGestureRecognizer(tapGesture)
    }
    
    
    @objc private func backgroundTapped(_ sender: UITapGestureRecognizer) {
        backgroundTapped?()
    }
    
    
    public func isKeyboardCurrentlyVisible() -> Bool {
        return isKeyboardVisible
    }
}
