//
//  CardTableViewCell.swift
//  ZaraRickAndMorty
//
//  Created by Marc on 10/10/2023.
//

import Foundation
import UIKit

class CardTableViewCell: UITableViewCell {
    
    // MARK: - IBOutlets
    @IBOutlet weak var characterImageView: UIImageView!
    
    @IBOutlet weak var characterNameLabel: UILabel!
    @IBOutlet weak var characterStatusImageView: UIImageView!
    @IBOutlet weak var characterStatusAndSpeciesLabel: UILabel!
    
    @IBOutlet weak var lastKnownLocationLabel: UILabel!
    @IBOutlet weak var characterLocationLabel: UILabel!
    
    @IBOutlet weak var firstSeenInLabel: UILabel!
    @IBOutlet weak var characterOriginLabel: UILabel!
    
    @IBOutlet weak var bookmarkButton: UIButton!
    @IBOutlet weak var infoButton: UIButton!
    
    // MARK: - UI modifier variables
    var bookmarkButtonFilled: Bool = false {
        
        didSet {
            
            if bookmarkButtonFilled {
                
                bookmarkButton.setImage(UIImage(systemName: "bookmark.fill"), for: .normal)
            } else {
                
                bookmarkButton.setImage(UIImage(systemName: "bookmark"), for: .normal)
            }
        }
    }
    
    // MARK: - IBAction callbacks
    var bookmarkButtonActionCallback: ((Any, Bool) -> Void)?
    var infoButtonActionCallback: ((Any) -> Void)?
    
    // MARK: - IBActions
    @IBAction func bookmarkButtonAction(_ sender: Any) {
        
        bookmarkButtonFilled = !bookmarkButtonFilled
        
        if let bookmarkButtonActionCallback = bookmarkButtonActionCallback {
            
            bookmarkButtonActionCallback(sender, bookmarkButtonFilled)
        }
    }
    
    @IBAction func infoButtonAction(_ sender: Any) {

        if let infoButtonActionCallback = infoButtonActionCallback {
            
            infoButtonActionCallback(sender)
        }
    }
}
