//
//  ViewController.swift
//  TestInstagrid
//
//  Created by Birkyboy on 20/03/2021.
//

import UIKit
import Photos

class ViewController: UIViewController, UIGestureRecognizerDelegate, PhotoLibraryManagerDelegate {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var gridView: UIView!
    @IBOutlet weak var topImageStackView: UIStackView!
    @IBOutlet weak var bottomImageStackView: UIStackView!
    @IBOutlet var imageButtonsArray: [UIButton]!
    @IBOutlet var layoutButtonsArray: [UIButton]!
    @IBOutlet weak var swipeIcon: UIImageView!
    @IBOutlet weak var swipeLabel: UILabel!
    
    // MARK: - Properties
    private var tappedImageButtonTag = Int()
    private let gestureSwipeRecognizer = UISwipeGestureRecognizer()
    private let emptyStateGridButtonImage = #imageLiteral(resourceName: "Plus")
    private let imagePickerController = UIImagePickerController()
    private let gridManager = GridManager()
    private let photoAccessManager = PhotoLibraryAccessManager()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        buttonsSetup()
        gestureSetup()
        photoAccessManager.photoLibraryDelegate = self
        /// selects the firrst layout when the app is first opened
        layoutButtonsAction(layoutButtonsArray[0])
        /// add a notification observer to keep track when the device orientation changes and update the ui
        NotificationCenter.default.addObserver(self, selector: #selector(updateUiOnOrientationChange), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    // MARK: - button setup
    
    /// Sets up  the buttons properties for the control buttons and the gird view button.
    private func buttonsSetup() {
        /// for loop assigning the same empty state image to all 4 buttons
        /// set contentmode to keep image proportions and fill the button
        /// assign same target function to all 4 buttons
        imageButtonsArray.forEach { button in
            button.imageView?.contentMode = .scaleAspectFill
            button.setImage(emptyStateGridButtonImage, for: .normal)
            button.addTarget(self, action: #selector(imageButtonAction(_:)), for: .touchUpInside)
        }
        /// for loop assigning the same selected state image to all 3 control buttons
        /// set content mode to keep image proportions and fill the button
        /// assign same target function to all 3 control buttons
        layoutButtonsArray.forEach { button in
            button.contentMode = .scaleAspectFill
            button.setImage(#imageLiteral(resourceName: "Selected"), for: .selected)
            button.addTarget(self, action: #selector(layoutButtonsAction(_:)), for: .touchUpInside)
        }
    }
    
    // MARK: - Gesture
    
    /// Gesture Recognizer sets a left swipe for landscape mode and up swipe for portrait orientation.
    private func gestureSetup() {
        gestureSwipeRecognizer.delegate = self
        
        let leftSwipe =  UISwipeGestureRecognizer(target: self, action: #selector(self.handleGesture(gesture:)))
        leftSwipe.direction = .left
        view.addGestureRecognizer(leftSwipe)
        
        let upSwipe =  UISwipeGestureRecognizer(target: self, action: #selector(self.handleGesture(gesture:)))
        upSwipe.direction = .up
        view.addGestureRecognizer(upSwipe)
    }
    
    /// Handles the swipe gesture by animating the gridView out either to the left
    /// or up depending on device orientation.
    ///
    ///  - up: available in portrait mode only
    ///  - left: available in landscape mode only
    /// - Parameter gesture: Pass in swipe gesture recognizer
    @objc private func handleGesture(gesture: UISwipeGestureRecognizer) {
        switch gesture.direction {
        case .left:
            if UIApplication.shared.statusBarOrientation.isLandscape {
                gridViewAnimateOut(to: .left)
            }
        case .up:
            if UIApplication.shared.statusBarOrientation.isPortrait {
                gridViewAnimateOut(to: .up)
            }
        default:
            break
        }
    }
    
    // MARK: - UI Animation
    
    /// Animate the girdView out of the view
    ///
    /// Before animating the view ,  gridView is complete for selected layout check is done.
    /// - Parameter direction: pass in the gesture recognizer direction
    private func gridViewAnimateOut(to direction: UISwipeGestureRecognizer.Direction ) {
        /// Call function from GridManager  class to check if the grid for selected layout is complete.
        let isGridComplete = gridManager.gridViewComplete(for: topImageStackView,
                                                          and: bottomImageStackView,
                                                          refImage: emptyStateGridButtonImage)
        if isGridComplete {
            let directionUp = CGAffineTransform(translationX: 0, y: -UIScreen.main.bounds.height)
            let directionLeft = CGAffineTransform(translationX: -view.bounds.width, y: 0)
            /// Check which direction is passed in and assign proper up or left translation
            /// On completion the activity controller is presented to share the gridView
            /// if grid not completed display an alert to the  user
            UIView.animate(withDuration: 0.3) {
                self.gridView.transform = direction == .up ? directionUp : directionLeft
            } completion: { _ in
                self.shareImageFromGrid()
            }
        } else {
            presentAlert(message: "You need to complete the chosen grid before sharing with your friends.")
        }
    }
    
    /// Animate gridView back to its orginial position
    private func gridViewAnimateIn() {
        UIView.animate(withDuration: 0.3) {
            self.gridView.transform = .identity
        }
    }
    
    // MARK: - UI orientation update
    
    /// Update the UI depending on device orientation
    /// Checks device orientation and updates the swipeIcon image and swipeLabel text.
    @objc private func updateUiOnOrientationChange() {
        if  UIApplication.shared.statusBarOrientation.isLandscape {
            swipeIcon.image = #imageLiteral(resourceName: "Arrow Left")
            swipeLabel.text = "Swipe left to share"
        } else {
            swipeIcon.image = #imageLiteral(resourceName: "Arrow Up")
            swipeLabel.text = "Swipe up to share"
        }
    }
    
    // MARK: - Buttons Action
    
    /// Control the grid by hidding or showing button within the 2 stackviews.
    ///
    /// To match the selected layout, image buttons are hidden depending on which layout button is tapped.
    ///
    /// By hidding an image button, the stackview streches the adjacent button t
    /// o full width and give the effect of having one button.
    ///
    /// `Three cases:`
    /// - First layout      : Top right is hidden  TAG 1.
    /// - Second layout : Bottom right is hidden  TAG 3.
    /// - Third layout     : None of the button are hidden.
    ///
    /// - Parameter sender: Pass in the control button tapped
    @objc private func layoutButtonsAction(_ sender: UIButton) {
        /// for loop to reset all layout buttons in the collection to non selected state
        for button in layoutButtonsArray {
            button.isSelected = false
        }
        /// set sender button to selected stated by using button tag property
        layoutButtonsArray[sender.tag].isSelected = true
        /// for loop to reset all imageButton in the collection to non hiden state
        for button in imageButtonsArray {
            button.isHidden = false
        }
        /// Hides the relevant button depending on the layout selected
        switch sender.tag {
        case 0:
            imageButtonsArray[1].isHidden = true
        case 1:
            imageButtonsArray[3].isHidden = true
        default:
            return
        }
    }
    
    /// Presents the image picker when a gridView button is tapped.
    ///
    /// `tappedImageButtonTag`  property keeps track of the tapped button tag.
    /// - Parameter sender: Pass in the image button tapped
    @objc private func imageButtonAction(_ sender: UIButton) {
        tappedImageButtonTag = sender.tag
        photoAccessManager.accessPermission()
    }
    // MARK: - Share
    
    /// Share gridView as an image.
    ///
    /// After the gridView is converted to a UIImage, the return image is shared.
    private func shareImageFromGrid() {
        /// Converts the view to an image
        gridManager.viewToImage(for: gridView) { [weak self] image in
            guard let self = self else {return}
            /// pass in the image to the activity controller
            let activityController = UIActivityViewController(activityItems: [image],
                                                              applicationActivities: nil)
            /// on completion or dismissal animate the grid view back to its original position
            activityController.completionWithItemsHandler = { _, _, _, error in
                if error != nil {
                    print("\(error?.localizedDescription ?? "")")
                    return
                }
                self.gridViewAnimateIn()
            }
            /// present the activity controller
            DispatchQueue.main.async {
                self.present(activityController, animated: true, completion: nil)
            }
        }
    }
    
    // MARK: - Image Picker
    
    /// Present Image Picker Controller
    ///
    /// First checks If photo library is access authoized:
    /// - true: Present image picker.
    /// - false:  display an alert.
    ///
    /// Before presenting the image picker controller the source type availability is checked.
    func presentImagePicker() {
        let sourceType = UIImagePickerController.SourceType.photoLibrary
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            DispatchQueue.main.async {
                self.imagePickerController.delegate = self
                self.imagePickerController.allowsEditing = false
                self.imagePickerController.sourceType = sourceType
                self.present(self.imagePickerController, animated: true, completion: nil)
            }
        }
    }

    // MARK: - Alert

    /// Present an alert to inform user of a potential issue.
    /// - Parameters:
    ///   - title: Alert title
    ///   - body: Message to the user
    func presentAlert(with title: String = "Oups!", message body: String) {
        let alert = UIAlertController(title: title, message: body, preferredStyle: .alert)
        let dismiss = UIAlertAction(title: "Dismiss", style: .default)
        alert.addAction(dismiss)
        present(alert, animated: true)
    }
}

// MARK: Extension

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        /// Set the image to the proper button by using the tappedImageButtonTag property
        ///  which keeps track of the button tag.
        if let image = info[.originalImage] as? UIImage {
            imageButtonsArray[tappedImageButtonTag].setImage(image, for: .normal)
        }
        dismiss(animated: true, completion: nil)
    }
    /// Delegate method to dismiss picker if cancel button is tapped
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
