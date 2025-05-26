import Foundation
import UIKit
import Then
import SnapKit

@available(iOS 13.0, *)
public class SummaryViewController : UIViewController {
    
    private let BPM_BUTTON_TAG = 1
    private let ARR_BUTTON_TAG = 2
    private let HRV_BUTTON_TAG = 3
    private let CAL_BUTTON_TAG = 4
    private let STEP_BUTTON_TAG = 5
    private let STRESS_BUTTON_TAG = 6
    private let SPO2_BUTTON_TAG = 7
    private let BREATH_BUTTON_TAG = 8
    
    
    
    private let lineChartView = LineChartVC()
    private let barChartView = BarChartVC()
    
    private var arrChild: [UIViewController] = []
    
    private lazy var childs: [UIViewController] = {
        return [lineChartView, barChartView]
    }()
    
    private lazy var buttons: [UIButton] = {
        return [bpmButton, arrButton, hrvButton, calorieButton, stepButton, stressButton, spo2Button, breathButton]
    }()
    
    private lazy var images: [UIImageView] = {
        return [bpmImage, arrImage, hrvImage, calorieImage, stepImage, stressImage, spo2Image, breatheImage]
    }()
    
    
    
    // MARK: -
    private let safeAreaView = UIView()

    // ------------------------ Top Button ------------------------
    private lazy var bpmImage = UIImageView().then {
        let image = UIImage(named: "summary_bpm")?.withRenderingMode(.alwaysTemplate)
        $0.image = image
        $0.tintColor = UIColor.white
    }
    
    private lazy var hrvImage = UIImageView().then {
        let image = UIImage(named: "summary_hrv")?.withRenderingMode(.alwaysTemplate)
        $0.image = image
        $0.tintColor = UIColor.lightGray
    }
    
    private lazy var arrImage = UIImageView().then {
        let image = UIImage(named: "summary_arr")?.withRenderingMode(.alwaysTemplate)
        $0.image = image
        $0.tintColor = UIColor.lightGray
    }
    
    private lazy var stressImage = UIImageView().then {
        let image = UIImage(named: "ic_relax")?.withRenderingMode(.alwaysTemplate)
        $0.image = image
        $0.tintColor = UIColor.lightGray
    }
    
    private lazy var calorieImage = UIImageView().then {
        let image = UIImage(named: "summary_cal")?.withRenderingMode(.alwaysTemplate)
        $0.image = image
        $0.tintColor = UIColor.lightGray
    }
    
    private lazy var stepImage = UIImageView().then {
        let image = UIImage(named: "summary_step")?.withRenderingMode(.alwaysTemplate)
        $0.image = image
        $0.tintColor = UIColor.lightGray
    }
    
    private lazy var spo2Image = UIImageView().then {
        let image = UIImage(named: "ic_spo2")?.withRenderingMode(.alwaysTemplate)
        $0.image = image
        $0.tintColor = UIColor.lightGray
    }
    
    private lazy var breatheImage = UIImageView().then {
        let image = UIImage(named: "ic_breath_fill")?.withRenderingMode(.alwaysTemplate)
        $0.image = image
        $0.tintColor = UIColor.lightGray
    }
    
    
    
    // ------------------------ BUTTON ------------------------
    private lazy var bpmButton = UIButton().then {
        $0.setTitle("unit_bpm_cap".localized(), for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .heavy)
        $0.titleLabel?.contentMode = .center
        $0.backgroundColor = UIColor(red: 45/255, green: 63/255, blue: 100/255, alpha: 1.0)
        $0.layer.borderColor = UIColor(red: 234/255, green: 235/255, blue: 237/255, alpha: 1.0).cgColor
        $0.layer.borderWidth = 0
        $0.layer.cornerRadius = 15
        $0.titleEdgeInsets = UIEdgeInsets(top: 25, left: 0, bottom: 0, right: 0)
        $0.isEnabled = true
        $0.isUserInteractionEnabled = true
        $0.tag = BPM_BUTTON_TAG
        $0.addTarget(self, action: #selector(ButtonEvent(_:)), for: .touchUpInside)
    }
    
    private lazy var hrvButton = UIButton().then {
        $0.setTitle("unit_hrv_upper".localized(), for: .normal)
        $0.setTitleColor(.lightGray, for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .heavy)
        $0.titleLabel?.contentMode = .center
        $0.backgroundColor = .white
        $0.layer.borderColor = UIColor(red: 234/255, green: 235/255, blue: 237/255, alpha: 1.0).cgColor
        $0.layer.borderWidth = 3
        $0.layer.cornerRadius = 15
        $0.titleEdgeInsets = UIEdgeInsets(top: 25, left: 0, bottom: 0, right: 0)
        $0.isEnabled = true
        $0.isUserInteractionEnabled = true
        $0.tag = HRV_BUTTON_TAG
        $0.addTarget(self, action: #selector(ButtonEvent(_:)), for: .touchUpInside)
    }
    
    private lazy var arrButton = UIButton().then {
        $0.setTitle("unit_arr_abb".localized(), for: .normal)
        $0.setTitleColor(.lightGray, for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .heavy)
        $0.titleLabel?.contentMode = .center
        $0.backgroundColor = .white
        $0.layer.borderColor = UIColor(red: 234/255, green: 235/255, blue: 237/255, alpha: 1.0).cgColor
        $0.layer.borderWidth = 3
        $0.layer.cornerRadius = 15
        $0.titleEdgeInsets = UIEdgeInsets(top: 25, left: 0, bottom: 0, right: 0)
        $0.isEnabled = true
        $0.isUserInteractionEnabled = true
        $0.tag = ARR_BUTTON_TAG
        $0.addTarget(self, action: #selector(ButtonEvent(_:)), for: .touchUpInside)
    }

    private lazy var stressButton = UIButton().then {
        $0.setTitle("unit_stress".localized(), for: .normal)
        $0.setTitleColor(.lightGray, for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .heavy)
        $0.titleLabel?.contentMode = .center
        $0.backgroundColor = .white
        $0.layer.borderColor = UIColor(red: 234/255, green: 235/255, blue: 237/255, alpha: 1.0).cgColor
        $0.layer.borderWidth = 3
        $0.layer.cornerRadius = 15
        $0.titleEdgeInsets = UIEdgeInsets(top: 25, left: 0, bottom: 0, right: 0)
        $0.isEnabled = true
        $0.isUserInteractionEnabled = true
        $0.tag = STRESS_BUTTON_TAG
        $0.addTarget(self, action: #selector(ButtonEvent(_:)), for: .touchUpInside)
    }
    
    
    private lazy var calorieButton = UIButton().then {
        $0.setTitle("unit_tCal_cap".localized(), for: .normal)
        $0.setTitleColor(.lightGray, for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .heavy)
        $0.titleLabel?.contentMode = .center
        $0.backgroundColor = .white
        $0.layer.borderColor = UIColor(red: 234/255, green: 235/255, blue: 237/255, alpha: 1.0).cgColor
        $0.layer.borderWidth = 3
        $0.layer.cornerRadius = 15
        $0.titleEdgeInsets = UIEdgeInsets(top: 25, left: 0, bottom: 0, right: 0)
        $0.isEnabled = true
        $0.isUserInteractionEnabled = true
        $0.tag = CAL_BUTTON_TAG
        $0.addTarget(self, action: #selector(ButtonEvent(_:)), for: .touchUpInside)
    }
    
    
    private lazy var stepButton = UIButton().then {
        $0.setTitle("unit_step_cap".localized(), for: .normal)
        $0.setTitleColor(.lightGray, for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .heavy)
        $0.titleLabel?.contentMode = .center
        $0.backgroundColor = .white
        $0.layer.borderColor = UIColor(red: 234/255, green: 235/255, blue: 237/255, alpha: 1.0).cgColor
        $0.layer.borderWidth = 3
        $0.layer.cornerRadius = 15
        $0.titleEdgeInsets = UIEdgeInsets(top: 25, left: 0, bottom: 0, right: 0)
        $0.isEnabled = true
        $0.isUserInteractionEnabled = true
        $0.tag = STEP_BUTTON_TAG
        $0.addTarget(self, action: #selector(ButtonEvent(_:)), for: .touchUpInside)
    }
    
    private lazy var spo2Button = UIButton().then {
        $0.setTitle("SPO2", for: .normal)
        $0.setTitleColor(.lightGray, for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .heavy)
        $0.titleLabel?.contentMode = .center
        $0.backgroundColor = .white
        $0.layer.borderColor = UIColor(red: 234/255, green: 235/255, blue: 237/255, alpha: 1.0).cgColor
        $0.layer.borderWidth = 3
        $0.layer.cornerRadius = 15
        $0.titleEdgeInsets = UIEdgeInsets(top: 25, left: 0, bottom: 0, right: 0)
        $0.isEnabled = true
        $0.isUserInteractionEnabled = true
        $0.tag = SPO2_BUTTON_TAG
        $0.addTarget(self, action: #selector(ButtonEvent(_:)), for: .touchUpInside)
    }
    
    private lazy var breathButton = UIButton().then {
        $0.setTitle("호흡", for: .normal)
        $0.setTitleColor(.lightGray, for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .heavy)
        $0.titleLabel?.contentMode = .center
        $0.backgroundColor = .white
        $0.layer.borderColor = UIColor(red: 234/255, green: 235/255, blue: 237/255, alpha: 1.0).cgColor
        $0.layer.borderWidth = 3
        $0.layer.cornerRadius = 15
        $0.titleEdgeInsets = UIEdgeInsets(top: 25, left: 0, bottom: 0, right: 0)
        $0.isEnabled = true
        $0.isUserInteractionEnabled = true
        $0.tag = BREATH_BUTTON_TAG
        $0.addTarget(self, action: #selector(ButtonEvent(_:)), for: .touchUpInside)
    }
    
    @objc private func ButtonEvent(_ sender: UIButton) {
        
        setButtonColor(sender)
        
        switch(sender.tag) {
        case BPM_BUTTON_TAG:
            setChild(selectChild: lineChartView, in: self.view)
            lineChartView.refreshView(lineChart: .BPM)
        case ARR_BUTTON_TAG:
            setChild(selectChild: barChartView, in: self.view)
            barChartView.refreshView(.ARR)
        case HRV_BUTTON_TAG:
            setChild(selectChild: lineChartView, in: self.view)
            lineChartView.refreshView(lineChart: .HRV)
        case STRESS_BUTTON_TAG:
            setChild(selectChild: lineChartView, in: self.view)
            lineChartView.refreshView(lineChart: .STRESS)
        case CAL_BUTTON_TAG:
            setChild(selectChild: barChartView, in: self.view)
            barChartView.refreshView(.CALORIE)
        case STEP_BUTTON_TAG:
            setChild(selectChild: barChartView, in: self.view)
            barChartView.refreshView(.STEP)
        case SPO2_BUTTON_TAG:
            setChild(selectChild: lineChartView, in: self.view)
            lineChartView.refreshView(lineChart: .SPO2)
        case BREATH_BUTTON_TAG:
            setChild(selectChild: lineChartView, in: self.view)
            lineChartView.refreshView(lineChart: .BREATHE)
        default:
            break
        }
    }
    
    private func setChild(
        selectChild: UIViewController,
        in containerView: UIView
    ) {
        for child in childs {
            if child == selectChild {
                addChild(child, in: containerView)
            } else {
                removeChild(child)
            }
        }
    }
    
    // MARK: - viewDidLoad
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        addViews()
        
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setChild(selectChild: lineChartView, in: self.view)
        
        lineChartView.refreshView(lineChart: .BPM)
        
        setButtonColor(buttons[BPM_BUTTON_TAG - 1])
        
    }
    
    func setButtonColor(_ sender: UIButton) {
        for button in buttons {
            if button == sender {
                button.setTitleColor(.white, for: .normal)
                button.backgroundColor = UIColor(red: 45/255, green: 63/255, blue: 100/255, alpha: 1.0)
                button.layer.borderWidth = 0
                
                images[button.tag-1].tintColor = UIColor.white
            } else {
                button.setTitleColor(.lightGray, for: .normal)
                button.backgroundColor = .white
                button.layer.borderColor = UIColor(red: 234/255, green: 235/255, blue: 237/255, alpha: 1.0).cgColor
                button.layer.borderWidth = 3
                
                images[button.tag-1].tintColor = UIColor.lightGray
            }
        }
    }
    
    func addChild(_ child: UIViewController, in containerView: UIView) {

        addChild(child)
        containerView.addSubview(child.view)
        
        child.view.snp.makeConstraints { make in
            make.top.equalTo(calorieButton.snp.bottom)
            make.left.right.bottom.equalTo(safeAreaView)
        }
        
        child.didMove(toParent: self)
                
        if !arrChild.contains(where: { $0 === child }) {
            arrChild.append(child)
        }
        
    }

    // 자식 뷰 컨트롤러 제거
    func removeChild(_ child: UIViewController) {
        child.willMove(toParent: nil)
        child.view.removeFromSuperview()
        child.removeFromParent()
    }
    
    // MARK: - addViews
    func addViews() {
        let buttonWidth = (self.view.frame.size.width - 60) / 5
        let scrollView = UIScrollView()
        let contentView = UIView()
    
        scrollView.do {
            $0.showsHorizontalScrollIndicator = true
            $0.showsVerticalScrollIndicator = false
            $0.alwaysBounceHorizontal = true
            $0.alwaysBounceVertical = false
        }
        
        view.addSubview(safeAreaView)
        safeAreaView.snp.makeConstraints { make in
            make.top.bottom.equalTo(view.safeAreaLayoutGuide)
            make.left.right.equalToSuperview()
        }
        
        // scrollView
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.top.left.equalTo(safeAreaView).offset(10)
            make.right.equalTo(safeAreaView).offset(-10)
            make.height.equalTo(50)
        }
        
        // buttonView
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.top.bottom.equalTo(scrollView)
            make.left.right.equalTo(scrollView)
            make.height.equalTo(scrollView)
        }
        
        
        // bpm
        contentView.addSubview(bpmButton)
        bpmButton.snp.makeConstraints { make in
            make.top.left.equalTo(contentView)
            make.width.equalTo(buttonWidth)
            make.height.equalTo(contentView)
        }
        
        contentView.addSubview(bpmImage)
        bpmImage.snp.makeConstraints { make in
            make.top.equalTo(bpmButton).offset(5)
            make.centerX.equalTo(bpmButton)
        }
        
        
        // hrv
        contentView.addSubview(hrvButton)
        hrvButton.snp.makeConstraints { make in
            make.top.equalTo(bpmButton)
            make.left.equalTo(bpmButton.snp.right).offset(10)
            make.width.height.equalTo(bpmButton)
        }
  
        contentView.addSubview(hrvImage)
        hrvImage.snp.makeConstraints { make in
            make.top.equalTo(hrvButton).offset(5)
            make.centerX.equalTo(hrvButton)
        }
        
        
        // arr
        contentView.addSubview(arrButton)
        arrButton.snp.makeConstraints { make in
            make.top.equalTo(bpmButton)
            make.left.equalTo(hrvButton.snp.right).offset(10)
            make.width.height.equalTo(bpmButton)
        }
        
        contentView.addSubview(arrImage)
        arrImage.snp.makeConstraints { make in
            make.top.equalTo(arrButton).offset(5)
            make.centerX.equalTo(arrButton)
        }

        
        
        // stress
        contentView.addSubview(stressButton)
        stressButton.snp.makeConstraints { make in
            make.top.equalTo(bpmButton)
            make.left.equalTo(arrButton.snp.right).offset(10)
            make.width.height.equalTo(bpmButton)
        }
        
        contentView.addSubview(stressImage)
        stressImage.snp.makeConstraints { make in
            make.top.equalTo(stressButton).offset(5)
            make.centerX.equalTo(stressButton)
        }
        
        // spo2
        contentView.addSubview(spo2Button)
        spo2Button.snp.makeConstraints { make in
            make.top.equalTo(bpmButton)
            make.left.equalTo(stressButton.snp.right).offset(10)
            make.width.height.equalTo(bpmButton)
        }
  
        contentView.addSubview(spo2Image)
        spo2Image.snp.makeConstraints { make in
            make.top.equalTo(spo2Button).offset(5)
            make.centerX.equalTo(spo2Button)
        }
        
        
        // breath
        contentView.addSubview(breathButton)
        breathButton.snp.makeConstraints { make in
            make.top.equalTo(bpmButton)
            make.left.equalTo(spo2Button.snp.right).offset(10)
            make.width.height.equalTo(bpmButton)
        }
  
        contentView.addSubview(breatheImage)
        breatheImage.snp.makeConstraints { make in
            make.top.equalTo(breathButton).offset(5)
            make.centerX.equalTo(breathButton)
        }
        
        
        // cal
        contentView.addSubview(calorieButton)
        calorieButton.snp.makeConstraints { make in
            make.top.equalTo(bpmButton)
            make.left.equalTo(breathButton.snp.right).offset(10)
            make.width.height.equalTo(bpmButton)
        }
        
        contentView.addSubview(calorieImage)
        calorieImage.snp.makeConstraints { make in
            make.top.equalTo(calorieButton).offset(5)
            make.centerX.equalTo(calorieButton)
        }
        

        // step
        contentView.addSubview(stepButton)
        stepButton.snp.makeConstraints { make in
            make.top.equalTo(bpmButton)
            make.left.equalTo(calorieButton.snp.right).offset(10)
            make.width.height.equalTo(bpmButton)
            make.right.equalTo(contentView)
        }
        
        contentView.addSubview(stepImage)
        stepImage.snp.makeConstraints { make in
            make.top.equalTo(stepButton).offset(5)
            make.centerX.equalTo(stepButton)
        }
        
        addChild(lineChartView)
        view.addSubview(lineChartView.view)
        lineChartView.didMove(toParent: self)
        lineChartView.view.snp.makeConstraints { make in
            make.top.equalTo(calorieButton.snp.bottom)
            make.left.right.bottom.equalTo(safeAreaView)
        }
    }
}
