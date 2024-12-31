import UIKit

public class MyAlert {
    public static let shared = MyAlert()
    
    public init() {}
    
    public func basicAlert(
        title: String,
        message: String,
        ok: String,
        viewController: UIViewController
    ) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let complite = UIAlertAction(title: ok, style: .default)
        alert.addAction(complite)
        viewController.present(alert, animated: true, completion: {})
    }
    
    
    
    public func basicActionAlert(
        title: String,
        message: String,
        ok: String,
        viewController: UIViewController,
        completion: @escaping () -> Void
    ) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let complite = UIAlertAction(title: ok, style: .default) { _ in
            completion()
        }
        alert.addAction(complite)
        viewController.present(alert, animated: true, completion: {})
    }
    
    
    
    public func basicCancelAlert(
        title: String,
        message: String,
        ok: String,
        cancel: String,
        viewController: UIViewController,
        completion: @escaping () -> Void,
        cancelAction: @escaping () -> Void
    ) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let complite = UIAlertAction(title: ok, style: .default) { _ in
            completion()
        }
        let cancel = UIAlertAction(title: cancel, style: .cancel) { _ in
            cancelAction()
        }
        alert.addAction(complite)
        alert.addAction(cancel)
        viewController.present(alert, animated: true, completion: {})
    }
    
    
    public func basicTextFieldAlert(
        title: String, body: String, ok: String, cancel: String, holder: String,
        viewController: UIViewController,
        okCompletion: @escaping (String) -> Void,
        cancelCompletion: @escaping () -> Void
    ) {
        let alertController = UIAlertController(title: title, message: body, preferredStyle: .alert)

        // 텍스트 필드
        alertController.addTextField { textField in
            textField.placeholder = holder
            textField.autocorrectionType = .no
            textField.spellCheckingType = .no
        }

        // 확인 버튼
        let confirmAction = UIAlertAction(title: ok, style: .default) { _ in
            if let text = alertController.textFields?.first?.text {
                okCompletion(text)
            }
        }

        // 취소 버튼
        let cancelAction = UIAlertAction(title: cancel, style: .cancel) { _ in
            cancelCompletion()
        }
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        viewController.present(alertController, animated: true)
    }
    
    
    public func basicTextFieldAlert(
        title: String,
        body: String,
        hint: String,
        type: UIKeyboardType,
        viewController: UIViewController,
        completion: @escaping (String) -> Void
    ) {
        let alertController = UIAlertController(
            title: title,
            message: body,
            preferredStyle: .alert
        )

        // 텍스트 필드
        alertController.addTextField { textField in
            textField.placeholder = hint
            textField.keyboardType = type
        }

        // 확인 버튼
        let confirmAction = UIAlertAction(title: "msg_ok".localized(), style: .default) { _ in
            if let text = alertController.textFields?.first?.text {
                completion(text)
            }
        }

        // 취소 버튼
        let cancelAction = UIAlertAction(title: "msg_cancel_upper".localized(), style: .cancel, handler: nil)

        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        viewController.present(alertController, animated: true)
    }
    
    public func basicPasswordAlert(
        viewController: UIViewController,
        completion: @escaping (String) -> Void
    ) {
        let alertController = UIAlertController(title: "msg_input_password".localized(), message: "password_Hint".localized(), preferredStyle: .alert)

        // 텍스트 필드
        alertController.addTextField { textField in
            textField.placeholder = "msg_password".localized()
            textField.isSecureTextEntry = true // 비밀번호 입력 필드로 설정
        }

        // 확인 버튼
        let confirmAction = UIAlertAction(title: "msg_ok".localized(), style: .default) { _ in
            if let password = alertController.textFields?.first?.text {
                // 비밀번호
                completion(password)
            }
        }

        // 취소 버튼
        let cancelAction = UIAlertAction(title: "msg_cancel_upper".localized(), style: .cancel, handler: nil)

        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        viewController.present(alertController, animated: true)
    }
    
}
