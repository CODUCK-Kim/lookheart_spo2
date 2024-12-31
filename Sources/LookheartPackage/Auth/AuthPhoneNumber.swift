import Foundation
import UIKit
import Then
import SnapKit
import PhoneNumberKit

public protocol AuthDelegate: AnyObject {
    func complete(result: String)
    func cancle()
}

@available(iOS 13.0.0, *)
public class AuthPhoneNumber: UIView, UITableViewDataSource, UITableViewDelegate {
    public weak var delegate: AuthDelegate?
    
    private let numberRegex = try! NSRegularExpression(pattern: "[0-9]+")
    
    private let PHONE_NUMBER_TAG = 0
    private let AUTH_NUMBER_TAG = 1

    private let phoneNumberKit = PhoneNumberKit()
    
    private var countries: [String] {
        return phoneNumberKit.allCountries().filter { $0 != "001" }
    }

    private var authTextFieldHeightConstraint: Constraint?  // 기존 높이 제약 조건을 참조할 수 있도록 저장
    
    private var countdownTimer: Timer?
    private var countdown: Int = 180
    private var smsCnt = 5
    
    private var phoneNumber = ""
    private var nationalCode = ""
    private var authNumber = ""
    
    private var phoneNumberRegx = false
    private var authNumberRegx = false

    private var authService = AuthService()
    
    
    
    private lazy var toggleButton = UIButton().then {
        $0.setTitle("-", for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        $0.titleLabel?.textAlignment = .center
        $0.setTitleColor(UIColor.darkGray, for: .normal)
        $0.addTarget(self, action: #selector(toggleButtonTapped), for: .touchUpInside)
    }
    
    private lazy var sendButton = UIButton().then {
        $0.setTitle("dialog_verify".localized(), for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        $0.titleLabel?.textAlignment = .center
        $0.setTitleColor(UIColor.white, for: .normal)
        $0.backgroundColor = UIColor.MY_BLUE
    }

    private lazy var okButton = UIButton().then {
        $0.setTitle("msg_ok".localized(), for: .normal)
        $0.titleLabel?.textAlignment = .center
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        $0.setTitleColor(.white, for: .normal)
        $0.backgroundColor = UIColor.MY_BLUE
    }
    
    private lazy var calcleButton = UIButton().then {
        $0.setTitle("msg_cancel_upper".localized(), for: .normal)
        $0.titleLabel?.textAlignment = .center
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        $0.setTitleColor(.lightGray, for: .normal)
        $0.backgroundColor = UIColor.MY_LIGHT_GRAY_BORDER2
    }
    
    private lazy var tableView = UITableView().then {
        $0.dataSource = self
        $0.delegate = self
        $0.isHidden = true  // 초기에는 숨김
    }
    
    private lazy var phoneNumberTextField = UnderLineTextField().then {
        $0.textColor = .darkGray
        $0.keyboardType = .numberPad
        $0.tintColor = UIColor.MY_BLUE
        $0.font = UIFont.systemFont(ofSize: 16)
        $0.placeholderString = "msg_phone_number".localized()
        $0.placeholderColor = UIColor.lightGray
        $0.tag = PHONE_NUMBER_TAG
    }
    
    private lazy var authTextField = UnderLineTextField().then {
        $0.textColor = .darkGray
        $0.keyboardType = .numberPad
        $0.textContentType = .oneTimeCode
        $0.tintColor = UIColor.MY_BLUE
        $0.font = UIFont.systemFont(ofSize: 16)
        $0.placeholderString = "desc_enter_verification_code".localized()
        $0.placeholderColor = UIColor.lightGray
        $0.tag = AUTH_NUMBER_TAG
        $0.isHidden = true
    }

    private let verifyNumberLabel = UILabel().then {
        $0.text = "msg_verify_number".localized()
        $0.font = UIFont.systemFont(ofSize: 14, weight: .heavy)
        $0.textColor = UIColor.darkGray
        $0.textAlignment = .center
        $0.isHidden = true
    }
    
    private var _sms:Bool = true
   
    public var sms:Bool {
        set{
            _sms = newValue
        }
        get{
            return _sms
        }
    }
    
    
    // MARK: - init
    override init(frame: CGRect) {
        super.init(frame: frame)
        addViews()
        updateToggleButtonTitle()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        setLayoutSubviews()
    }
    
    // MARK: tableView
    @objc func toggleButtonTapped() {
        tableView.isHidden = !tableView.isHidden            // 리스트 뷰의 표시 상태 토글
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return countries.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let countryCode = countries[indexPath.row]
        let currentLocale = Locale.current
        let countryName = currentLocale.localizedString(forRegionCode: countryCode) ?? countryCode
        let flag = emojiFlag(for: countryCode)
        cell.backgroundColor = .white
        cell.textLabel?.textColor = .darkGray
        cell.textLabel?.text = "\(flag)\(countryName)"
        return cell
    }
    
    // UITableViewDelegate
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCountry = countries[indexPath.row]
        let countryCode = phoneNumberKit.countryCode(for: selectedCountry) ?? 0
        let currentLocale = Locale.current
        let countryName = currentLocale.localizedString(forRegionCode: selectedCountry) ?? selectedCountry
        let flag = emojiFlag(for: selectedCountry)
        
        toggleButton.setTitle("\(flag)\(countryName)", for: .normal)
        tableView.isHidden = !tableView.isHidden
        
        nationalCode = String(countryCode)
        print("Selected Country: \(selectedCountry) - Code: \(countryCode)")
    }
    
    private func emojiFlag(for countryCode: String) -> String {
        let base: UInt32 = 127397
        var s = ""
        for v in countryCode.uppercased().unicodeScalars {
            s.unicodeScalars.append(UnicodeScalar(base + v.value)!)
        }
        return s
    }
    
    private func updateToggleButtonTitle() {
        let currentLocale = Locale.current
        let countryCode = currentLocale.regionCode ?? "US"
        let countryName = currentLocale.localizedString(forRegionCode: countryCode) ?? countryCode
        let flag = emojiFlag(for: countryCode)
        toggleButton.setTitle("\(flag)\(countryName)", for: .normal)
        
        // nationalCode 업데이트
        if let code = phoneNumberKit.countryCode(for: countryCode) {
            nationalCode = String(code)
        }
    }
    
    // MARK: - sendSMS Event
    @objc private func sendButtonEvent() {
        self.endEditing(true)
        print("sms \(sms)")
        if smsCnt > 0 && phoneNumber.count > 4 && phoneNumberRegx {
            
            if sms {
                sendSMS()
                updateUI()
            } else {
                checkDupPhoneNumber()
            }
            
        } else if phoneNumber.count < 4 || !phoneNumberRegx {
            showAlert(title: "dialog_notification".localized(), message: "dialog_setupGuardian_help".localized(), actionButton: false)
        } else {
            showAlert(title: "dialog_notification".localized(), message: "dialog_exceeded_verification_help".localized(), actionButton: false)
        }
    }
    
    private func checkDupPhoneNumber() {
        Task {
            let response = await authService.getDupPhoneNumber(phone: phoneNumber)
            
            switch response {
            case .success:
                sendSMS()
                updateUI()
            case .failer:
                self.showAlert(
                    title: "dialog_notification".localized(),
                    message: "dialog_dup_phoneNumber_help".localized(),
                    actionButton: true
                )
            default:
                self.showAlert(
                    title: "dialog_notification".localized(),
                    message: "dialog_error_server_noData".localized(),
                    actionButton: true
                )
            }
        }
    }
    
    
    private func sendSMS() {
        Task {
            let response = await authService.getSendSms(phone: phoneNumber, code: nationalCode)
            
            switch response {
            case .success:
                self.startCountdown()
                self.showAlert(
                    title: "dialog_verify".localized(),
                    message: "dialog_sendVerification_help".localized(),
                    actionButton: false
                )
            case .failer:
                self.showAlert(
                    title: "dialog_notification".localized(),
                    message: "dialog_error_connect".localized(),
                    actionButton: false
                )
            case .noData:   // 횟수 초과
                self.showAlert(
                    title: "dialog_notification".localized(),
                    message: "dialog_exceeded_verification_help".localized(),
                    actionButton: false
                )
            default:
                self.showAlert(
                    title: "dialog_notification".localized(),
                    message: "dialog_error_connect".localized(),
                    actionButton: false
                )
            }
        }
    }

    
    func showAlert(title: String, message: String, actionButton: Bool) {
        DispatchQueue.main.async {
            guard let viewController = self.parentViewController else {
                print("View controller not found")
                return
            }
            
            var action: UIAlertAction?
            
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            
            action = actionButton ?
            UIAlertAction(title: "msg_ok".localized(), style: .default) { _ in self.delegate?.complete(result: "false")} :
            UIAlertAction(title: "msg_ok".localized(), style: .default, handler: nil)
            
            alert.addAction(action!)
            viewController.present(alert, animated: true)
        }
    }
    
    private func updateUI() {
        verifyNumberLabel.isHidden = false
        authTextField.isHidden = false
        sendButton.isEnabled = false
        
        authTextFieldHeightConstraint?.update(offset: 30)
        authTextField.layoutIfNeeded()  // 레이아웃 업데이트
                
        self.addSubview(verifyNumberLabel)
        verifyNumberLabel.snp.makeConstraints { make in
            make.top.bottom.equalTo(authTextField)
            make.left.equalTo(toggleButton).offset(3)
            make.right.equalTo(toggleButton)
        }
        
        verifyNumberLabel.layoutIfNeeded()
    }
    
    // MARK: - checkSMS Event
    @objc private func checkButtonEvent() {
        
        self.endEditing(true)
        
        if authNumber.count == 6 && authNumberRegx {
            checkSMS()
        } else {
            showAlert(title: "dialog_notification".localized(), message: "dialog_confirmVerification_help".localized(), actionButton: false)
        }
    }
    
    private func checkSMS() {
        Task {
            let response = await authService.getCheckSmsCode(phone: phoneNumber, code: authNumber)
            
            switch response {
            case .success:
                UserProfileManager.shared.phone = phoneNumber
                delegate?.complete(result: phoneNumber)
            case .failer:
                // Time Over
                showAlert(
                    title: "dialog_notification".localized(),
                    message: "dialog_auth_exceeded_time".localized(),
                    actionButton: false
                )
            default:
                showAlert(
                    title: "dialog_notification".localized(),
                    message: "dialog_error_connect".localized(),
                    actionButton: false
                )
            }
        }
    }
    
    
    
    // MARK: - cancleButton Event
    @objc private func cancleButtonEvent() {
        self.endEditing(true)
        delegate?.cancle()
    }
    
    // MARK: - keyboard
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.endEditing(true)
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        let text = textField.text ?? "Empty"
        
        switch (textField.tag) {
        case PHONE_NUMBER_TAG:
            phoneNumber = text
            
            if isNumberValid(phoneNumber) {
                phoneNumberRegx = true
                phoneNumberTextField.setUnderLineColor(UIColor.MY_BLUE)
            } else {
                phoneNumberRegx = false
                phoneNumberTextField.setUnderLineColor(.lightGray)
            }
            
        case AUTH_NUMBER_TAG:
            authNumber = text
            
            if isNumberValid(authNumber) {
                authNumberRegx = true
                authTextField.setUnderLineColor(UIColor.MY_BLUE)
            } else {
                authNumberRegx = false
                authTextField.setUnderLineColor(.lightGray)
            }
            
        default:
            break
        }
    }
    
    private func isNumberValid(_ number: String) -> Bool {
        return numberRegex.firstMatch(in: number, options: [], range: NSRange(location: 0, length: number.count)) != nil
    }
    
    // MARK: - timer
    func startCountdown() {
        countdownTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateCountdown), userInfo: nil, repeats: true)
    }
    
    @objc func updateCountdown() {
        if countdown > 0 {
            countdown -= 1
            let sec = countdown % 60
            let min = (countdown / 60) % 60
            
            let secString = sec < 10 ? "0\(sec)" : "\(sec)"
            let minString = min < 10 ? "0\(min)" : "\(min)"
            
            updateText("\(minString):\(secString)")
        } else {
            countdown = 180
            countdownTimer?.invalidate()
            countdownTimer = nil
            sendButton.isEnabled = true
            
            updateText("msg_reSend".localized())
        }
    }
    
    private func updateText(_ text: String) {
        DispatchQueue.main.async {
            self.sendButton.setTitle(text, for: .normal)
        }
    }
    
    // MARK: - addViews
    private func addTarget() {
        
        phoneNumberTextField.tag = PHONE_NUMBER_TAG
        authTextField.tag = AUTH_NUMBER_TAG
        
        phoneNumberTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        authTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        sendButton.addTarget(self, action: #selector(sendButtonEvent), for: .touchUpInside)
        
        okButton.addTarget(self, action: #selector(checkButtonEvent), for: .touchUpInside)
        calcleButton.addTarget(self, action: #selector(cancleButtonEvent), for: .touchUpInside)
        
    }
    
    private func setLayoutSubviews() {
        
        addTarget()
        setBorder()
        
        let underLine = UILabel().then {
            $0.backgroundColor = UIColor.MY_BLUE
        }
        
        self.addSubview(underLine)
        underLine.snp.makeConstraints { make in
            make.top.equalTo(toggleButton.snp.bottom).offset(1)
            make.left.equalTo(toggleButton).offset(3)
            make.right.equalTo(toggleButton)
            make.height.equalTo(2)
        }
    }
    
    private func addViews(){
        
        self.backgroundColor = .white
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        let safeAreaView = UILabel().then { $0.backgroundColor = .white }
        
        self.addSubview(safeAreaView)
        
        safeAreaView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(30)
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
            make.bottom.equalToSuperview().offset(-50)
        }
        
        let borderLabel = UILabel().then {
            $0.layer.borderColor = UIColor.MY_BLUE.cgColor
            $0.layer.cornerRadius = 10
            $0.layer.borderWidth = 2
            $0.layer.masksToBounds = true
            $0.backgroundColor = .clear
        }

        self.addSubview(borderLabel)
        borderLabel.snp.makeConstraints {
            $0.top.right.left.equalTo(safeAreaView)
            $0.bottom.equalToSuperview().offset(30)
        }
        
        let authLabel = UILabel().then {
            $0.text = "msg_verification".localized()
            $0.textColor = .white
            $0.font = UIFont.systemFont(ofSize: 18, weight: .heavy)
            $0.backgroundColor = UIColor.MY_BLUE
            $0.textAlignment = .center
            $0.layer.cornerRadius = 10
            $0.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]   // 왼쪽 위, 오른쪽 위 테두리 설정
            $0.clipsToBounds = true
        }
        
        
        self.addSubview(authLabel)
        authLabel.snp.makeConstraints { make in
            make.top.left.right.centerX.equalTo(safeAreaView)
            make.height.equalTo(40)
        }
        
        //
        let helpText = UILabel().then {
            $0.text = "desc_auth".localized()
            $0.numberOfLines = 2
            $0.font = UIFont.systemFont(ofSize: 16, weight: .heavy)
            $0.textColor = UIColor.MY_BLUE
            $0.textAlignment = .center
        }
        self.addSubview(helpText)
        helpText.snp.makeConstraints { make in
            make.top.equalTo(authLabel.snp.bottom).offset(50)
            make.left.right.equalTo(safeAreaView)
        }
        
        //
        self.addSubview(toggleButton)
        toggleButton.snp.makeConstraints { make in
            make.top.equalTo(helpText.snp.bottom).offset(50)
            make.left.equalTo(safeAreaView).offset(10)
            make.width.equalTo(100)
        }
        
        // phoneNumberTextField
        self.addSubview(phoneNumberTextField)
        phoneNumberTextField.snp.makeConstraints { make in
            make.left.equalTo(toggleButton.snp.right).offset(10)
            make.right.equalTo(safeAreaView).offset(-100)
            make.top.equalTo(toggleButton)
            make.bottom.equalTo(toggleButton).offset(1)
        }
        
        // authTextField
        self.addSubview(authTextField)
        authTextField.snp.makeConstraints { make in
            make.top.equalTo(toggleButton.snp.bottom).offset(20)
            make.left.right.equalTo(phoneNumberTextField)
            authTextFieldHeightConstraint = make.height.equalTo(0).constraint // 초기 높이 저장
        }
        
        //
        self.addSubview(sendButton)
        sendButton.snp.makeConstraints { make in
            make.top.bottom.equalTo(toggleButton)
            make.left.equalTo(phoneNumberTextField.snp.right).offset(10)
            make.right.equalTo(safeAreaView).offset(-10)
        }
    
        //
        let authHelpText = UILabel().then {
            $0.text = "dialog_time_help".localized()
            $0.font = UIFont.systemFont(ofSize: 14, weight: .heavy)
            $0.textColor = UIColor.lightGray
        }
        self.addSubview(authHelpText)
        authHelpText.snp.makeConstraints { make in
            make.top.equalTo(authTextField.snp.bottom).offset(15)
            make.left.equalTo(toggleButton).offset(10)
        }
        
        //
        let authHelpText2 = UILabel().then {
            $0.text = "dialog_resend_number".localized()
            $0.font = UIFont.systemFont(ofSize: 14, weight: .bold)
            $0.textColor = UIColor.lightGray
        }
        
        self.addSubview(authHelpText2)
        authHelpText2.snp.makeConstraints { make in
            make.top.equalTo(authHelpText.snp.bottom).offset(5)
            make.left.equalTo(toggleButton).offset(10)
        }
        
        self.addSubview(okButton)
        okButton.snp.makeConstraints { make in
            make.top.equalTo(authHelpText2).offset(50)
            make.left.equalTo(safeAreaView).offset(10)
            make.right.equalTo(safeAreaView).offset(-10)
            make.height.equalTo(40)
        }
        
        self.addSubview(calcleButton)
        calcleButton.snp.makeConstraints { make in
            make.top.equalTo(okButton.snp.bottom).offset(10)
            make.left.right.height.equalTo(okButton)
        }
        
        // tableView
        self.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(toggleButton.snp.bottom).offset(10)
            make.left.equalTo(toggleButton)
            make.right.equalTo(borderLabel).offset(-5)
            make.height.equalTo(300)
        }
    }
    
    private func setBorder() {
        sendButton.layer.cornerRadius = 10
        sendButton.layer.masksToBounds = true

        okButton.layer.cornerRadius = 10
        okButton.layer.masksToBounds = true

        calcleButton.layer.borderColor = UIColor.MY_LIGHT_GRAY_BORDER.cgColor
        calcleButton.layer.cornerRadius = 10
        calcleButton.layer.borderWidth = 3
        calcleButton.layer.masksToBounds = true
    }
    
}
