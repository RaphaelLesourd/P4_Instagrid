//
//  UIViewExtension.swift
//  TestInstagrid
//
//  Created by Birkyboy on 21/03/2021.
//

import UIKit


/// Utility class for the GridView
class GridManager {
    
    /// Convert any view to an image
    /// - Parameters:
    ///   - view: Pass in the view to convert
    ///   - completion: Returns an image
    func viewToImage(for view: UIView, completion: (UIImage) -> Void)  {
        let renderer = UIGraphicsImageRenderer(bounds: view.bounds)
        let image = renderer.image { rendererContext in
            view.layer.render(in: rendererContext.cgContext)
        }
        completion(image)
    }
    
    
    /// Check if the grid is complete.
    ///
    /// The two stackViews that composes the gridView are checked for completion individually.
    /// If both have their required number of images, the girdView is determined completed.
    /// Each stackViews complete status starts at a false until its complete.
    /// - Parameters:
    ///   - topStack: Pass in the top stackview object.
    ///   - bottomStack: Pass in the bottom stackview object.
    ///   - refImage: Pass in the ref image to compare with.
    /// - Returns: Bool value if grid is complete.
    func gridViewComplete(for topStack: UIStackView, and bottomStack: UIStackView,
                          refImage: UIImage) -> Bool {
        
        var topGridComplete = false
        var bottomGridComplete = false
        /// checks if each stackview contains the ref image
        topGridComplete = gridComplete(for: topStack,imageToCheck: refImage)
        bottomGridComplete = gridComplete(for: bottomStack,imageToCheck: refImage)
        
        return topGridComplete && bottomGridComplete
    }
    
    
    /// Check if the stackview is complete
    ///
    /// - This method first checks how many images are availlable by checking the isHidden attribute of each views in the stackView.
    /// A count of available image is increased.
    /// - Then each visible button is checked to determine if its image is the emptyState image (+) or anther image. If the image in not the emptyState image then the button is considered changed with a selected image and a count is increased by 1.
    /// - Finally both if both counts are equal the stackView is considered completed and returns true.
    /// - Parameters:
    ///   - stackView: pass in a stackview.
    ///   - imageToCheck: pass in the emptyState button image.
    /// - Returns: return a stackView is complete bool
    func gridComplete(for stackView: UIStackView, imageToCheck: UIImage) -> Bool {
        
        var availableImageCount = 0
        var imageToSetCount = 0
        
        /// For Loop counting how many images are not hidden in the top & bottom image stackview
        /// this count keep track of how many image is needed to complete the grid
        for view in stackView.arrangedSubviews {
            /// if the view is not hidden increment count by 1
            if !view.isHidden {
                availableImageCount += 1
            }
            /// check if the view is a button
            /// if the button (view) is not hiden and the image in the button is not the empty state image (image has been replaced)
            /// increment the count of images set in the grid by 1
            if let button = view as? UIButton, !button.isHidden, button.imageView?.image != imageToCheck {
                imageToSetCount += 1
            }
        }
        /// compare if the number of images set are equal the available views  for the layout
        /// return true if the stackView is completed
        return imageToSetCount == availableImageCount
    }
    
    
}
