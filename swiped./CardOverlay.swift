//
//  CardOverlay.swift
//  swiped.
//
//  Created by tobykohlhagen on 2/5/2025.
//

import Shuffle
import UIKit

class CardOverlay: UIView {

  init(direction: SwipeDirection) {
    super.init(frame: .zero)
    switch direction {
    case .left:
      createLeftOverlay()
    case .up:
      createUpOverlay()
    case .right:
      createRightOverlay()
    default:
      break
    }
  }

  required init?(coder: NSCoder) {
    return nil
  }

  private func createLeftOverlay() {
    let leftTextView = CardOverlayLabelView(withTitle: "DELETE",
																						color: .sampleRed,
																						rotation: CGFloat.pi / 10)
    addSubview(leftTextView)
    leftTextView.anchor(top: topAnchor,
                        right: rightAnchor,
                        paddingTop: 30,
                        paddingRight: 14)
  }

  private func createUpOverlay() {
    let upTextView = CardOverlayLabelView(withTitle: "SKIP",
																					color: .sampleBlue,
																					rotation: -CGFloat.pi / 20)
    addSubview(upTextView)
    upTextView.anchor(bottom: bottomAnchor, paddingBottom: 20)
    upTextView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
  }

  private func createRightOverlay() {
		let rightTextView = CardOverlayLabelView(withTitle: "KEEP",
																						 color: .sampleGreen,
																						 rotation: -CGFloat.pi / 10)
    addSubview(rightTextView)
    rightTextView.anchor(top: topAnchor,
                         left: leftAnchor,
                         paddingTop: 26,
                         paddingLeft: 14)
  }
}

private class CardOverlayLabelView: UIView {

  private let titleLabel: UILabel = {
    let label = UILabel()
    label.textAlignment = .center
    return label
  }()

  init(withTitle title: String, color: UIColor, rotation: CGFloat) {
    super.init(frame: CGRect.zero)
    layer.borderColor = color.cgColor
    layer.borderWidth = 4
    layer.cornerRadius = 4
    transform = CGAffineTransform(rotationAngle: rotation)

    addSubview(titleLabel)
    titleLabel.textColor = color
    titleLabel.attributedText = NSAttributedString(string: title,
                                                   attributes: NSAttributedString.Key.overlayAttributes)
    titleLabel.anchor(top: topAnchor,
                      left: leftAnchor,
                      bottom: bottomAnchor,
                      right: rightAnchor,
                      paddingLeft: 8,
                      paddingRight: 3)
  }

  required init?(coder aDecoder: NSCoder) {
    return nil
  }
}

extension NSAttributedString.Key {

  static var overlayAttributes: [NSAttributedString.Key: Any] = [
    NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-Bold", size: 42)!,
    NSAttributedString.Key.kern: 5.0
  ]
}

extension UIColor {
  static var sampleRed = UIColor(red: 300, green: 0 / 255, blue: 0 / 255, alpha: 1)
  static var sampleGreen = UIColor(red: 0 / 255, green: 300, blue: 0 / 255, alpha: 1)
  static var sampleBlue = UIColor(red: 0 / 255, green: 0 / 255, blue: 300, alpha: 1)
}
