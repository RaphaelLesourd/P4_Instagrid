//
//  UIViewExtension.swift
//  TestInstagrid
//
//  Created by Birkyboy on 21/03/2021.
//

import UIKit


extension UIView {
    
    func convertToImage(completion: (UIImage) -> Void)  {
        UIGraphicsBeginImageContext(self.frame.size)
        if let context = UIGraphicsGetCurrentContext() {
            self.layer.render(in: context)
            guard let image = UIGraphicsGetImageFromCurrentImageContext() else { return }
            completion(image)
        }
    }
}
