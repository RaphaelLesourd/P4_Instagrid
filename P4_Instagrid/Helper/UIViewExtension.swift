//
//  UIViewExtension.swift
//  TestInstagrid
//
//  Created by Birkyboy on 21/03/2021.
//

import UIKit


extension UIView {
    
    func convertToImage(completion: (UIImage) -> Void)  {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        let image = renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
        completion(image)
    }
    
}
