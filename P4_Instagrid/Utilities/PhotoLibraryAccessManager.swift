//
//  PhotoLibraryAccessManager.swift
//  P4_Instagrid
//
//  Created by Birkyboy on 19/04/2021.
//

import Foundation
import Photos

/// Utility class for checking if access to the photo library is authorized
class PhotoLibraryAccessManager {

    /// In case the  authorization status is not determined, a new request alert is presented.
    /// - Parameter completion: True or false bool if authorized or not
    func accessPermission(completion: @escaping(Bool) -> Void) {
         let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
         switch photoAuthorizationStatus {
         case .authorized:
            completion(true)
         case .notDetermined:
             PHPhotoLibrary.requestAuthorization({ (newStatus) in
                 if newStatus == PHAuthorizationStatus.authorized {
                    completion(true)
                 }
             })
         case .restricted, .denied:
             completion(false)
         case .limited:
             completion(true)
         @unknown default:
             break
         }
     }
}
