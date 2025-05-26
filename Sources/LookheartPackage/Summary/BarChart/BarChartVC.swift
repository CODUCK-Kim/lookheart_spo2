import Foundation
import UIKit
import DGCharts

@available(iOS 13.0, *)
class BarChartVC : UIViewController {
    
    private var email = String()
    private var chartType: BarChartType = .ARR
    
    enum DateType: Int {
        case DAY = 1
        case WEEK = 2
        case MONTH = 3
        case YEAR = 4
    }
    
    struct HourlyDataStruct {
        var arrCnt: Double = 0.0
        var step: Double = 0.0
        var distance: Double = 0.0
        var cal: Double = 0.0
        var activityCal: Double = 0.0
        
        mutating func updateData(_ data: HourlyData) {
            arrCnt += data.toDouble(data.arrCnt)
            activityCal += data.toDouble(data.activityCal)
            cal += data.toDouble(data.cal)
            step += data.toDouble(data.step)
            distance += data.toDouble(data.distance)
        }
    }

    // ----------------------------- Image ------------------- //
    private let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 20, weight: .light)
    private lazy var calendarImage =  UIImage( systemName: "calendar", withConfiguration: symbolConfiguration)?.withTintColor(.darkGray, renderingMode: .alwaysOriginal)
    // Image End
    
    // ----------------------------- 상수 ------------------- //
    private let weekDays = [
        "unit_monday".localized(),
        "unit_tuesday".localized(),
        "unit_wednesday".localized(),
        "unit_thursday".localized(),
        "unit_friday".localized(),
        "unit_saturday".localized(),
        "unit_sunday".localized()
    ]
    
    private let YESTERDAY_BUTTON_FLAG = 1, TOMORROW_BUTTON_FLAG = 2
    private let DAY_FLAG = 1, WEEK_FLAG = 2, MONTH_FLAG = 3, YEAR_FLAG = 4
    
    private let PLUS_DATE = true, MINUS_DATE = false
    // 상수 END
    
    // ----------------------------- UI ------------------- //
    // 보여지는 변수
    private var firstGoal = 0, secondGoal = 0   // 목표값
    
    // UI VAR END
    
    // ----------------------------- DATE ------------------- //
    // 날짜 변수
    private let dateFormatter = DateFormatter()
    private let timeFormatter = DateFormatter()
    private var calendar = Calendar.current
    private var targetDate = String()
    // DATE END
    
    // ----------------------------- CHART ------------------- //
    // 차트 관련 변수
    private var currentButtonFlag: DateType = .DAY   // 현재 버튼 플래그가 저장되는 변수
    private var buttonList:[UIButton] = []
    // CHART END
    
    private let graphService = GraphService()
    
    
    
    // MARK: - UI VAR
    private let safeAreaView = UIView()
    
    //    ----------------------------- Loding Bar -------------------    //
    private lazy var activityIndicator = UIActivityIndicatorView().then {
        // indicator 스타일 설정
        $0.style = UIActivityIndicatorView.Style.large
    }
    
    //    ----------------------------- FSCalendar -------------------    //
    private lazy var fsCalendar = CustomCalendar(frame: CGRect(x: 0, y: 0, width: 300, height: 300)).then {
        $0.isHidden = true
    }
    
    //    ----------------------------- Chart -------------------    //
    // Cal, Step : $0.xAxis.centerAxisLabelsEnabled = true
    private lazy var barChartView = BarChartView().then {
        $0.legend.font = .systemFont(ofSize: 15, weight: .bold)
        $0.noDataText = ""
        $0.xAxis.enabled = true
        $0.xAxis.granularity = 1
        $0.xAxis.labelPosition = .bottom
        $0.xAxis.drawGridLinesEnabled = false
        $0.leftAxis.granularityEnabled = true
        $0.leftAxis.granularity = 1.0
        $0.leftAxis.axisMinimum = 0
        $0.rightAxis.enabled = false
        $0.drawMarkers = false
        $0.dragEnabled = true
        $0.pinchZoomEnabled = false
        $0.doubleTapToZoomEnabled = false
        $0.highlightPerTapEnabled = false
    }
    
    private let bottomContents = UILabel().then {  $0.isUserInteractionEnabled = true  }
    
    private let topContents = UILabel().then {  $0.isUserInteractionEnabled = true  }
    
    private let middleContents = UILabel().then {  $0.isUserInteractionEnabled = true  }
    
    // CAL, STEP
    private lazy var doubleGraphBottomContents = UIStackView(arrangedSubviews: [topBackground, bottomBackground]).then {
        $0.axis = .vertical
        $0.distribution = .fillEqually // default
        $0.alignment = .fill // default
        $0.spacing = 5
    }
    
    // ARR
    private lazy var singleGraphBottomContents = UIStackView(arrangedSubviews: [singleContentsLabel, singleContentsValueLabel]).then {
        $0.axis = .horizontal
        $0.distribution = .fillEqually
        $0.alignment = .fill
    }
    
    // MARK: - top Contents
    private lazy var dayButton = UIButton().then {
        $0.setTitle ("unit_day".localized(), for: .normal )
        
        $0.setTitleColor(.lightGray, for: .normal)
        $0.setTitleColor(.white, for: .selected)
        $0.setTitleColor(.lightGray, for: .disabled)
        
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        $0.setBackgroundColor(UIColor.MY_LIGHT_GRAY_BORDER, for: .normal)
        $0.setBackgroundColor(UIColor.MY_LIGHT_GRAY_BORDER, for: .disabled)
        $0.setBackgroundColor(UIColor.MY_BODY_STATE, for: .selected)
        
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 15
        $0.isSelected = true
        
        $0.tag = DAY_FLAG
        $0.addTarget(self, action: #selector(selectDayButton(_:)), for: .touchUpInside)
    }
    
    private lazy var weekButton = UIButton().then {
        $0.setTitle ("unit_week".localized(), for: .normal )
        
        $0.setTitleColor(.lightGray, for: .normal)
        $0.setTitleColor(.white, for: .selected)
        $0.setTitleColor(.lightGray, for: .disabled)
        
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        $0.setBackgroundColor(UIColor.MY_LIGHT_GRAY_BORDER, for: .normal)
        $0.setBackgroundColor(UIColor.MY_LIGHT_GRAY_BORDER, for: .disabled)
        $0.setBackgroundColor(UIColor.MY_BODY_STATE, for: .selected)
        
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 15
        
        $0.tag = WEEK_FLAG
        $0.addTarget(self, action: #selector(selectDayButton(_:)), for: .touchUpInside)
    }
    
    private lazy var monthButton = UIButton().then {
        $0.setTitle ("unit_month".localized(), for: .normal )
        $0.setTitleColor(.lightGray, for: .normal)
        $0.setTitleColor(.white, for: .selected)
        $0.setTitleColor(.lightGray, for: .disabled)
        
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        $0.setBackgroundColor(UIColor.MY_LIGHT_GRAY_BORDER, for: .normal)
        $0.setBackgroundColor(UIColor.MY_LIGHT_GRAY_BORDER, for: .disabled)
        $0.setBackgroundColor(UIColor.MY_BODY_STATE, for: .selected)
                
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 15
        
        $0.tag = MONTH_FLAG
        $0.addTarget(self, action: #selector(selectDayButton(_:)), for: .touchUpInside)
    }
    
    lazy var yearButton = UIButton().then {
        $0.setTitle ("unit_year".localized(), for: .normal )
        $0.setTitleColor(.lightGray, for: .normal)
        $0.setTitleColor(.white, for: .selected)
        $0.setTitleColor(.lightGray, for: .disabled)
        
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        $0.setBackgroundColor(UIColor.MY_LIGHT_GRAY_BORDER, for: .normal)
        $0.setBackgroundColor(UIColor.MY_LIGHT_GRAY_BORDER, for: .disabled)
        $0.setBackgroundColor(UIColor.MY_BODY_STATE, for: .selected)
        
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 15
        
        $0.tag = YEAR_FLAG
        $0.addTarget(self, action: #selector(selectDayButton(_:)), for: .touchUpInside)
    }
    
    // MARK: - middle Contents
    private lazy var todayDisplay = UILabel().then {
        $0.text = "-"
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
    
    private lazy var calendarButton = UIButton(type: .custom).then {
        $0.setImage(calendarImage, for: .normal)
        $0.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 100)
        $0.addTarget(self, action: #selector(calendarButtonEvent(_:)), for: .touchUpInside)
    }
    
    // MARK: - bottom Contents
    //    ----------------------------- ARR -------------------    //
    private let singleContentsLabel = UILabel().then {
        $0.text = "unit_arr_times".localized()
        $0.numberOfLines = 2
        $0.textColor = .darkGray
        $0.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        $0.textAlignment = .center
    }
    
    private let singleContentsValueLabel = UILabel().then {
        $0.text = "0"
        $0.textColor = .darkGray
        $0.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        $0.textAlignment = .center
    }
    
    //    ----------------------------- STEP, CAL -------------------    //
    private lazy var topBackground = UIStackView(arrangedSubviews: [topTitleLabel, topProgress]).then {
        $0.axis = .vertical
        $0.distribution = .fillEqually
        $0.alignment = .fill
        $0.spacing = 10
        $0.isLayoutMarginsRelativeArrangement = true
        $0.layoutMargins = UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0)
    }
    private lazy var bottomBackground = UIStackView(arrangedSubviews: [bottomTitleLabel, bottomProgress]).then {
        $0.axis = .vertical
        $0.distribution = .fillEqually
        $0.alignment = .fill
        $0.spacing = 10
        $0.isLayoutMarginsRelativeArrangement = true
        $0.layoutMargins = UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0)
    }
    
    private let topProgress = UIProgressView().then {
        $0.trackTintColor = UIColor.MY_LIGHT_GRAY_BORDER
        $0.progressTintColor = UIColor.PROGRESSBAR_RED
        $0.progress = 0.0
        $0.layer.cornerRadius = 10
        $0.layer.masksToBounds = true
    }
    private let bottomProgress = UIProgressView().then {
        $0.trackTintColor = UIColor.MY_LIGHT_GRAY_BORDER
        $0.progressTintColor = UIColor.PROGRESSBAR_BLUE
        $0.progress = 0.0
        $0.layer.cornerRadius = 10
        $0.layer.masksToBounds = true
    }
    
    private let topTitleLabel = UILabel().then {
        $0.text = "unit_step_cap".localized()
        $0.textAlignment = .center
        $0.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        $0.textColor = .black
    }
    
    private let bottomTitleLabel = UILabel().then {
        $0.text = "unit_travel_distance".localized()
        $0.textAlignment = .center
        $0.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        $0.textColor = .black
    }
        
    private let topValue = UILabel().then {
        $0.text = "-"
        $0.textAlignment = .center
        $0.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        $0.textColor = .black
    }
    
    private let bottomValue = UILabel().then {
        $0.text = "-"
        $0.textAlignment = .center
        $0.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        $0.textColor = .black
    }
    
    private let topValueProcent = UILabel().then {
        $0.text = "-"
        $0.textAlignment = .center
        $0.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        $0.textColor = .black
    }
    
    private let bottomValueProcent = UILabel().then {
        $0.text = "-"
        $0.textAlignment = .center
        $0.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        $0.textColor = .black
    }
    
    private let bottomLine = UILabel().then {   $0.backgroundColor = .lightGray }
    private let bottomValueContents = UILabel()
    
    // MARK: - Button Event
    @objc func shiftDate(_ sender: UIButton) {
        moveDate(shouldAdd: sender.tag == TOMORROW_BUTTON_FLAG)
        updateDisplayText()
        
        if let startDate = getStartDate(),
           let endDate = getEndDate() {
            showChart(
                startDate: startDate,
                endDate: endDate
            )
        }
    }
        
    @objc func selectDayButton(_ sender: UIButton) {
        updateDateType(tag: sender.tag)
        updateDisplayText()
        setButtonColor(sender)
        
        if let startDate = getStartDate(),
           let endDate = getEndDate() {
            showChart(
                startDate: startDate,
                endDate: endDate
            )
        }
    }
    
    @objc func calendarButtonEvent(_ sender: UIButton) {
        fsCalendar.isHidden = !fsCalendar.isHidden
        barChartView.isHidden = !barChartView.isHidden
    }
    
    private func buttonEnable() {
        yesterdayButton.isEnabled = !yesterdayButton.isEnabled
        tomorrowButton.isEnabled = !tomorrowButton.isEnabled
        dayButton.isEnabled = !dayButton.isEnabled
        weekButton.isEnabled = !weekButton.isEnabled
        monthButton.isEnabled = !monthButton.isEnabled
        yearButton.isEnabled = !yearButton.isEnabled
    }
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initVar()
        
        addViews()
        
        setCalendarClosure()
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        dissmissCalendar()
    }
    
    public func refreshView(_ type: BarChartType) {
        chartType = type
        currentButtonFlag = .DAY
        targetDate = DateTimeManager.shared.getCurrentLocalDate()
        
        updateDisplayText()
        setUI()
        setButtonColor(dayButton)
        
        if let startDate = getStartDate(),
           let endDate = getEndDate() {
            showChart(
                startDate: startDate,
                endDate: endDate
            )
        }
        
    }
    
    func initVar() {
        buttonList = [dayButton, weekButton, monthButton, yearButton]
    }
    
    // MARK: - CHART FUNC
    private func showChart(
        startDate: String,
        endDate: String
    ) {
        initUI()
        
        Task { @MainActor in
            if let hourlyDataList = await getDataToServer(startDate, endDate) {
                let (firstMap, secondMap) = self.getChartDataMap(hourlyDataList: hourlyDataList)
                
                if !firstMap.isEmpty {
                    // chart
                    let (sortedFirstMap, sortedSecondMap) = self.sortedMap(firstMap, secondMap)
                    let barChartDataSets = self.getBarChartDataSets(sortedFirstMap, sortedSecondMap)

                    self.updateBarChart(
                        chartData: barChartDataSets,
                        timeTable: sortedFirstMap.map { $0.0 }
                    )
                    
                    // value
                    self.updateValue(
                        firstValue: firstMap.values.compactMap { $0 }.reduce(0, +),
                        secondValue: secondMap.values.compactMap { $0 }.reduce(0, +)
                    )
                } else {
                    toastMessage("dialog_error_noData".localized())
                }
            }
        }
    }
    
    private func getDataToServer(
        _ startDate: String,
        _ endDate: String
    ) async -> [HourlyData]? {
        await MainActor.run { activityIndicator.startAnimating() }
    
        let (data, response) = await graphService.getHourlyData(
            startDate: startDate,
            endDate: endDate
        )
        
        await MainActor.run { activityIndicator.stopAnimating() }

        switch response {
        case .success:
            return data
        case .noData:
            await MainActor.run { toastMessage("dialog_error_noData".localized()) }
            return nil
        default:
            await MainActor.run { toastMessage("dialog_error_server_noData".localized()) }
            return nil
        }
    }
    
    
    // MARK: - data map
    private func getChartDataMap(
        hourlyDataList: [HourlyData]
    ) -> (firstMap: [String : Double], secondMap: [String : Double]) {
        switch (currentButtonFlag) {
        case .DAY:
            return getTodayChartMap(hourlyDataList: hourlyDataList)
        case .WEEK:
            return getWeekChartMap(hourlyDataList: hourlyDataList)
        case .MONTH:
            return getMonthChartMap(hourlyDataList: hourlyDataList)
        case .YEAR:
            return getYearChartMap(hourlyDataList: hourlyDataList)
        }
    }
    
    private func getTodayChartMap (
        hourlyDataList: [HourlyData]
    ) -> ([String : Double], [String : Double]) {
        var firstMap: [String : Double] = [:]
        var secondMap: [String : Double] = [:]
        
        let todayDataList = hourlyDataList.filter {
            $0.date == targetDate
        }
        
        todayDataList.forEach { data in
            switch (chartType) {
            case .ARR:
                firstMap[data.hour] = Double(data.arrCnt)
            case .CALORIE:
                firstMap[data.hour] = Double(data.cal)
                secondMap[data.hour] = Double(data.activityCal)
            case .STEP:
                firstMap[data.hour] = Double(data.step)
                secondMap[data.hour] = Double(data.distance)
            }
        }
        
        return (firstMap, secondMap)
    }
    
    private func getWeekChartMap (
        hourlyDataList: [HourlyData]
    ) -> ([String : Double], [String : Double]) {
        guard let monday = findMonday(targetDate) else {
          return ([:], [:])
        }
        
        let days = DayOfWeek.allCases
        let dates = (0..<7).compactMap { offset in
          DateTimeManager.shared.adjustDate(monday, offset: offset, component: .day)
        }
        
        var firstMap: [String : Double] = [:]
        var secondMap: [String : Double] = [:]
        
        for (day, date) in zip(days, dates) {
          let todayData = hourlyDataList.filter { $0.date == date }

            switch (chartType) {
            case .ARR:
                firstMap[day.name] = todayData.compactMap { Double($0.arrCnt) }.reduce(0, +)
            case .CALORIE:
                firstMap[day.name] = todayData.compactMap { Double($0.cal) }.reduce(0, +)
                secondMap[day.name] = todayData.compactMap { Double($0.activityCal) }.reduce(0, +)
            case .STEP:
                firstMap[day.name] = todayData.compactMap { Double($0.step) }.reduce(0, +)
                secondMap[day.name] = todayData.compactMap { Double($0.distance) }.reduce(0, +)
            }
        }
        
        return (firstMap, secondMap)
    }
    
    private func getMonthChartMap (
        hourlyDataList: [HourlyData]
    ) -> ([String : Double], [String : Double]) {
        var firstMap: [String: Double]  = [:]
        var secondMap: [String: Double] = [:]
        
        var date = String(targetDate.prefix(7)) + "-01"
        guard let daysInMonth = DateTimeManager.shared.daysInMonth(from: targetDate) else {
            return ([:], [:])
        }
        
        for _ in 0..<daysInMonth {
            let parts = date.split(separator: "-")
            let xValue = String(parts[2])
            
            let targetDataList = hourlyDataList.filter {
                $0.date == date
            }
            
            if !targetDataList.isEmpty {
                switch (chartType) {
                case .ARR:
                    firstMap[xValue] = targetDataList.compactMap { Double($0.arrCnt) }.reduce(0, +)
                case .CALORIE:
                    firstMap[xValue] = targetDataList.compactMap { Double($0.cal) }.reduce(0, +)
                    secondMap[xValue] = targetDataList.compactMap { Double($0.activityCal) }.reduce(0, +)
                case .STEP:
                    firstMap[xValue] = targetDataList.compactMap { Double($0.step) }.reduce(0, +)
                    secondMap[xValue] = targetDataList.compactMap { Double($0.distance) }.reduce(0, +)
                }
            }
            
            date = DateTimeManager.shared.adjustDate(date, offset: 1, component: .day) ?? date
        }
        
        return (firstMap, secondMap)
    }
    
    private func getYearChartMap (
        hourlyDataList: [HourlyData]
    ) -> ([String : Double], [String : Double]) {
        var firstMap: [String: Double]  = [:]
        var secondMap: [String: Double] = [:]
        
        let groupedByMonth: [String?: [HourlyData]] = Dictionary(
            grouping: hourlyDataList,
            by: { data in
                if data.date.count >= 7 {
                    let start = data.date.index(data.date.startIndex, offsetBy: 5)
                    let end   = data.date.index(data.date.startIndex, offsetBy: 7)
                    return String(data.date[start..<end])  // ex) "04", "11"
                } else {
                    return nil
                }
            }
        )
        
        for (maybeMonth, dataList) in groupedByMonth {
            guard let month = maybeMonth else { continue }
            
            switch (chartType) {
            case .ARR:
                let sumArr = dataList.reduce(0) { acc, item in
                    acc + (Double(item.arrCnt) ?? 0)
                }
                firstMap[month] = sumArr
            case .CALORIE:
                let sumCal = dataList.reduce(0) { acc, item in
                    acc + (Double(item.cal) ?? 0)
                }
                let sumAct = dataList.reduce(0) { acc, item in
                    acc + (Double(item.activityCal) ?? 0)
                }
                firstMap[month]  = sumCal
                secondMap[month] = sumAct
            case .STEP:
                let sumStep = dataList.reduce(0) { acc, item in
                    acc + (Double(item.step) ?? 0)
                }
                let sumDist = dataList.reduce(0) { acc, item in
                    acc + (Double(item.distance) ?? 0)
                }
                firstMap[month]  = sumStep
                secondMap[month] = sumDist
            }
        }
        
        return (firstMap, secondMap)
    }
    
    private func sortedMap(
        _ firstMap: [String : Double],
        _ secondMap: [String : Double]
    ) -> (first: [(String, Double)], second: [(String, Double)]) {
        let sortedFirstEntries: [(String, Double)]
        let sortedSecondEntries: [(String, Double)]
        
        switch currentButtonFlag {
        case .WEEK:
            let weekdayOrder = ["MON","TUE","WED","THU","FRI","SAT","SUN"]
            sortedFirstEntries = firstMap.sorted { lhs, rhs in
                (weekdayOrder.firstIndex(of: lhs.key) ?? 0)
              < (weekdayOrder.firstIndex(of: rhs.key) ?? 0)
            }
            sortedSecondEntries = secondMap.sorted { lhs, rhs in
                (weekdayOrder.firstIndex(of: lhs.key) ?? 0)
              < (weekdayOrder.firstIndex(of: rhs.key) ?? 0)
            }

        default:
            sortedFirstEntries = firstMap.sorted { lhs, rhs in
                (Int(lhs.key) ?? 0) < (Int(rhs.key) ?? 0)
            }
            sortedSecondEntries = secondMap.sorted { lhs, rhs in
                (Int(lhs.key) ?? 0) < (Int(rhs.key) ?? 0)
            }
        }
        
        return (sortedFirstEntries, sortedSecondEntries)
    }
    
    private func getBarChartDataSets(
        _ firstMap: [(String, Double)],
        _ secondMap: [(String, Double)]
    ) -> BarChartData {
        switch (chartType) {
        // single bar
        case .ARR:
            let (firstLabel, _) = getLabel()
            
            // entries
            let entries = firstMap.enumerated().map { index, element in
                BarChartDataEntry(x: Double(index), y: element.1)
            }
            // data set
            let dataSet = BarChartDataSet(entries: entries, label: firstLabel)
            dataSet.setColor(NSUIColor.GRAPH_RED)
            dataSet.valueFormatter = CombinedValueFormatter()
            
            return BarChartData(dataSets: [dataSet])
            
        // double bar
        case .CALORIE, .STEP:
            let (firstLabel, secondLabel) = getLabel()
            
            // entries
            let firstEntries = firstMap.enumerated().map { index, element in
                BarChartDataEntry(x: Double(index), y: element.1)
            }
            let scondEntries = secondMap.enumerated().map { index, element in
                BarChartDataEntry(x: Double(index), y: element.1)
            }
            
            // data set
            let firstDataSet = BarChartDataSet(entries: firstEntries, label: firstLabel)
            firstDataSet.setColor(NSUIColor.GRAPH_RED)
            firstDataSet.valueFormatter = CombinedValueFormatter()
            
            let secondDataSet = BarChartDataSet(entries: scondEntries, label: secondLabel)
            secondDataSet.setColor(NSUIColor.GRAPH_BLUE)
            secondDataSet.valueFormatter = CombinedValueFormatter()
            
            return BarChartData(dataSets: [firstDataSet, secondDataSet])
        }
    }
    
    private func getLabel() -> (firstLabel: String, secondLabel: String) {
        switch (chartType) {
        case .ARR:
            return ("unit_arr_abb".localized(), "")
        case .CALORIE:
            return ("unit_tCal".localized(), "unit_eCal".localized())
        case .STEP:
            return ("unit_step".localized(), "unit_distance".localized())
        }
    }
    
    private func updateBarChart(
        chartData: BarChartData,
        timeTable: [String]
    ) {
        let labelCount = timeTable.count
        let visibleXRangeMax = timeTable.count > 7 ? 7.5 : Double(timeTable.count)

        configureBarChartSettings(chartData: chartData, labelCnt: labelCount)
        
        barChartView.data = chartData
        barChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: timeTable)
        barChartView.setVisibleXRangeMaximum(visibleXRangeMax)
        barChartView.xAxis.setLabelCount(labelCount, force: false)
        barChartView.data?.notifyDataChanged()
        barChartView.notifyDataSetChanged()
        barChartView.moveViewToX(0)
        chartZoomOut()
    }
    
    private func updateValue(
        firstValue: Double,
        secondValue: Double
    ) {
        switch (chartType) {
        case .ARR:
            singleContentsValueLabel.text = String(Int(firstValue))
        case .CALORIE, .STEP:
            let firstLabel = chartType == .CALORIE ? "unit_kcal".localized() : "unit_step_cap".localized()
            let secondLabel = chartType == .CALORIE ? "unit_kcal".localized() : "unit_distance_km".localized()
            let dayCount = getDayCount(for: currentButtonFlag)
            
            // Progress
            let firstGoalProgress = Double(firstValue) / Double(firstGoal * dayCount)
            topProgress.progress = Float(firstGoalProgress)
            
            let secondGoalProgress = chartType == .STEP ? (Double(secondValue) / 1000.0) / Double(secondGoal * dayCount) : Double(secondValue) / Double(secondGoal * dayCount)
            bottomProgress.progress = Float(secondGoalProgress)
            
            // procent
            topValueProcent.text = String(Int(firstGoalProgress * 100)) + "%"
            bottomValueProcent.text = String(Int(secondGoalProgress * 100)) + "%"
            
            // text
            topValue.text = String(Int(firstValue)) + " " + firstLabel
            bottomValue.text = chartType == .STEP ? String(Double(Int(secondValue)) / 1000.0) + " " + secondLabel : String(Int(secondValue)) + " " + secondLabel
        }
    }

    private func configureBarChartSettings(
        chartData: BarChartData,
        labelCnt: Int
    ) {
        switch (chartType) {
        case .CALORIE, .STEP:
            let groupSpace = 0.3
            let barSpace = 0.05
            let barWidth = 0.3
            
            chartData.barWidth = barWidth
            
            barChartView.xAxis.axisMinimum = Double(0)
            barChartView.xAxis.axisMaximum = Double(0) + chartData.groupWidth(groupSpace: groupSpace, barSpace: barSpace) * Double(labelCnt)  // group count : 2
            chartData.groupBars(fromX: Double(0), groupSpace: groupSpace, barSpace: barSpace)
            
            barChartView.xAxis.centerAxisLabelsEnabled = true
            
        default:
            let defaultBarWidth = 0.85 // 기본 바 너비
            chartData.barWidth = defaultBarWidth
            
            barChartView.xAxis.resetCustomAxisMin()
            barChartView.xAxis.resetCustomAxisMax()

            barChartView.xAxis.centerAxisLabelsEnabled = false
        }
    }
    
    // MARK: - DATE FUNC
    func moveDate(shouldAdd: Bool) {
        let component: Calendar.Component = switch (currentButtonFlag) {
        case .DAY:      .day
        case .WEEK:     .weekOfYear
        case .MONTH:    .month
        case .YEAR:     .year
        }
        
        if let targetDate = DateTimeManager.shared.adjustDate(
            targetDate,
            offset: shouldAdd ? 1 : -1,
            component: component
        ) {
            self.targetDate = targetDate
        }
    }
    
    private func updateDateType(tag: Int) {
        switch (tag) {
        case DAY_FLAG:
            currentButtonFlag = .DAY
        case WEEK_FLAG:
            currentButtonFlag = .WEEK
        case MONTH_FLAG:
            currentButtonFlag = .MONTH
        case YEAR_FLAG:
            currentButtonFlag = .YEAR
        default:
            break
        }
    }
    
    func getStartDate() -> String? {
        guard let startDate = switch (currentButtonFlag) {
        case .DAY:
            targetDate
        case .WEEK:
            findMonday(targetDate)
        case .MONTH:
            String(targetDate.prefix(8)) + "01"
        case .YEAR:
            String(targetDate.prefix(4)) + "-01-01"
        } else {
            return nil
        }
        
        return DateTimeManager.shared.localDateStartToUtcDateString(startDate)
    }
    
    
    func getEndDate() -> String? {
        let baseDate: String? = {
            switch currentButtonFlag {
            case .DAY:
                return DateTimeManager.shared.localDateEndToUtcDateString(targetDate)

            case .WEEK:
                if let monday = findMonday(targetDate) {
                    return DateTimeManager.shared.localDateEndToUtcDateString(monday)
                }
                return nil
            case .MONTH:
                let firstOfMonth = String(targetDate.prefix(8)) + "01"
                return DateTimeManager.shared.localDateEndToUtcDateString(firstOfMonth)

            case .YEAR:
                let firstOfYear = String(targetDate.prefix(4)) + "-01-01"
                return DateTimeManager.shared.localDateEndToUtcDateString(firstOfYear)
            }
        }()
        
        if let endUtcDate = baseDate {
            switch (currentButtonFlag) {
            case .DAY:
                return DateTimeManager.shared.adjustDate(
                    endUtcDate,
                    offset: 1,
                    component: .day
                )
            case .WEEK:
                return DateTimeManager.shared.adjustDate(
                    endUtcDate,
                    offset: 1,
                    component: .weekOfYear
                )
            case .MONTH:
                return DateTimeManager.shared.adjustDate(
                    endUtcDate,
                    offset: 1,
                    component: .month
                )
            case .YEAR:
                return DateTimeManager.shared.adjustDate(
                    endUtcDate,
                    offset: 1,
                    component: .year
                )
            }
        } else {
            return nil
        }
    }
    
    
    func findMonday(_ dateStr: String) -> String? {
        guard let date = DateTimeManager.shared.getFormattedLocalDate(dateStr) else {
            return nil
        }

        let calendar = Calendar(identifier: .gregorian)
        // 일요일=1, 월요일=2, …, 토요일=7
        let weekday = calendar.component(.weekday, from: date)
        // 월요일=1, …, 일요일=7
        let dayOfWeek = (weekday == 1) ? 7 : (weekday - 1)
        
        let daysToSubtract = dayOfWeek - 1  // 월요일→0, 화요일→1, …
        guard let monday = calendar.date(
            byAdding: .day,
            value: -daysToSubtract,
            to: date
        ) else {
            return nil
        }
        
        return DateTimeManager.shared.getFormattedLocalDateString(monday)
    }
    
    
    private func setCalendarClosure() {
        fsCalendar.didSelectDate = { [self] date in
            targetDate = DateTimeManager.shared.getFormattedLocalDateString(date)
            
            switch (currentButtonFlag) {
            case .DAY:
                selectDayButton(dayButton)
            case .WEEK:
                selectDayButton(weekButton)
            case .MONTH:
                selectDayButton(monthButton)
            case .YEAR:
                selectDayButton(yearButton)
            }
            
            fsCalendar.isHidden = true
            barChartView.isHidden = false
        }
    }
    
    // MARK: - UI
    private func updateDisplayText() {
        let displayDate: String

        switch currentButtonFlag {
        case .DAY:
            displayDate = targetDate

        case .WEEK:
            if let monday = findMonday(targetDate),
               let sunday = DateTimeManager.shared.adjustDate(monday, offset: 6, component: .day)
            {
                displayDate = "\(monday)~\(sunday.suffix(5))"
            } else {
                displayDate = targetDate
            }

        case .MONTH:
            // 예: "2025-04-02" → "2025-04"
            displayDate = String(targetDate.prefix(7))

        case .YEAR:
            // 예: "2025-04-02" → "2025"
            displayDate = String(targetDate.prefix(4))
        }

        todayDisplay.text = displayDate
    }
    
    func toastMessage(_ message: String) {
        // chartView의 중앙 좌표 계산
        let chartViewCenterX = barChartView.frame.size.width / 2
        let chartViewCenterY = barChartView.frame.size.height / 2

        // 토스트 컨테이너의 크기
        let containerWidth: CGFloat = barChartView.frame.width - 60
        let containerHeight: CGFloat = 35

        // 토스트 컨테이너가 chartView 중앙에 오도록 위치 조정
        let toastPositionX = chartViewCenterX - containerWidth / 2
        let toastPositionY = chartViewCenterY - containerHeight / 2
        
        ToastHelper.shared.showChartToast(self.view, message, position: CGPoint(x: toastPositionX, y: toastPositionY))

    }
    
    func setButtonColor(_ sender: UIButton) {
        for button in buttonList {
            if button == sender {
                button.isSelected = true
            } else {
                button.isSelected = false
            }
        }
    }
    
    private func initUI() {
        barChartView.clear()
        
        singleContentsValueLabel.text = "0"
        
        topValue.text = "-"
        bottomValue.text = "-"
        
        topValueProcent.text = "-"
        bottomValueProcent.text = "-"
        
        topProgress.progress = 0
        bottomProgress.progress = 0
                
        dissmissCalendar()
    }
    
    private func setUI() {
        switch (chartType) {
        case .CALORIE, .STEP:
            // double graph
            doubleGraphBottomContents.isHidden = false
            singleGraphBottomContents.isHidden = true
            
            let type = chartType == .CALORIE
            topTitleLabel.text = (type ? "unit_tCal".localized() : "unit_step_cap".localized())
            bottomTitleLabel.text = (type ? "unit_eCal".localized() : "unit_travel_distance".localized())
            
            
            firstGoal = type ? UserProfileManager.shared.targetCalorie :
                               UserProfileManager.shared.targetStep
            secondGoal = type ? UserProfileManager.shared.targetActivityCalorie :
                                UserProfileManager.shared.targetDistance
                        
        default:
            // single graph
            singleGraphBottomContents.isHidden = false
            doubleGraphBottomContents.isHidden = true
        }
    }
    

    
    private func getDayCount(for buttonFlag: DateType) -> Int {
        switch buttonFlag {
        case .DAY: return 1
        case .WEEK: return 7
        case .MONTH: return 30
        case .YEAR: return 365
        }
    }
    
    func chartZoomOut() {
        for _ in 0..<20 {
            barChartView.zoomOut()
        }
    }
    
    private func dissmissCalendar() {
        if (!fsCalendar.isHidden) {
            fsCalendar.isHidden = true
            barChartView.isHidden = false
        }
    }

    
    // MARK: - addViews
    private func addViews() {
        let totalMultiplier = 4.0 // 1.0, 1.0, 2.0
        let singlePortion = 1.0 / totalMultiplier
        
        let screenWidth = UIScreen.main.bounds.width // Screen width
        let oneFourthWidth = screenWidth / 4.0
        
        view.addSubview(safeAreaView)
        safeAreaView.snp.makeConstraints { make in
            make.top.bottom.left.right.equalToSuperview()
        }
        
        view.addSubview(barChartView)
        barChartView.snp.makeConstraints { make in
            make.top.left.right.equalTo(safeAreaView)
            make.height.equalTo(safeAreaView).multipliedBy(5.5 / (5.5 + 4.5))
        }
        
        view.addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints { make in
            make.centerX.centerY.equalTo(barChartView)
        }
        
        view.addSubview(bottomContents)
        bottomContents.snp.makeConstraints { make in
            make.top.equalTo(barChartView.snp.bottom)
            make.left.right.bottom.equalTo(safeAreaView)
        }
        
        bottomContents.addSubview(topContents)
        topContents.snp.makeConstraints { make in
            make.top.equalTo(bottomContents).offset(10)
            make.left.equalTo(bottomContents).offset(10)
            make.right.equalTo(bottomContents).offset(-10)
            make.height.equalTo(bottomContents).multipliedBy(singlePortion)
        }
        
        bottomContents.addSubview(middleContents)
        middleContents.snp.makeConstraints { make in
            make.top.equalTo(topContents.snp.bottom)
            make.left.equalTo(bottomContents).offset(10)
            make.right.equalTo(bottomContents).offset(-10)
            make.height.equalTo(bottomContents).multipliedBy(singlePortion)
        }
        
        // ARR Contents StackView
        bottomContents.addSubview(singleGraphBottomContents)
        singleGraphBottomContents.snp.makeConstraints { make in
            make.top.equalTo(middleContents.snp.bottom)
            make.left.right.bottom.equalTo(bottomContents)
        }
        
        // CAL, STEP Contents StackView
        bottomContents.addSubview(doubleGraphBottomContents)
        doubleGraphBottomContents.snp.makeConstraints { make in
            make.top.equalTo(middleContents.snp.bottom)
            make.left.equalTo(bottomContents).offset(20)
            make.right.equalTo(safeAreaView.snp.centerX).offset(40)
            make.bottom.equalTo(bottomContents).offset(-5)
        }
        
        // --------------------- topContents --------------------- //
        
        topContents.addSubview(weekButton)
        weekButton.snp.makeConstraints { make in
            make.top.equalTo(topContents)
            make.right.equalTo(topContents.snp.centerX).offset(-10)
            make.bottom.equalTo(topContents).offset(-20)
            make.width.equalTo(oneFourthWidth - 20)
        }
        
        topContents.addSubview(monthButton)
        monthButton.snp.makeConstraints { make in
            make.top.bottom.width.equalTo(weekButton)
            make.left.equalTo(topContents.snp.centerX).offset(10)
        }
        
        topContents.addSubview(dayButton)
        dayButton.snp.makeConstraints { make in
            make.top.bottom.width.equalTo(weekButton)
            make.left.equalTo(safeAreaView).offset(10)
        }
                
        topContents.addSubview(yearButton)
        yearButton.snp.makeConstraints { make in
            make.top.bottom.width.equalTo(weekButton)
            make.right.equalTo(safeAreaView).offset(-10)
        }
        
        // --------------------- middleContents --------------------- //
        middleContents.addSubview(todayDisplay)
        todayDisplay.snp.makeConstraints { make in
            make.top.bottom.equalTo(middleContents)
            make.centerX.equalTo(middleContents).offset(5)
        }
        
        middleContents.addSubview(yesterdayButton)
        yesterdayButton.snp.makeConstraints { make in
            make.top.left.bottom.equalTo(middleContents)
        }
        
        middleContents.addSubview(tomorrowButton)
        tomorrowButton.snp.makeConstraints { make in
            make.top.right.bottom.equalTo(middleContents)
        }
     
        middleContents.addSubview(calendarButton)
        calendarButton.snp.makeConstraints { make in
            make.centerY.equalTo(todayDisplay)
            make.left.equalTo(todayDisplay.snp.left).offset(-30)
        }
        
        // --------------------- Cal, Step bottomContents --------------------- //
        doubleGraphBottomContents.addSubview(bottomValueContents)
        bottomValueContents.snp.makeConstraints { make in
            make.top.equalTo(doubleGraphBottomContents)
            make.left.equalTo(doubleGraphBottomContents.snp.right)
            make.bottom.right.equalTo(safeAreaView)
        }
        
        doubleGraphBottomContents.addSubview(topValue)
        topValue.snp.makeConstraints { make in
            make.centerX.equalTo(bottomValueContents)
            make.centerY.equalTo(topProgress)
        }
        
        doubleGraphBottomContents.addSubview(bottomValue)
        bottomValue.snp.makeConstraints { make in
            make.centerX.equalTo(bottomValueContents)
            make.centerY.equalTo(bottomProgress)
        }
        
        doubleGraphBottomContents.addSubview(bottomLine)
        bottomLine.snp.makeConstraints { make in
            make.centerY.equalTo(bottomValueContents)
            make.left.equalTo(safeAreaView).offset(10)
            make.right.equalTo(safeAreaView).offset(-10)
            make.height.equalTo(1)
        }
        
        doubleGraphBottomContents.addSubview(topValueProcent)
        topValueProcent.snp.makeConstraints { make in
            make.centerX.centerY.equalTo(topProgress)
        }
        
        doubleGraphBottomContents.addSubview(bottomValueProcent)
        bottomValueProcent.snp.makeConstraints { make in
            make.centerX.centerY.equalTo(bottomProgress)
        }
        
        view.addSubview(fsCalendar)
        fsCalendar.snp.makeConstraints { make in
            make.centerY.centerX.equalTo(barChartView)
            make.height.equalTo(300)
            make.width.equalTo(300)
        }
    }
}
