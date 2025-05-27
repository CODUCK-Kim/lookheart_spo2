import Foundation
import DGCharts
import UIKit

@available(iOS 13.0, *)
public class ArrViewController : UIViewController {
    
    // ----------------------------- Image ------------------- //
    private let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 20, weight: .light)
    private lazy var calendarImage =  UIImage( systemName: "calendar", withConfiguration: symbolConfiguration)?.withTintColor(.darkGray, renderingMode: .alwaysOriginal)
    // Image End
    
    private struct ArrDateTagStruct {
        var writeDateTime: String
        var emergencyFlag: Bool
        var address: String?
    }
    
    private let SELECTED_COLOR = UIColor(red: 83/255, green: 136/255, blue: 247/255, alpha: 1.0)
    private let DESELECTED_COLOR = UIColor(red: 234/255, green: 235/255, blue: 237/255, alpha: 1.0)
    private let BLACK_COLOR = UIColor.black
    private let HEARTATTACK_COLOR = UIColor(red: 239/255, green: 80/255, blue: 123/255, alpha: 1.0)
    
    private let YESTERDAY_BUTTON_FLAG = 1
    private let TOMORROW_BUTTON_FLAG = 2
    
    private let YESTERDAY = false
    private let TOMORROW = true
    
    private let YEAR_FLAG = true
    private let TIME_FLAG = false
    
    private var calendar = Calendar.current
    private let screenWidth = UIScreen.main.bounds.width
    
    private var targetDate: String = DateTimeManager.shared.getCurrentLocalDate()
    
    private var arrDateTagDict: [Int : ArrDateTagStruct] = [:]
    
    private var arrDateArray: [String] = []
    private var arrFilePath: [String] = []
    private var arrDataEntries: [ChartDataEntry] = []
    
    private var idxButtonList: [UIButton] = []
    private var titleButtonList: [UIButton] = []
    private var arrNumber = 1
    
    private var emergencyIdxButtonList: [UIButton] = []
    private var emergencyTitleButtonList: [UIButton] = []
    private var emergencyList: [String: String] = [:]
    private var emergencyNumber = 1
    
    private var isArrViewLoaded: Bool = false
    
    private var arrService = ArrService()
    private let ecgDataConversion = EcgDataConversion()
    
    // MARK: - UI VAR
    private let safeAreaView = UIView()
    
    //    ----------------------------- Loding Bar -------------------    //
    private lazy var activityIndicator = UIActivityIndicatorView().then {
        // indicator 스타일 설정
        $0.style = UIActivityIndicatorView.Style.large
    }
    
    private lazy var calendarButton = UIButton(type: .custom).then {
        $0.setImage(calendarImage, for: .normal)
        $0.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 100)
        $0.addTarget(self, action: #selector(calendarButtonEvent(_:)), for: .touchUpInside)
    }
    
    //    ----------------------------- FSCalendar -------------------    //
    private lazy var fsCalendar = CustomCalendar(frame: CGRect(x: 0, y: 0, width: 300, height: 300)).then {
        $0.isHidden = true
    }
    
    //    ----------------------------- Chart -------------------    //
    private lazy var chartView = LineChartView().then {
        $0.xAxis.enabled = false
        $0.noDataText = ""
    
        $0.rightAxis.enabled = false
        $0.legend.enabled = false
        $0.drawMarkers = false
        $0.dragEnabled = false
        $0.pinchZoomEnabled = false
        $0.doubleTapToZoomEnabled = false
        $0.highlightPerTapEnabled = false
        $0.chartDescription.enabled = true
        $0.chartDescription.font = .systemFont(ofSize: 20)
    }
    
    private let arrState = UILabel().then {
        $0.text = ""
        $0.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        $0.textColor = .black
        $0.numberOfLines = 2
        $0.isHidden = false
    }
    
    private let arrStateLabel = UILabel().then {
        $0.text = "msg_arr_type".localized()
        $0.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        $0.textColor = .darkGray
        $0.numberOfLines = 2
        $0.isHidden = false
    }
    
    private let bodyState = UILabel().then {
        $0.text = ""
        $0.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        $0.textColor = .black
        $0.isHidden = false
    }
    
    private let bodyStateLabel = UILabel().then {
        $0.text = "msg_arr_status".localized()
        $0.font = UIFont.systemFont(ofSize: 14, weight: .medium) // 크기, 굵음 정도 설정
        $0.textColor = .darkGray
        $0.isHidden = false
    }
    
    
    //    ----------------------------- ARR List Contents -------------------    //
    private let listBackground = UILabel().then {   $0.isUserInteractionEnabled = true   }
    
    private lazy var todayDisplay = UILabel().then {
        $0.text = targetDate
        $0.textColor = .black
        $0.textAlignment = .center
        $0.baselineAdjustment = .alignCenters
        $0.font = UIFont.systemFont(ofSize: 20, weight: .bold)
    }
    
    private lazy var yesterdayButton = UIButton().then {
        $0.setImage(leftArrow, for: UIControl.State.normal)
        $0.tag = YESTERDAY_BUTTON_FLAG
        $0.addTarget(self, action: #selector(shiftDate(_:)), for: .touchUpInside)
    }
    
    private lazy var tomorrowButton = UIButton().then {
        $0.setImage(rightArrow, for: UIControl.State.normal)
        $0.tag = TOMORROW_BUTTON_FLAG
        $0.addTarget(self, action: #selector(shiftDate(_:)), for: .touchUpInside)
    }
    
    private let scrollView = UIScrollView()
    
    private var arrList = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 10
    }
    
    // MARK: - Button Event
    @objc func calendarButtonEvent(_ sender: UIButton) {
        fsCalendar.isHidden = !fsCalendar.isHidden
        chartView.isHidden = !chartView.isHidden
    }
    
    @objc func shiftDate(_ sender: UIButton) {
        switch(sender.tag) {
        case YESTERDAY_BUTTON_FLAG:
            dateCalculate(shouldAdd: false)
        default:
            dateCalculate(shouldAdd: true)  // tomorrow
        }
        
        showArrDataList()
    }
    
    private func buttonEnable() {
        yesterdayButton.isEnabled = !yesterdayButton.isEnabled
        tomorrowButton.isEnabled = !tomorrowButton.isEnabled
        calendarButton.isEnabled = !calendarButton.isEnabled
    }
    
    // MARK: - viewDidLoad
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        addViews()
        
        setCalendarClosure()
    }
    
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        dissmissCalendar()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initVar()
        showArrDataList()
    }
    
    func initVar() {
        targetDate = DateTimeManager.shared.getCurrentLocalDate()
        
        dissmissCalendar()
    }
    
    //MARK: - setTable
    func showArrDataList() {
        initArray()
        getArrList()
    }
    
    
    func getArrList() {
        activityIndicator.startAnimating()
        
        Task {
            let (arrDataList, response) = await arrService.getArrList(
                startDate: getStartDate(),
                endDate: getEndDate()
            )
                    
            switch response {
            case .success:
                let arrDataList = arrDataList?.filter {
                    DateTimeManager.shared.checkLocalDate(
                        utcDateTime: $0.writetime,
                        localDate: targetDate
                    )
                }
                
                if let arrDataList = arrDataList {
                    self.setArrList(arrDateList: arrDataList)
                } else {
                    toastMessage("dialog_error_noData".localized())
                }
            case .session, .notConnected:
                toastMessage("dialog_error_server_noData".localized())
            default:
                toastMessage("dialog_error_noData".localized())
            }
            
            self.activityIndicator.stopAnimating()
        }
    }
    
    private func getStartDate() -> String {
        return DateTimeManager.shared.localDateStartToUtcDateString(targetDate) ?? targetDate
    }
    
    private func getEndDate() -> String {
        if let endUtcDate = DateTimeManager.shared.localDateEndToUtcDateString(targetDate) {
            return DateTimeManager.shared.adjustDate(
                endUtcDate,
                offset: 1,
                component: .day
            ) ?? targetDate
        } else {
            return targetDate
        }
    }

    // MARK: - Select Arr Data
    private func selectArrData(_ dict: ArrDateTagStruct) {
        activityIndicator.startAnimating()
        
        Task {
            let getArrData = await arrService.getArrData(
                startDate: dict.writeDateTime,
                emergency: dict.emergencyFlag
            )
            
            let data = getArrData.0
            let response = getArrData.1
            
            switch response {
            case .success:
                self.arrChart(data, dict)
            default:
                toastMessage("dialog_error_noData".localized())
            }
        }
    }

    private func setArrList(arrDateList: [ArrDateEntry]) {
        for (idx, arrDate) in arrDateList.enumerated() {
            let emergencyFlag = arrDate.address != nil
            
            let localDateTime = DateTimeManager.shared.convertUtcToLocal(utcTimeStr: arrDate.writetime) ?? arrDate.writetime
            let idxButton = setIdxButton(idx, emergencyFlag)
            let titleButton = setTitleButton(idx, localDateTime)
            
            let background = UILabel().then {
                $0.isUserInteractionEnabled = true
            }
            
            arrDateTagDict[idx] = ArrDateTagStruct(
                writeDateTime: arrDate.writetime,
                emergencyFlag: emergencyFlag,
                address: arrDate.address
            )
            
            arrList.addArrangedSubview(background)
            idxButtonList.append(idxButton)
            titleButtonList.append(titleButton)
            
            setButtonConstraint(background, idxButton, titleButton)
        }
        
        if arrDateList.count >= 10 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.scrollToBottom()
            }
        }
    }
    
    // MARK: - Chart
    private func arrChart(_ arrData: ArrData?, _ dict: ArrDateTagStruct) {
        if let arrData = arrData {
            if arrData.data.count < 400 {   return  }
            
            activityIndicator.stopAnimating()
                        
            arrDataEntries = []
            
            stateIsHidden(isHidden: false)
            
            if dict.emergencyFlag {
                if let address = dict.address {
                    setEmergencyText(location: address)
                }
            } else {
                setState(bodyType: arrData.bodyStatus,
                         arrType: arrData.type)
            }
            
            for i in 0...arrData.data.count - 1{
//                let ecgData = ecgDataConversion.conversion(arrData.data[i])
//                let arrDataEntry = ChartDataEntry(x: Double(i), y: Double(ecgData))
                let arrDataEntry = ChartDataEntry(x: Double(i), y: Double(arrData.data[i]))
                arrDataEntries.append(arrDataEntry)
            }
            
            let arrChartDataSet = LineChartDataSet(entries: arrDataEntries, label: "Peak")
            arrChartDataSet.drawCirclesEnabled = false
            arrChartDataSet.setColor(dict.emergencyFlag ? NSUIColor(red: 239/255, green: 80/255, blue: 123/255, alpha: 1.0) : NSUIColor.blue)
            arrChartDataSet.mode = .linear
            arrChartDataSet.drawValuesEnabled = false
            

            chartView.leftAxis.axisMaximum = if arrData.data.max() ?? 0 > 1000 { 4096 } else { 1024 }
            chartView.leftAxis.axisMinimum = 0
            chartView.data = LineChartData(dataSet: arrChartDataSet)
            chartView.data?.notifyDataChanged()
            chartView.notifyDataSetChanged()
            chartView.moveViewToX(0)
        } else {
            print("Error arrChart : nil")
        }
    }

    private func setState(bodyType: String, arrType: String){
        arrStateLabel.text = "msg_arr_type".localized()
        bodyState.text = getBodyType(bodyType)
        arrState.text = getArrType(arrType)
    }
    
    private func getArrType(_ arrType: String ) -> String {
        switch (arrType) {
        case "fast":
            return "msg_type_fast_arr".localized()
        case "slow":
            return "msg_type_slow_arr".localized()
        case "irregular":
            return "msg_type_heavy_arr".localized()
        default:    // "arr"
            return "msg_type_arr".localized()
        }
    }
    
    private func getBodyType(_ bodyType: String ) -> String {
        switch (bodyType){
        case "E":
            return "msg_status_exercise".localized()
        case "S":
            return "msg_status_sleep".localized()
        default:    // "R"
            return "msg_status_rest".localized()
        }
    }
    
    // MARK: -
    func dateCalculate(shouldAdd: Bool) {
        if let moveDate = DateTimeManager.shared.adjustDate(targetDate, offset: shouldAdd ? 1 : -1, component: .day) {
            targetDate = moveDate
            todayDisplay.text = targetDate
        }
    }

    // MARK: - Button Event
    func setIdxButton(_ idx: Int, _ flag: Bool) -> UIButton {
        let arrIdxButton = UIButton()
        let title = flag ? "E" : String(idx + 1)
        
        arrIdxButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .heavy)
        arrIdxButton.titleLabel?.textAlignment = .center
        
        arrIdxButton.setTitle(title, for: .normal)
        arrIdxButton.setTitleColor(.white, for: .normal)
        
        arrIdxButton.backgroundColor = .black
        
        arrIdxButton.layer.cornerRadius = 10
        arrIdxButton.layer.borderWidth = 3
        arrIdxButton.clipsToBounds = true
        arrIdxButton.tag = idx
        
        arrIdxButton.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        
        return arrIdxButton
    }
    
    func setTitleButton(_ idx: Int,_ title: String) -> UIButton {
        let arrTitleButton = UIButton()
        
        arrTitleButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .heavy)
        arrTitleButton.titleLabel?.textAlignment = .center
        
        arrTitleButton.setTitle(title, for: .normal)
        arrTitleButton.setTitleColor(.black, for: .normal)
        
        arrTitleButton.setBackgroundColor(.white, for: .normal)
        
        arrTitleButton.layer.borderColor = UIColor(red: 234/255, green: 235/255, blue: 237/255, alpha: 1.0).cgColor
        arrTitleButton.layer.cornerRadius = 10
        arrTitleButton.layer.borderWidth = 3
        arrTitleButton.tag = idx
        
        arrTitleButton.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        
        return arrTitleButton
    }
    
    @objc func buttonTapped(_ sender: UIButton) {
        if let arrStruct = arrDateTagDict[sender.tag] {
            selectArrData(arrStruct)
            updateButtonColor(sender.tag, arrStruct.emergencyFlag)
        }
    }
    
    
    private func updateButtonColor(_ tag: Int, _ emergencyFlag: Bool) {
        // IDX
        for button in idxButtonList {
            if idxButtonList[tag] == button {
                button.backgroundColor = emergencyFlag ? HEARTATTACK_COLOR : SELECTED_COLOR
                button.layer.borderColor = emergencyFlag ? HEARTATTACK_COLOR.cgColor : SELECTED_COLOR.cgColor
            } else {
                button.backgroundColor = BLACK_COLOR
                button.layer.borderColor = BLACK_COLOR.cgColor
            }
        }
        
        // TITLE
        for button in titleButtonList {
            if titleButtonList[tag] == button {
                button.layer.borderColor = emergencyFlag ? HEARTATTACK_COLOR.cgColor : SELECTED_COLOR.cgColor
            } else {
                button.layer.borderColor = DESELECTED_COLOR.cgColor
            }
        }
    }
    
    
    // MARK: -
    func setButtonConstraint(_ background: UILabel, _ arrIdxButton: UIButton, _ arrTitleButton: UIButton) {
        
        background.snp.makeConstraints { make in
            make.left.right.equalTo(arrList)
            make.height.equalTo(50)
        }
        
        background.addSubview(arrIdxButton)
        arrIdxButton.snp.makeConstraints { make in
            make.top.left.bottom.equalTo(background)
            make.width.equalTo(screenWidth / 7.0)
        }
        
        background.addSubview(arrTitleButton)
        arrTitleButton.snp.makeConstraints { make in
            make.top.bottom.equalTo(background)
            make.left.equalTo(arrIdxButton.snp.right).offset(10)
            make.right.equalTo(background).offset(-10)
        }
        
    }
    

    
    func reconstructedPath(_ path: URL) -> String? {
        if let documentsIndex = path.pathComponents.firstIndex(of: "arrECGData") {
            let desiredPathComponents = path.pathComponents[(documentsIndex + 1)...]
            return desiredPathComponents.joined(separator: "/")
        }
        return nil
    }
    
    func resetArrList() {
        for subview in self.arrList.subviews {
            subview.removeFromSuperview()
        }
    }
    
    func stateIsHidden(isHidden: Bool) {
        bodyState.isHidden = isHidden
        bodyStateLabel.isHidden = isHidden
        arrState.isHidden = isHidden
        arrStateLabel.isHidden = isHidden
    }
    
    private func setEmergencyText(location: String) {
        arrState.text = "\(location)"
        arrStateLabel.text = "msg_arr_emergency".localized()
        bodyState.isHidden = true
        bodyStateLabel.isHidden = true
    }
    
    func scrollToBottom() {
        scrollView.setContentOffset(CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.bounds.height), animated: true)
    }
    
    func initArray() {
        resetArrList()
        dissmissCalendar()
        stateIsHidden(isHidden: true)
        
        chartView.clear()
        
        arrDateArray = []
        arrFilePath = []
        arrDataEntries = []
        
        idxButtonList = []
        titleButtonList = []
        arrNumber = 1
        
        emergencyList = [:]
        emergencyIdxButtonList = []
        emergencyTitleButtonList = []
        emergencyNumber = 1
    }
    
    func toastMessage(_ message: String) {
        // chartView의 중앙 좌표 계산
        let chartViewCenterX = chartView.frame.size.width / 2
        let chartViewCenterY = chartView.frame.size.height / 2

        // 토스트 컨테이너의 크기
        let containerWidth: CGFloat = chartView.frame.width - 60
        let containerHeight: CGFloat = 35

        // 토스트 컨테이너가 chartView 중앙에 오도록 위치 조정
        let toastPositionX = chartViewCenterX - containerWidth / 2
        let toastPositionY = chartViewCenterY - containerHeight / 2
        
        ToastHelper.shared.showChartToast(self.view, message, position: CGPoint(x: toastPositionX, y: toastPositionY))

    }
    
    private func setCalendarClosure() {
        fsCalendar.didSelectDate = { [self] date in
            targetDate = DateTimeManager.shared.getFormattedLocalDateString(date)

            todayDisplay.text = targetDate
            
            initArray()
            getArrList()
            
            fsCalendar.isHidden = true
            chartView.isHidden = false
        }
    }
    
    private func dissmissCalendar() {
        if (!fsCalendar.isHidden) {
            fsCalendar.isHidden = true
            chartView.isHidden = false
        }
    }
    
    // MARK: - addViews
    private func addViews() {
        view.addSubview(safeAreaView)
        safeAreaView.snp.makeConstraints { make in
            make.top.bottom.equalTo(view.safeAreaLayoutGuide)
            make.left.right.equalToSuperview()
        }
        
        view.addSubview(chartView)
        chartView.snp.makeConstraints { make in
            make.top.left.right.equalTo(safeAreaView)
            make.height.equalTo(safeAreaView).multipliedBy(4.5 / (4.5 + 5.5))
        }
        
        view.addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints { make in
            make.centerX.centerY.equalTo(chartView)
        }
        
        view.addSubview(arrState)
        arrState.snp.makeConstraints { make in
            make.right.equalTo(safeAreaView).offset(-20)
            make.top.equalTo(chartView.snp.bottom).offset(10)
        }
        
        view.addSubview(arrStateLabel)
        arrStateLabel.snp.makeConstraints { make in
            make.right.equalTo(arrState.snp.left).offset(-10)
            make.top.equalTo(arrState)
        }
        
        view.addSubview(bodyState)
        bodyState.snp.makeConstraints { make in
            make.right.equalTo(arrStateLabel.snp.left).offset(-10)
            make.top.equalTo(arrStateLabel)
        }
        
        view.addSubview(bodyStateLabel)
        bodyStateLabel.snp.makeConstraints { make in
            make.right.equalTo(bodyState.snp.left).offset(-10)
            make.top.equalTo(bodyState)
        }
                
        view.addSubview(listBackground)
        listBackground.snp.makeConstraints { make in
            make.top.equalTo(chartView.snp.bottom).offset(50)
            make.left.right.bottom.equalTo(safeAreaView)
        }
        
        listBackground.addSubview(todayDisplay)
        todayDisplay.snp.makeConstraints { make in
            make.top.equalTo(listBackground)
            make.centerX.equalTo(listBackground)
        }
        
        listBackground.addSubview(calendarButton)
        calendarButton.snp.makeConstraints { make in
            make.centerY.equalTo(todayDisplay)
            make.left.equalTo(todayDisplay.snp.left).offset(-30)
        }
        
        listBackground.addSubview(yesterdayButton)
        yesterdayButton.snp.makeConstraints { make in
            make.left.equalTo(listBackground).offset(10)
            make.centerY.equalTo(todayDisplay)
        }
        
        listBackground.addSubview(tomorrowButton)
        tomorrowButton.snp.makeConstraints { make in
            make.right.equalTo(listBackground).offset(-10)
            make.centerY.equalTo(todayDisplay)
        }
        
        listBackground.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(todayDisplay.snp.bottom).offset(20)
            make.left.equalTo(listBackground).offset(10)
            make.right.equalTo(listBackground)
            make.bottom.equalTo(listBackground).offset(-10)
        }
        
        scrollView.addSubview(arrList)
        arrList.snp.makeConstraints { make in
            make.top.bottom.width.equalTo(scrollView)
        }
        
        view.addSubview(fsCalendar)
        fsCalendar.snp.makeConstraints { make in
            make.centerY.centerX.equalTo(chartView)
            make.height.equalTo(300)
            make.width.equalTo(300)
        }
    }
}

