import Foundation
import UIKit
import DGCharts
import Combine
import SnapKit

@available(iOS 13.0, *)
class LineChartVC : UIViewController {
    // injection
    private let viewModel = DependencyInjection.shared.resolve(LineChartViewModel.self)
    private let lineChartController = DependencyInjection.shared.resolve(LineChartController.self)
    
    // Combine
    private var cancellables = Set<AnyCancellable>()
    
    /* Loading Bar */
    private var loadingIndicator = LoadingIndicator()
    
    /* Stack View*/
    private let stackView = UIStackView()
    private var topHeightConstraint: Constraint?
    private var middleHeightConstraint: Constraint?
    private var bottomHeightConstraint: Constraint?
    
    
    // ----------------------------- Image ------------------- //
    private let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 20, weight: .light)
    private lazy var calendarImage =  UIImage( systemName: "calendar", withConfiguration: symbolConfiguration)?.withTintColor(.darkGray, renderingMode: .alwaysOriginal)
    // Image End

    private let YESTERDAY_BUTTON_FLAG = 1
    private let TOMORROW_BUTTON_FLAG = 2
    
    private let TODAY_FLAG = 1
    private let TWO_DAYS_FLAG = 2
    private let THREE_DAYS_FLAG = 3
    
    
    // ----------------------------- CHART ------------------- //
    // 차트 관련 변수
    private var buttonList:[UIButton] = []
    // CHART END
    
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
    
    private lazy var lineChartView = LineChartView()
    
    //    ----------------------------- UILabel -------------------    //
    private let topContents = UILabel().then { $0.isUserInteractionEnabled = true }
    
    private let middleContents = UILabel().then { $0.isUserInteractionEnabled = true }
    
    private let bottomContents = UILabel().then { $0.isUserInteractionEnabled = true }
    
    private let bpmHrvContents = UILabel().then { $0.isUserInteractionEnabled = true }
    private let stressContents = UILabel().then { $0.isUserInteractionEnabled = true }
    
    // MARK: - Top
    private lazy var todayButton = UIButton().then {
        $0.setTitle ("unit_today".localized(), for: .normal )
        
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
        
        $0.tag = TODAY_FLAG
        $0.addTarget(self, action: #selector(selectDayButton(_:)), for: .touchUpInside)
    }
    
    private lazy var twoDaysButton = UIButton().then {
        $0.setTitle ("unit_twoDays".localized(), for: .normal )
        
        $0.setTitleColor(.lightGray, for: .normal)
        $0.setTitleColor(.white, for: .selected)
        $0.setTitleColor(.lightGray, for: .disabled)
        
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        $0.setBackgroundColor(UIColor.MY_LIGHT_GRAY_BORDER, for: .normal)
        $0.setBackgroundColor(UIColor.MY_LIGHT_GRAY_BORDER, for: .disabled)
        $0.setBackgroundColor(UIColor.MY_BODY_STATE, for: .selected)
        
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 15
        
        $0.tag = TWO_DAYS_FLAG
        $0.addTarget(self, action: #selector(selectDayButton(_:)), for: .touchUpInside)
    }
    
    private lazy var threeDaysButton = UIButton().then {
        $0.setTitle ("unit_threeDays".localized(), for: .normal )
        
        $0.setTitleColor(.lightGray, for: .normal)
        $0.setTitleColor(.white, for: .selected)
        $0.setTitleColor(.lightGray, for: .disabled)
        
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        $0.setBackgroundColor(UIColor.MY_LIGHT_GRAY_BORDER, for: .normal)
        $0.setBackgroundColor(UIColor.MY_LIGHT_GRAY_BORDER, for: .disabled)
        $0.setBackgroundColor(UIColor.MY_BODY_STATE, for: .selected)
        
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 15
        
        $0.tag = THREE_DAYS_FLAG
        $0.addTarget(self, action: #selector(selectDayButton(_:)), for: .touchUpInside)
    }
    
    
    // MARK: - Middle
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
    
    
    // MARK: - Bottom
    private let maxLabel = UILabel().then {
        $0.text = "unit_max".localized()
        $0.textColor = .lightGray
        $0.font = UIFont.systemFont(ofSize: 18, weight: .medium)
    }
    
    private let maxValue = UILabel().then {
        $0.text = "0"
        $0.textColor = .lightGray
        $0.font = UIFont.systemFont(ofSize: 16, weight: .medium)
    }
    
    private let maxStandardDeviationValue = UILabel().then {
        $0.text = "0"
        $0.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        $0.textColor = UIColor(red: 239/255, green: 80/255, blue: 123/255, alpha: 1.0)
    }
    
    private let minLabel = UILabel().then {
        $0.text = "unit_min".localized()
        $0.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        $0.textColor = .lightGray
    }
    
    private let minValue = UILabel().then {
        $0.text = "0"
        $0.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        $0.textColor = .lightGray
    }
    
    private let minStandardDeviationValue = UILabel().then {
        $0.text = "0"
        $0.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        $0.textColor = UIColor(red: 83/255, green: 136/255, blue: 247/255, alpha: 1.0)
    }
    
    private let avgLabel = UILabel().then {
        $0.text = "unit_bpm_avg".localized()
        $0.font = UIFont.systemFont(ofSize: 20, weight: .bold)
    }
    
    private let avgValue = UILabel().then {
        $0.text = "0"
        $0.font = UIFont.systemFont(ofSize: 20, weight: .bold)
    }
    
    private let valueLabel = UILabel().then {
        $0.text = "unit_standard_deviation".localized()
        $0.font = UIFont.systemFont(ofSize: 20, weight: .bold)
    }
    
    
    
    
    private let stressSnsLabel = UILabel().then {
        $0.text = "SNS"
        $0.textColor = .MY_RED
        $0.font = UIFont.systemFont(ofSize: 20, weight: .bold)
    }
    
    private let stressPnsLabel = UILabel().then {
        $0.text = "PNS"
        $0.textColor = .MY_BLUE
        $0.font = UIFont.systemFont(ofSize: 20, weight: .bold)
    }
    
    
    private let stressMaxLabel = UILabel().then {
        $0.text = "unit_max".localized()
        $0.textColor = .MY_RED
        $0.font = UIFont.systemFont(ofSize: 18, weight: .bold)
    }
    
    private let stressAvgLabel = UILabel().then {
        $0.text = "unit_avg_cap".localized()
        $0.textColor = .black
        $0.font = UIFont.systemFont(ofSize: 20, weight: .bold)
    }
    
    private let stressMinLabel = UILabel().then {
        $0.text = "unit_min".localized()
        $0.textColor = .MY_BLUE
        $0.font = UIFont.systemFont(ofSize: 18, weight: .bold)
    }
    
    
    private let snsMaxValue = UILabel().then {
        $0.textColor = .MY_LIGHT_RED
        $0.font = UIFont.systemFont(ofSize: 16, weight: .medium)
    }
    
    private let snsAvgValue = UILabel().then {
        $0.textColor = .black
        $0.font = UIFont.systemFont(ofSize: 18, weight: .bold)
    }
    
    private let snsMinValue = UILabel().then {
        $0.textColor = .MY_LIGHT_BLUE
        $0.font = UIFont.systemFont(ofSize: 16, weight: .medium)
    }
    
    
    private let pnsMaxValue = UILabel().then {
        $0.textColor = .MY_LIGHT_RED
        $0.font = UIFont.systemFont(ofSize: 16, weight: .medium)
    }
    
    private let pnsAvgValue = UILabel().then {
        $0.textColor = .black
        $0.font = UIFont.systemFont(ofSize: 18, weight: .bold)
    }
    
    private let pnsMinValue = UILabel().then {
        $0.textColor = .MY_LIGHT_BLUE
        $0.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        
    }
    
    // MARK: - Button Evnet
    @objc func selectDayButton(_ sender: UIButton) {
        switch(sender.tag) {
        case TWO_DAYS_FLAG:
            viewModel?.updateDateType(.TWO_DAYS)
        case THREE_DAYS_FLAG:
            viewModel?.updateDateType(.THREE_DAYS)
        default:
            viewModel?.updateDateType(.TODAY)
        }
        
        setButtonColor(sender)
    }
    
    @objc func shiftDate(_ sender: UIButton) {
        let shiftFlag = sender.tag == TOMORROW_BUTTON_FLAG
        viewModel?.moveDate(nextDate: shiftFlag)
    }
    
    @objc func calendarButtonEvent(_ sender: UIButton) {
        fsCalendar.isHidden = !fsCalendar.isHidden
        lineChartView.isHidden = !lineChartView.isHidden
    }
    
    
    // MARK: - VDL
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initVar()
        
        addViews()
        
        setupBindings()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        dissmissCalendar()
    }
    
    public func refreshView(lineChart: LineChartType) {
        // update UI
        fsCalendar.isHidden = true
        lineChartView.isHidden = false
        
        updateChartUI(lineChart)
        
        setButtonColor(todayButton)
        
        // update Chart Data
        viewModel?.refresh(type: lineChart)
        

        switch lineChart {
        case .BPM, .HRV, .SPO2, .BREATHE:
            bpmHrvContents.isHidden = false
            stressContents.isHidden = true
        case .STRESS:
            bpmHrvContents.isHidden = true
            stressContents.isHidden = false
        }
    }
    
    private func initVar() {
        setCalendarEvent()
        
        lineChartController?.setLineChart(lineChart: lineChartView)
        
        buttonList = [todayButton, twoDaysButton, threeDaysButton]
    }
    
    private func setCalendarEvent() {
        fsCalendar.didSelectDate = { [self] date in
            fsCalendar.isHidden = true
            lineChartView.isHidden = false
            
            viewModel?.moveDate(moveDate: date)
        }
    }
    
    private func setupBindings() {
        // init
        viewModel?.$initValue
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.initUI()
            }
            .store(in: &cancellables)
        
        // chart data
        viewModel?.$chartModel
            .receive(on: DispatchQueue.main)
            .sink { [weak self] chartModel in
                self?.updateValueUI(chartModel)
                self?.showChart(chartModel)
            }
            .store(in: &cancellables)
        
        
        // display date
        viewModel?.$displayDate
            .receive(on: DispatchQueue.main)
            .sink { [weak self] displyDate in
                self?.todayDisplay.text = displyDate
            }
            .store(in: &cancellables)
        
        
        // network response
        viewModel?.$networkResponse
            .receive(on: DispatchQueue.main)
            .sink { [weak self] response in
                self?.showErrorMessage(response)
            }
            .store(in: &cancellables)
        
        
        // loading
        viewModel?.$loading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] show in
                guard let view = self?.view else { return }
                
                if show {
                    self?.loadingIndicator.show(in: view)
                } else {
                    self?.loadingIndicator.hide()
                }
            }
            .store(in: &cancellables)
    }

    
    private func showChart(_ lineChartModel: LineChartModel?) {
        guard let lineChartModel else { return }
                
        if let showChart = lineChartController?.showChart(
            lineChart: lineChartView,
            lineChartModel: lineChartModel
        ) {
            if !showChart {
                showErrorMessage(.noData)
            }
        }
    }
    
    
    private func showErrorMessage(_ response: NetworkResponse?) {
        guard let response else { return }
        
        switch response {
        case .failer, .invalidResponse:
            showToastMessage("dialog_error_server_noData".localized())
        case .notConnected, .session:
            showToastMessage("dialog_error_internet".localized())
        case .noData:
            showToastMessage("dialog_error_noData".localized())
        default:
            print("other response: \(response)")
        }
    }
    
    
    
    
    // MARK: - UI
    private func updateChartUI(_ chartType: LineChartType) {
        toggleTopView(isHidden: chartType != .STRESS)
        
        switch chartType {
        case .BPM:
            avgLabel.text = "unit_bpm_avg".localized()
            valueLabel.text = "unit_bpm_upper".localized()
        case .HRV:
            avgLabel.text = "unit_hrv_avg".localized()
            valueLabel.text = "unit_hrv".localized()
        case .SPO2:
            avgLabel.text = "SPO2"
        case .BREATHE:
            avgLabel.text = "호흡"
        case .STRESS:
            break
        }
    }
    
    private func updateValueUI(_ lineChartModel: LineChartModel?) {
        guard let lineChartModel else { return }
        
        switch lineChartModel.chartType {
        case .BPM, .HRV:
            valueLabel.text = "unit_standard_deviation".localized()
            
            let max = lineChartModel.stats?.maxValue ?? 0.0
            let min = lineChartModel.stats?.minValue ?? 0.0
            let avg = lineChartModel.stats?.average ?? 0.0
            
            let maxStandardDeviation = avg + (lineChartModel.standardDeviationValue ?? 0.0)
            let minStandardDeviation = avg - (lineChartModel.standardDeviationValue ?? 0.0)
            
            let difMax = String(format: "%.0f", max - avg)
            let difMin = String(format: "%.0f", avg - min)
            
            let strigMax = String(format: "%.0f", max)
            let strigMin = String(format: "%.0f", min)
            
            maxValue.text = "\(strigMax)(+\(difMax))"
            minValue.text = "\(strigMin)(-\(difMin))"
            avgValue.text = String(format: "%.0f", avg)

            maxStandardDeviationValue.text = String(format: "%.0f", maxStandardDeviation)
            minStandardDeviationValue.text = String(format: "%.0f", minStandardDeviation)
            
        case .STRESS:
            let pns = lineChartModel.stressStats?.pns
            let sns = lineChartModel.stressStats?.sns
            
            pnsMaxValue.text = String(format: "%.1f", pns?.maxValue ?? 0)
            pnsMinValue.text = String(format: "%.1f", pns?.minValue ?? 0)
            pnsAvgValue.text = String(format: "%.1f", pns?.average ?? 0)
            
            snsMaxValue.text = String(format: "%.1f", sns?.maxValue ?? 0)
            snsMinValue.text = String(format: "%.1f", sns?.minValue ?? 0)
            snsAvgValue.text = String(format: "%.1f", sns?.average ?? 0)
        case .SPO2, .BREATHE:
            valueLabel.text = "unit_avg_cap".localized()
            
            let format = lineChartModel.chartType == .SPO2 ? "%.1f" : "%.0f"
            
            let max = lineChartModel.stats?.maxValue ?? 0.0
            let min = lineChartModel.stats?.minValue ?? 0.0
            let avg = lineChartModel.stats?.average ?? 0.0
            
            let difMax = String(format: format, max - avg)
            let difMin = String(format: format, avg - min)
            
            maxValue.text = String(format: format, max)
            minValue.text = String(format: format, min)
            avgValue.text = String(format: format, avg)
            
            maxStandardDeviationValue.text = "+\(difMax)"
            minStandardDeviationValue.text = "-\(difMin)"
        }
    }
    
    private func initUI() {
        lineChartView.clear()
        
        maxValue.text = "0"
        minValue.text = "0"
        avgValue.text = "0"
        
        minStandardDeviationValue.text = "-0"
        maxStandardDeviationValue.text = "+0"
        
        pnsMaxValue.text = "0"
        pnsMinValue.text = "0"
        pnsAvgValue.text = "0"
        
        snsMaxValue.text = "0"
        snsMinValue.text = "0"
        snsAvgValue.text = "0"
    }
    
    
    private func setButtonColor(_ sender: UIButton) {
        for button in buttonList {
            if button == sender {
                button.isSelected = true
            } else {
                button.isSelected = false
            }
        }
    }

    
    private func showToastMessage(_ message: String) {
        // chart location
        let chartViewCenterX = lineChartView.frame.size.width / 2
        let chartViewCenterY = lineChartView.frame.size.height / 2

        // size
        let containerWidth: CGFloat = lineChartView.frame.width - 60
        let containerHeight: CGFloat = 35

        // toast message location
        let toastPositionX = chartViewCenterX - containerWidth / 2
        let toastPositionY = chartViewCenterY - containerHeight / 2
        
        ToastHelper.shared.showChartToast(self.view, message, position: CGPoint(x: toastPositionX, y: toastPositionY))
    }
    
    
    private func dissmissCalendar() {
        if (!fsCalendar.isHidden) {
            fsCalendar.isHidden = true
            lineChartView.isHidden = false
        }
    }
    
    
    
    
    // MARK: -
    private func toggleTopView(isHidden: Bool) {
        if isHidden {
            middleHeightConstraint?.deactivate()
            bottomHeightConstraint?.deactivate()
            
            topContents.snp.remakeConstraints { make in
                topHeightConstraint = make.height.equalTo(stackView.snp.height).multipliedBy(0.15).constraint
            }
            
            middleContents.snp.remakeConstraints { make in
                middleHeightConstraint = make.height.equalTo(stackView.snp.height).multipliedBy(0.2).constraint
            }
            
            bottomContents.snp.remakeConstraints { make in
                bottomHeightConstraint = make.height.equalTo(stackView.snp.height).multipliedBy(0.65).constraint
            }
        } else {
            hideTopView()
        }
        
        self.view.layoutIfNeeded()
    }
    
    
    private func hideTopView() {
        topHeightConstraint?.deactivate()
        middleHeightConstraint?.deactivate()
        bottomHeightConstraint?.deactivate()
        
        topContents.snp.remakeConstraints { make in
            topHeightConstraint = make.height.equalTo(stackView.snp.height).multipliedBy(0.0).constraint
        }
        
        middleContents.snp.remakeConstraints { make in
            middleHeightConstraint = make.height.equalTo(stackView.snp.height).multipliedBy(0.2).constraint
        }
        
        bottomContents.snp.remakeConstraints { make in
            bottomHeightConstraint = make.height.equalTo(stackView.snp.height).multipliedBy(0.8).constraint
        }
    }
    
    
    
    
    // MARK: -
    private func addViews() {
        addChartViews()
        
        addStackView()
        
        addDateViews()
        
        addCalendarViews()
        
        addBpmHrvViews()
        
        addStressViews()
    }
    
    
    private func addChartViews() {
        view.addSubview(safeAreaView)
        view.addSubview(lineChartView)
        view.addSubview(activityIndicator)
        view.addSubview(fsCalendar)
        
        safeAreaView.snp.makeConstraints { make in
            make.top.bottom.left.right.equalToSuperview()
        }
        
        // chart
        lineChartView.snp.makeConstraints { make in
            make.top.left.right.equalTo(safeAreaView)
            make.height.equalTo(safeAreaView).multipliedBy(5.5 / (5.5 + 4.5))
        }
        
        // indicator
        activityIndicator.snp.makeConstraints { make in
            make.centerX.centerY.equalTo(lineChartView)
        }
        
        // calendar
        fsCalendar.snp.makeConstraints { make in
            make.centerY.centerX.equalTo(lineChartView)
            make.height.equalTo(300)
            make.width.equalTo(300)
        }
    }
    
    
    private func addStackView() {
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        
        view.addSubview(stackView)
        stackView.addArrangedSubview(topContents)
        stackView.addArrangedSubview(middleContents)
        stackView.addArrangedSubview(bottomContents)
        
        stackView.snp.makeConstraints { make in
            make.top.equalTo(lineChartView.snp.bottom).offset(10)
            make.left.right.bottom.equalTo(safeAreaView)
        }
        
        topContents.snp.makeConstraints { make in
            topHeightConstraint = make.height.equalTo(stackView.snp.height).multipliedBy(0.15).constraint
        }
        
        middleContents.snp.makeConstraints { make in
            middleHeightConstraint = make.height.equalTo(stackView.snp.height).multipliedBy(0.2).constraint
        }
        
        bottomContents.snp.makeConstraints { make in
            bottomHeightConstraint = make.height.equalTo(stackView.snp.height).multipliedBy(0.65).constraint
        }
    }
    
    
    private func addDateViews() {
        let oneThirdWidth = UIScreen.main.bounds.width / 3.0
        
        topContents.addSubview(todayButton)
        topContents.addSubview(twoDaysButton)
        topContents.addSubview(threeDaysButton)
        
        todayButton.snp.makeConstraints { make in
            make.top.equalTo(topContents)
            make.bottom.equalTo(topContents)
            make.left.equalTo(topContents).offset(10)
            make.width.equalTo(oneThirdWidth - 20)
        }
        
        threeDaysButton.snp.makeConstraints { make in
            make.top.equalTo(topContents)
            make.bottom.equalTo(topContents)
            make.right.equalTo(topContents).offset(-10)
            make.width.equalTo(oneThirdWidth - 20)
        }
        
        twoDaysButton.snp.makeConstraints { make in
            make.top.equalTo(topContents)
            make.bottom.equalTo(topContents)
            make.centerX.equalTo(topContents)
            make.width.equalTo(oneThirdWidth - 20)
        }
    }
    
    private func addCalendarViews() {
        middleContents.addSubview(todayDisplay)
        middleContents.addSubview(yesterdayButton)
        middleContents.addSubview(tomorrowButton)
        middleContents.addSubview(calendarButton)
        
        todayDisplay.snp.makeConstraints { make in
            make.top.equalTo(middleContents).offset(10)
            make.bottom.equalTo(middleContents)
            make.centerX.equalTo(middleContents).offset(5)
        }

        yesterdayButton.snp.makeConstraints { make in
            make.top.equalTo(middleContents).offset(10)
            make.bottom.equalTo(middleContents)
            make.left.equalTo(middleContents).offset(10)
        }

        tomorrowButton.snp.makeConstraints { make in
            make.top.equalTo(middleContents).offset(10)
            make.bottom.equalTo(middleContents)
            make.right.equalTo(middleContents).offset(-10)
        }

        calendarButton.snp.makeConstraints { make in
            make.centerY.equalTo(todayDisplay)
            make.left.equalTo(todayDisplay.snp.left).offset(-30)
        }
    }
    
    
    private func addBpmHrvViews() {
        let oneThirdWidth = UIScreen.main.bounds.width / 3.0
        
        let minStackView = UIStackView(arrangedSubviews: [minLabel, minValue, minStandardDeviationValue]).then {
            setStackView($0)
        }
        let maxStackView = UIStackView(arrangedSubviews: [maxLabel, maxValue, maxStandardDeviationValue]).then {
            setStackView($0)
        }
        let avgStackView = UIStackView(arrangedSubviews: [avgLabel, avgValue, valueLabel]).then {
            setStackView($0)
        }
        
        bottomContents.addSubview(bpmHrvContents)
        bpmHrvContents.addSubview(minStackView)
        bpmHrvContents.addSubview(maxStackView)
        bpmHrvContents.addSubview(avgStackView)
        
        
        bpmHrvContents.snp.makeConstraints { make in
            make.top.bottom.left.right.equalTo(bottomContents)
        }
        
        avgStackView.snp.makeConstraints { make in
            make.top.bottom.centerX.equalTo(bottomContents)
            make.width.equalTo(oneThirdWidth)
        }
        
        minStackView.snp.makeConstraints { make in
            make.top.bottom.left.equalTo(bottomContents)
            make.width.equalTo(oneThirdWidth)
        }
        
        maxStackView.snp.makeConstraints { make in
            make.top.bottom.right.equalTo(bottomContents)
            make.width.equalTo(oneThirdWidth)
        }
    }
    
    private func addStressViews() {
        let oneThirdWidth = UIScreen.main.bounds.width / 3.0
        
        let snsStackView = UIStackView(arrangedSubviews: [stressSnsLabel, snsMaxValue, snsAvgValue, snsMinValue]).then {
            setStackView($0)
        }
        let labelStackView = UIStackView(arrangedSubviews: [UIView(), stressMaxLabel, stressAvgLabel, stressMinLabel]).then {
            setStackView($0)
        }
        let pnsStackView = UIStackView(arrangedSubviews: [stressPnsLabel, pnsMaxValue, pnsAvgValue, pnsMinValue]).then {
            setStackView($0)
        }
        
        bottomContents.addSubview(stressContents)
        stressContents.addSubview(snsStackView)
        stressContents.addSubview(labelStackView)
        stressContents.addSubview(pnsStackView)
        
        stressContents.snp.makeConstraints { make in
            make.top.bottom.left.right.equalTo(bottomContents)
        }
        
        labelStackView.snp.makeConstraints { make in
            make.top.bottom.centerX.equalTo(bottomContents)
            make.width.equalTo(oneThirdWidth)
        }
        
        snsStackView.snp.makeConstraints { make in
            make.top.bottom.left.equalTo(bottomContents)
            make.width.equalTo(oneThirdWidth)
        }
        
        pnsStackView.snp.makeConstraints { make in
            make.top.bottom.right.equalTo(bottomContents)
            make.width.equalTo(oneThirdWidth)
        }
    }
    
    func setStackView(_ stackView: UIStackView) {
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.alignment = .center
    }
}
