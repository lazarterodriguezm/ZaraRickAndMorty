//
//  Utilities.swift
//  ZaraRickAndMorty
//
//  Created by Marc on 15/10/2023.
//

import Foundation
import UIKit

extension UIImageView {

    private var activityIndicator: UIActivityIndicatorView {
        
        let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = UIColor.black
        
        self.addSubview(activityIndicator)

        activityIndicator.translatesAutoresizingMaskIntoConstraints = false

        let centerX: NSLayoutConstraint = NSLayoutConstraint(
            item: self,
            attribute: .centerX,
            relatedBy: .equal,
            toItem: activityIndicator,
            attribute: .centerX,
            multiplier: 1,
            constant: 0
        )
        
        let centerY: NSLayoutConstraint = NSLayoutConstraint(
            item: self,
            attribute: .centerY,
            relatedBy: .equal,
            toItem: activityIndicator,
            attribute: .centerY,
            multiplier: 1,
            constant: 0
        )
        
        self.addConstraints([centerX, centerY])
        
        return activityIndicator
    }
    
    /// Adds an ActivityIndicator on the UIImage while fetching for an image from a URL
    /// - Parameters:
    ///   - url: Image URL
    ///   - completionHandler: Callback to execute when the image is successfully fetched
    ///   - errorHandler: Callback to execute when there is an error during the fetch
    func setImageFrom(url: URL, completionHandler: @escaping (() -> Void) = { }, errorHandler: @escaping (Error?) -> Void) {
        
        let activityIndicator: UIActivityIndicatorView = self.activityIndicator
        
        DispatchQueue.main.async(
            execute: {
                
                activityIndicator.startAnimating()
            }
        )
        
        URLSession.shared.dataTask(
            with: url,
            completionHandler: {
                
                data, response, error in
                    
                if let data: Data = data {
                    
                    DispatchQueue.main.async(
                        execute: {
                            
                            activityIndicator.stopAnimating()
                            activityIndicator.removeFromSuperview()
                            self.image = UIImage(data: data)
                            
                            completionHandler()
                        }
                    )
                } else {
                    
                    errorHandler(NSError(domain: "", code: 452, userInfo: [NSLocalizedDescriptionKey : "Invalid URL"]))
                }
            }
        ).resume()
    }
}
