//
//  UIViewExtension.swift
//  TestInstagrid
//
//  Created by Birkyboy on 21/03/2021.
//

import UIKit


class Utilities {
    
    static let shared = Utilities()
    
    /// Convert any view to an image
    /// - Parameters:
    ///   - view: pass in the view to convert
    ///   - completion: return in the closure an image
    func viewToImage(for view: UIView, completion: (UIImage) -> Void)  {
        let renderer = UIGraphicsImageRenderer(bounds: view.bounds)
        let image = renderer.image { rendererContext in
            view.layer.render(in: rendererContext.cgContext)
        }
        completion(image)
    }
    
    
    
    /// Check if the grid is complete
    /// - Parameters:
    ///   - topStack: pass in the top stackview object
    ///   - bottomStack: pass in the bottom stackview object
    ///   - refImage: pass in the ref image to compare with
    /// - Returns: a Bool value if grid is complete
    func gridViewComplete(for topStack: UIStackView, and bottomStack: UIStackView, refImage: UIImage) -> Bool {
        var topGridComplete = false
        var bottomGridComplete = false
        /// checks if each stackview contains the ref image
        topGridComplete = gridComplete(for: topStack,imageToCheck: refImage)
        bottomGridComplete = gridComplete(for: bottomStack,imageToCheck: refImage)
        return topGridComplete && bottomGridComplete
    }
    
    
    /// Check if the a stackview as an image from the photo library
    /// - Parameters:
    ///   - stackView: pass in a stackview
    ///   - imageToCheck: pass in a reference image to check against
    /// - Returns: return a bool depending if all images in the stackview are not the reference image
    func gridComplete(for stackView: UIStackView, imageToCheck: UIImage) -> Bool {
        
        var availableImageCount = 0
        var imageToSetCount = 0
        
        /// for loop counting how many images are not hidden in the top & bottom image stackview
        /// this count keep track of how many image is needed to complete the grid
        for view in stackView.arrangedSubviews {
            /// if the view is not hidden increment count by 1
            if !view.isHidden {
                availableImageCount += 1
            }
            /// check if the view is a button
            /// if the button (view) is not hiden and the image in the button is not the emptystate image (image has been replaced)
            /// increment the count of images set in the grid by 1
            if let button = view as? UIButton, !button.isHidden, button.imageView?.image != imageToCheck {
                imageToSetCount += 1
            }
        }
        /// compare if the number of image uploaded equal the available views in for the layout
        /// return true if the grid is completed
        return imageToSetCount == availableImageCount
    }
    
    
}
