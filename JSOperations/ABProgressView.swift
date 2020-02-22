//
//  ABProgressView.swift
//  JSOperations
//
//  Created by Abhinash Khanal on 2/22/20.
//  Copyright © 2020 abhinash.com. All rights reserved.
//

import UIKit

/// The view responsible for showing the prorgess of the operation
class ABProgressView: UIView {
    
    static let nibName = "ABProgressView"
    
    @IBOutlet public var contentView: UIView!
    @IBOutlet public var operationLabel: UILabel!
    @IBOutlet public var operationProgress: UIProgressView!
    @IBOutlet public var operationStatusLabel: UILabel!
    
    var jumboMessage: JumboMessage?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadFromNib()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadFromNib()
    }
    
    /// This is where the binding of the IBOutlets gets applied
    private func loadFromNib() {
        let nib = UINib(nibName: ABProgressView.nibName, bundle: Bundle.main)
        nib.instantiate(withOwner: self, options: nil)
        if contentView != nil {
            operationLabel.text = "Operation:  "
            operationProgress.setProgress(0, animated: false)
            operationProgress.trackTintColor = .yellow
            operationStatusLabel.text = "In Progress"
            contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
            contentView.frame = frame
            addSubview(contentView)
        }
    }
    
    /// Entry point of binding the JumboMessage model to this view
    /// - Parameter message: to be bound to the view
    func bind(toJumboMessage message: JumboMessage) {
        jumboMessage = message
        operationLabel.text = "Operation: \(message.id)"
        if let state = message.state {
            if state.lowercased() == "success" {
                updateForSuccess()
                return
            } else if state.lowercased() == "error" {
                updateForError()
                return
            }
        }
        let normalizedProgress = Float(message.progress ?? 0) / 100.0
        operationProgress.setProgress(normalizedProgress, animated: true)
        operationStatusLabel.text = "In Progress"
    }
    
    /// Helper function to changethe view state to successful
    private func updateForSuccess() {
        operationProgress.setProgress(1, animated: true)
        operationStatusLabel.text = "Successful"
        changeTint(toColor: .green)
    }
    
    /// Helper function to changethe view state to failed
    private func updateForError() {
        operationStatusLabel.text = "Failed"
        changeTint(toColor: .red)
    }
    
    /// Matching both the progress tint and tracking tint in case of failure.
    /// - Parameter color: to be applied to the progress view
    private func changeTint(toColor color: UIColor) {
        self.operationProgress.progressTintColor = color
        self.operationProgress.trackTintColor = color
    }
    
    /// This is necessary to ensure that the proper state is applied
    /// in case of orientation changes which would call the
    /// subviews to be laid out
    override func layoutSubviews() {
        if let jumboMessage = jumboMessage {
            bind(toJumboMessage: jumboMessage)
        }
        super.layoutSubviews()
    }

}
