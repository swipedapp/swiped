//
//  ButtonStackViewDelegate.swift
//  swiped.
//
//  Created by tobykohlhagen on 2/5/2025.
//

import UIKit

class ButtonStackView: UIStackView {

	enum Action: Int {
		case undo = 1
		case delete = 2
		case keep = 3
	}

	protocol Delegate: AnyObject {
		func didTapButton(action: Action)
	}

	weak var delegate: Delegate?

	private let undoButton = ActionButton(frame: .zero)
	private let deleteButton = ActionButton(frame: .zero)
	private let keepButton = ActionButton(frame: .zero)

	override init(frame: CGRect) {
		super.init(frame: frame)
		distribution = .equalSpacing
		alignment = .fill
		configureButtons()
	}

	required init(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private func configureButtons() {
		undoButton.setImage(UIImage(systemName: "arrow.uturn.backward.circle"), for: .normal)
		undoButton.setTitle("Undo", for: .normal)
		undoButton.addTarget(self, action: #selector(handleTap), for: .touchUpInside)
		undoButton.tag = Action.undo.rawValue
		
		deleteButton.setTitle("Delete", for: .normal)
		deleteButton.addTarget(self, action: #selector(handleTap), for: .touchUpInside)
		deleteButton.tag = Action.delete.rawValue

		keepButton.setTitle("Keep", for: .normal)
		keepButton.addTarget(self, action: #selector(handleTap), for: .touchUpInside)
		keepButton.tag = Action.keep.rawValue
		
		for button in [deleteButton, undoButton, keepButton] {
			NSLayoutConstraint.activate([
				button.heightAnchor.constraint(equalToConstant: 44)
			])
			addArrangedSubview(button)
		}
	}

	@objc private func handleTap(_ button: ActionButton) {
		let action = ButtonStackView.Action(rawValue: button.tag)!
		delegate?.didTapButton(action: action)
	}
}
