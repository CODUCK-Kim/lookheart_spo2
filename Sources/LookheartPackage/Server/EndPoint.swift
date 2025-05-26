//
//  File.swift
//  
//
//  Created by 정연호 on 8/7/24.
//

import Foundation

public enum EndPoint: String {
    // GET: Health Data
    case getVersion = "appversion/getVersion"
    case getBpmData = "mslbpm/api_getdata"
    case getBpmTime = "mslLast/lastBpmTime"
    case getArrListData = "mslecgarr/arrWritetime?" // List, Data
    case getArrCnt = "mslecgarr/arrCount?" // Cnt
    case getHourlyData = "mslecgday/day"
    case getStressData = "mslecgstress/ecgStressData?"
    
    // GET: User Data
    case getProfile = "msl/Profile"
    case getFindID = "msl/findID?"
    case getCheckLogin = "msl/CheckLogin"   // CheckLogin, Send Firebase Token
    case getCheckDupID = "msl/CheckIDDupe"
    case getInspectionMessage = "appversion/upgrade"
    
    // GET: Auth
    case getSendSms = "mslSMS/sendSMS"
    case getCheckSMS = "mslSMS/checkSMS"
    case getCheckPhoneNumber = "msl/checkPhone?"
    case getAppKey = "msl/appKey?"
    
    
    // GET: Exercise
    case getExerciseList = "exercise/list?"
    case getExerciseData = "exercise/data?"
    
    
    // Google Auth
    case googleAuth = "google/callback"
    case googleHtml = "google/html"
    case emailAuth = "mslSMS/sendEmail?"
    
    // POST: HealthData
    case postTenSecondData = "mslbpm/api_data"
    case postHourlyData = "mslecgday/api_getdata"
    case postEcgData = "mslecgbyte/api_getdata"
    case postArrData = "mslecgarr/api_getdata"
    
    // POST: User
    case postSetProfile = "msl/api_getdata" // profile, appKey
    case postSetGuardian = "mslparents/api_getdata"
    
    // POST: Log
    case postLog = "app_log/api_getdata"
    case postBleLog = "app_ble/api_getdata"
    
    // POST: Exercise
    case postExerciseData = "exercise/create"
    case deleteExerciseData = "exercise/delete"
    
    // POST: BLE
    case postSerialNumber = "mslLast/api_getdata"
    
    /* WSS */
    case wssEcg = "/Ecg"
    case webEcg = "/realEcg"
    case wssSendEmail = "/Email"
}
