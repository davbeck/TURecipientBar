//
//  ChipView.swift
//  Example
//
//  Created by David Beck on 6/20/17.
//  Copyright © 2017 ThinkUltimate. All rights reserved.
//

import UIKit


/// A Material UI style chip/token
///
/// See https://material.io/guidelines/components/chips.html#chips-contact-chips.
@available(iOS 9.0, *)
class ChipView : UIButton {
	let avatarView = UIImageView()
	let nameLabel = UILabel()
	let removeButton = UIButton(type: .custom)
	
	override init(frame: CGRect = .zero) {
		super.init(frame: frame)
		
		self.backgroundColor = #colorLiteral(red: 0.8783571124, green: 0.8784806132, blue: 0.878318131, alpha: 1)
		
		avatarView.isUserInteractionEnabled = false
		avatarView.backgroundColor = #colorLiteral(red: 0.0862745098, green: 0.3764705882, blue: 0.4862745098, alpha: 1)
		avatarView.translatesAutoresizingMaskIntoConstraints = false
		self.addSubview(avatarView)
		
		nameLabel.isUserInteractionEnabled = false
		nameLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
		nameLabel.translatesAutoresizingMaskIntoConstraints = false
		self.addSubview(nameLabel)
		
		removeButton.backgroundColor = #colorLiteral(red: 0.6509242058, green: 0.6510176659, blue: 0.6508947611, alpha: 1)
		removeButton.translatesAutoresizingMaskIntoConstraints = false
		self.addSubview(removeButton)
		
		NSLayoutConstraint.activate([
			avatarView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
			avatarView.topAnchor.constraint(equalTo: self.topAnchor),
			avatarView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
			avatarView.widthAnchor.constraint(equalTo: avatarView.heightAnchor),
			
			nameLabel.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: 8),
			nameLabel.topAnchor.constraint(equalTo: self.layoutMarginsGuide.topAnchor),
			nameLabel.bottomAnchor.constraint(equalTo: self.layoutMarginsGuide.bottomAnchor),
			
			removeButton.leadingAnchor.constraint(equalTo: nameLabel.trailingAnchor, constant: 8),
			removeButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -8),
			removeButton.centerYAnchor.constraint(equalTo: self.centerYAnchor),
			removeButton.widthAnchor.constraint(equalToConstant: 20),
			removeButton.heightAnchor.constraint(equalToConstant: 20),
			
			self.heightAnchor.constraint(equalToConstant: 30)
			])
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		self.layer.cornerRadius = self.bounds.size.height / 2
		avatarView.layer.cornerRadius = avatarView.frame.size.height / 2
		removeButton.layer.cornerRadius = removeButton.frame.size.height / 2
	}
	
	
	override var isHighlighted: Bool {
		didSet {
			update()
		}
	}
	
	override var isSelected: Bool {
		didSet {
			update()
		}
	}
	
	
	private func update() {
		if self.isHighlighted || self.isSelected {
			self.backgroundColor = #colorLiteral(red: 0.5019165277, green: 0.5019901395, blue: 0.5018931627, alpha: 1)
			removeButton.backgroundColor = .white
			nameLabel.textColor = .white
		} else {
			self.backgroundColor = #colorLiteral(red: 0.8783571124, green: 0.8784806132, blue: 0.878318131, alpha: 1)
			removeButton.backgroundColor = #colorLiteral(red: 0.6509242058, green: 0.6510176659, blue: 0.6508947611, alpha: 1)
			nameLabel.textColor = .black
		}
	}
}
