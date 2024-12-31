import Foundation


public class UserProfileManager {
    
    public static let shared = UserProfileManager()
    
    private(set) var userProfile: UserProfile?
    private var guardianPhoneNumbers: [String] = []
    private var checkLogin: Bool = true
    private var bluetoothIdentifier: String = ""
    
    public lazy var genderCalcAge: Double  = {
        let gender = propProfile.gender == "남자"
        return gender ? 0.2017 : 0.074
    }()
    
    public lazy var genderCalcWeight: Double  = {
        let gender = propProfile.gender == "남자"
        return gender ? 0.1988 : 0.1263
    }()

    public lazy var genderCalcBpm: Double  = {
        let gender = propProfile.gender == "남자"
        return gender ? 0.6309 : 0.4472
    }()
    
    public lazy var genderCal: Double  = {
        let gender = propProfile.gender == "남자"
        return gender ? 55.0969 : 20.4022
    }()
    
    public lazy var avgSize: Double  = {
        let height = Double(propProfile.height) ?? 170.0
        let calcHeight = ((height * 0.37) + (height - 100)) / 2.0
        return calcHeight < 0 ? 10 : calcHeight
    }()
    
    public init() { }
    
    // MARK: - PROFILE
    // UserProfile
    public var profile: UserProfile {
        get {
            return userProfile!
        }
        set {
            userProfile = newValue
        }
    }
    
    
    // Email
    public var email: String{
        get{
            return userProfile?.eq ?? "isEmpty"
        }
    }

    
    // name
    public var name: String {
        get {
            return userProfile?.eqname ?? "isEmpty"
        }
        set {
            userProfile?.eqname = newValue
        }
    }
    
    // phone
    public var phone: String {
        get {
            return userProfile?.userphone ?? "01012345678"
        }
        set {
            userProfile?.userphone = newValue
        }
    }
    

    // birth
    public var birthDate: String {
        get {
            return userProfile?.birth ?? "isEmpty"
        }
        set {
            userProfile?.birth = newValue
        }
    }
    
    // age
    public var age: String {
        get {
            return userProfile?.age ?? "isEmpty"
        }
        set {
            userProfile?.age = newValue
        }
    }
    

    // gender
    public var gender: String {
        get {
            return userProfile?.sex ?? "isEmpty"
        }
        set {
            userProfile?.sex = newValue
        }
    }
    
    
    // height
    public var height: String {
        get {
            return userProfile?.height ?? "isEmpty"
        }
        set {
            userProfile?.height = newValue
        }
    }
    
    
    // weight
    public var weight: String {
        get {
            return userProfile?.weight ?? "isEmpty"
        }
        set {
            userProfile?.weight = newValue
        }
    }
    

    // sleep time
    public var bedTime: Int {
        get {
            return userProfile?.sleeptime ?? 23
        }
        set {
            userProfile?.sleeptime = newValue
        }
    }
    
    
    
    // wake time
    public var wakeUpTime: Int {
        get {
            return userProfile?.uptime ?? 7
        }
        set {
            userProfile?.uptime = newValue
        }
    }
    
    // Check Login
    public var isLogin: Bool {
        get {
            return checkLogin
        }
        set {
            checkLogin = newValue
        }
    }
    
    // BLE ID
    public var bleIdentifier: String {
        get {
            return bluetoothIdentifier
        }
        set {
            bluetoothIdentifier = newValue
        }
    }
    
    // joinDate
    public var joinDate: String {
        get {
            return userProfile?.signupdate ?? "2023-01-01"
        }
    }


    public var guardianPhoneNumber: [String] {
        get {
            return guardianPhoneNumbers
        }
        set {
            guardianPhoneNumbers = newValue
        }
    }
    
    

    
    // MARK: - SETTING
    
    // Activity Bpm
    public var targetBpm: Int {
        get {
            return userProfile?.bpm ?? 90
        }
        set {
            userProfile?.bpm = newValue
        }
    }
    
    
    // Step
    public var targetStep: Int {
        get {
            return userProfile?.step ?? 2000
        }
        set {
            userProfile?.step = newValue
        }
    }
    
    
    // Distance
    public var targetDistance: Int {
        get {
            return userProfile?.distanceKM ?? 5
        }
        set {
            userProfile?.distanceKM = newValue
        }
    }
    
    
    // Calorie
    public var targetCalorie: Int {
        get {
            return userProfile?.cal ?? 3000
        }
        set {
            userProfile?.cal = newValue
        }
    }
    
    
    
    // Activity Calorie
    public var targetActivityCalorie: Int {
        get {
            return userProfile?.calexe ?? 500
        }
        set {
            userProfile?.calexe = newValue
        }
    }
    
    
    
    /// Conversion FLAG
    /// peak : 0, ecg : 1
    public var conversionFlag: Bool {
        get {
            return userProfile?.alarm_sms == 1 ? true : false
        }
        set {
            userProfile?.alarm_sms = newValue ? 1 : 0
        }
    }

    public var social: Int? {
        get {
            return userProfile?.way
        }
    }
}
