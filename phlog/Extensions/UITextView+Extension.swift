//
//  UITextView+Extension.swift
//  phlog
//
//  Created by Miroslav Taleiko on 22.01.2022.
//

import UIKit
import Combine

extension UITextView {
    public var textPublisher: AnyPublisher<String?, Never> {
        NotificationCenter.default
            .publisher(for: UITextView.textDidChangeNotification, object: self)
            .compactMap { $0.object as? UITextView }
            .map { $0.text ?? "" }
            .eraseToAnyPublisher()
    }
    
    public override var bounds: CGRect {
        didSet {
            self.resizePlaceholderLabel()
        }
    }

    
    @IBInspectable public var placeholder: String? {
        get {
            var placholder: String?
            if let label = self.viewWithTag(1000) as? UILabel {
                placholder = label.text
            }
            return placholder
        }
        set {
            if let label = self.viewWithTag(1000) as? UILabel {
                label.text = newValue
                label.sizeToFit()
            } else {
                self.addPlaceholderlabel(with: newValue!)
            }
        }
    }

    private func addPlaceholderlabel(with text: String) {
        let label = UILabel()
        label.text = text
        label.sizeToFit()
        
        label.font = self.font
        label.textColor = .darkGray
        label.tag = 1000
        
        label.isHidden = !self.text.isEmpty
        addSubview(label)
        resizePlaceholderLabel()
        subscribeToNotifiaction()
    }
    
    private func resizePlaceholderLabel() {
        guard let label = self.viewWithTag(1000) as? UILabel else { return }
        let xPadding = self.textContainer.lineFragmentPadding
        let yPadding = self.textContainerInset.top - 2
        
        let width = self.frame.width - (xPadding * 2)
        let height = label.frame.height
        
        label.frame = CGRect(x: xPadding, y: yPadding, width: width, height: height)
    }
    
    private func subscribeToNotifiaction() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(textViewDidChange),
                                               name: UITextView.textDidChangeNotification,
                                               object: self)
    }
    
    @objc func textViewDidChange(_ sender: NSNotification) {
        guard let textView = sender.object as? UITextView,
              let label = textView.viewWithTag(1000) as? UILabel else {
                  return
              }
        
        label.isHidden = !textView.text.isEmpty
    }
}
