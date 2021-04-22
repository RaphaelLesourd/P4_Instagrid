//
//  PhotoLibraryAccessManager.swift
//  P4_Instagrid
//
//  Created by Birkyboy on 19/04/2021.
//

import Foundation
import Photos

protocol PhotoLibraryManagerDelegate: AnyObject {
    func presentAlert(with title: String, message body: String)
    func presentImagePicker()
}

/// Utility class for checking if access to the photo library is authorized
class PhotoLibraryAccessManager {
    var photoLibraryDelegate: PhotoLibraryManagerDelegate?

    /// In case the  authorization status is not determined, a new request alert is presented.
    func accessPermission() {
         let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
         switch photoAuthorizationStatus {
            case .authorized, .limited:
                photoLibraryDelegate?.presentImagePicker()
         case .notDetermined:
             PHPhotoLibrary.requestAuthorization({ (newStatus) in
                 if newStatus == PHAuthorizationStatus.authorized {
                    self.photoLibraryDelegate?.presentImagePicker()
                 }
             })
         case .restricted, .denied:
            photoLibraryDelegate?.presentAlert(with: "Oups!", message: "Unable to access your photo library. Please, check your settings.")
         @unknown default:
             break
         }
     }
}
