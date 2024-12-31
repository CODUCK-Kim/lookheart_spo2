import Foundation
import UIKit
import Then

public class UIFactory {
    
    public static let shared = UIFactory()
    
    public init() {}
    
    public func stackView(
        views: [UIView],
        axis: NSLayoutConstraint.Axis,
        distribution: UIStackView.Distribution,
        alignment: UIStackView.Alignment,
        spacing: CGFloat = 0
    ) -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: views).then {
            $0.axis = axis
            $0.distribution = distribution
            $0.alignment = alignment
            $0.spacing = spacing
        }
        
        return stackView
    }
    
    public func progressView(
        backgroundColor: UIColor,
        tintColor: UIColor,
        progress: Float = 0,
        cornerRadius: CGFloat = 0,
        masksToBounds: Bool = true
    ) -> UIProgressView {
        let progressView = UIProgressView().then {
            $0.trackTintColor = backgroundColor
            $0.progressTintColor = tintColor
            $0.progress = progress
            $0.layer.cornerRadius = cornerRadius
            $0.layer.masksToBounds = masksToBounds
        }
        return progressView
    }
    
    public func textView(
        size: CGFloat,
        backgroundColor: UIColor,
        borderColor: CGColor? = nil,
        cornerRadius: CGFloat? = nil,
        borderWidth: CGFloat? = nil
    ) -> UITextView {
        let textView = UITextView().then {
            $0.font = UIFont.systemFont(ofSize: size)
            $0.backgroundColor = backgroundColor
            $0.layer.borderColor = borderColor
            $0.layer.cornerRadius = cornerRadius ?? 0
            $0.layer.borderWidth = borderWidth ?? 0
        }
        return textView
    }
    
    public func label(
        text: String? = nil,
        color: UIColor? = nil,
        font: UIFont
    ) -> UILabel {
        let label = UILabel().then {
            $0.text = text
            $0.font = font
            $0.textColor = color
        }
        return label
    }
    
    public func backgroundLabel(
        backgroundColor: UIColor,
        borderColor: CGColor,
        borderWidth: CGFloat,
        cornerRadius: CGFloat
    ) -> UILabel {
        let label = UILabel().then {
            $0.backgroundColor = backgroundColor
            $0.layer.borderColor = borderColor
            $0.layer.borderWidth = borderWidth
            $0.layer.cornerRadius = cornerRadius
            $0.layer.masksToBounds = true
        }
        return label
    }
    
    public func imageView(
        image: UIImage? = nil,
        tintColor: UIColor? = .clear,
        backgroundColor: UIColor? = .clear,
        contentMode: UIView.ContentMode = .scaleToFill
    ) -> UIImageView {
        let imageView = UIImageView().then {
            $0.image = image
            $0.tintColor = tintColor
            $0.backgroundColor = backgroundColor
            $0.contentMode = contentMode
        }
        return imageView
    }
    
    public func button(
        title: String? = nil,
        titleColor: UIColor? = nil,
        size: CGFloat = 14,
        weight: UIFont.Weight = .medium,
        backgroundColor: UIColor,
        cornerRadius: CGFloat = 0,
        borderColor: CGColor? = nil,
        borderWidth: CGFloat = 0,
        clipsToBounds: Bool = true,
        tag: Int = 0
    ) -> UIButton {
        let button =  UIButton().then {
            $0.setTitle(title, for: .normal)
            $0.setTitleColor(titleColor, for: .normal)
            $0.titleLabel?.font = UIFont.systemFont(ofSize: size, weight: weight)
            $0.backgroundColor = backgroundColor
                        
            $0.layer.cornerRadius = cornerRadius
            $0.layer.borderColor = borderColor
            $0.layer.borderWidth = borderWidth
            $0.clipsToBounds = clipsToBounds
            
            $0.tag = tag
        }
        return button
    }
    
    public func textField(
        textColor: UIColor,
        font: UIFont,
        keyboardType: UIKeyboardType,
        tintColor: UIColor? = nil,
        tag: Int = 0
    ) -> UITextField {
        let textField = UITextField().then {
            $0.textColor = textColor
            $0.font = font
            $0.keyboardType = keyboardType
            $0.tintColor = tintColor
            $0.tag = tag
        }
        return textField
    }
}
