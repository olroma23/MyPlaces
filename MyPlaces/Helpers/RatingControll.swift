//
//  RatingControll.swift
//  MyPlaces
//
//  Created by Roman Oliinyk on 14.05.2020.
//  Copyright © 2020 Roman Oliinyk. All rights reserved.
//

import UIKit

@IBDesignable class RatingControll: UIStackView {
    
    
    //    MARK: Properties
    
    private var ratingButtons = [UIButton]()
    
    var rating = 0 {
        didSet {
            updateButtonSelectionState()
        }
    }
    
    @IBInspectable var starSize: CGSize = CGSize(width: 44.0, height: 44.0) {
        didSet {
            setupButtons()
        }
    }
    @IBInspectable var starCount: Int = 5 {
        didSet {
            setupButtons()
        }
    }
    
    
    //    MARK: Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButtons()
    }
    required init(coder: NSCoder) {
        super.init(coder: coder)
        setupButtons()
    }
    
    
    //    MARK: private methods
    
    private func setupButtons() {
        
        for button in ratingButtons {
            removeArrangedSubview(button)
            button.removeFromSuperview()
        }
        
        ratingButtons.removeAll()
        
        let bundle = Bundle(for: type(of: self))
        let filledStar = UIImage(named: "star (1)", in: bundle, compatibleWith: self.traitCollection)
        let emptyStar = UIImage(named: "star", in: bundle, compatibleWith: self.traitCollection)
        let highlightedStar = UIImage(named: "star (2)", in: bundle, compatibleWith: self.traitCollection)
        
        for _ in 0..<starCount {
            //        Button creation
            let button = UIButton()
            
            //        Add constaints
            button.translatesAutoresizingMaskIntoConstraints = false
            button.heightAnchor.constraint(equalToConstant: starSize.height).isActive = true
            button.widthAnchor.constraint(equalToConstant: starSize.width).isActive = true
            
            //        Setup button action
            button.addTarget(self, action: #selector(ratingButtonPressed(button:)), for: .touchUpInside)
            
            //        Add button to the stack
            addArrangedSubview(button)
            
            //        Add button to array
            ratingButtons.append(button)
            
            //        Set the button image
            button.setImage(emptyStar, for: .normal)
            button.setImage(filledStar, for: .selected)
            button.setImage(highlightedStar, for: .highlighted)
            button.setImage(filledStar, for: [.highlighted, .selected])
        }
        updateButtonSelectionState()
    }
    
    
    //    MARK: Button action
    
    @objc func ratingButtonPressed(button: UIButton) {
        guard let index = ratingButtons.firstIndex(of: button) else { return }
        
//        Calculate rating of chosen star
        let selectedRating = index + 1
        
        if selectedRating == rating {
            rating = 0
        } else {
            rating = selectedRating
        }
    }
    
    private func updateButtonSelectionState() {
        for (index, button) in ratingButtons.enumerated() {
            button.isSelected = index < rating
        }
    }
    
}

