//
//  ViewController.swift
//  TestInstagrid
//
//  Created by Birkyboy on 20/03/2021.
//

import UIKit
import Photos

class ViewController: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var gridView: UIView!
    @IBOutlet weak var topImageStackView: UIStackView!
    @IBOutlet weak var bottomImageStackView: UIStackView!
    
    @IBOutlet var imageButtonsArray: [UIButton]!
    @IBOutlet var controlButtonsArray: [UIButton]!
    
    @IBOutlet weak var swipeIcon: UIImageView!
    @IBOutlet weak var swipeLabel: UILabel!
    
   // MARK: - Properties
    private var tappedImageButtonTag = Int()
    private var gestureSwipeRecognizer = UISwipeGestureRecognizer()
    private let emptyStateGridButtonImage = #imageLiteral(resourceName: "Plus")
    private let imagePickerController = UIImagePickerController()
    private let gridManager = GridManager()
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        buttonsSetup()
        gestureSetup()
        
        imagePickerController.delegate = self
        gestureSwipeRecognizer.delegate = self
        
        /// selects the firrst layout when the app is first opened
        controlButtonsAction(controlButtonsArray[0])
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
        controlButtonsArray.forEach { button in
            button.contentMode = .scaleAspectFill
            button.setImage(#imageLiteral(resourceName: "Selected"), for: .selected)
            button.addTarget(self, action: #selector(controlButtonsAction(_:)), for: .touchUpInside)
        }
    }
    
    // MARK: - Gesture
    
    /// Gesture Recognizer sets a left swipe for landscape mode and up swipe for portrait orientation.
    private func gestureSetup() {
    
        let leftSwipe =  UISwipeGestureRecognizer(target: self, action: #selector(self.handleGesture(gesture:)))
        leftSwipe.direction = .left
        view.addGestureRecognizer(leftSwipe)
        
        let upSwipe =  UISwipeGestureRecognizer(target: self, action: #selector(self.handleGesture(gesture:)))
        upSwipe.direction = .up
        view.addGestureRecognizer(upSwipe)
    }
    
    /// Handles the swipe gesture by animating the gridView out either to the left or up depending on device orientation.
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
    /// Before animating the view , a gridView complete for selected layout is done.
    /// - Parameter direction: pass in the gesture recognizer direction
    private func gridViewAnimateOut(to direction: UISwipeGestureRecognizer.Direction ) {
        
        let up = CGAffineTransform(translationX: 0, y: -UIScreen.main.bounds.height)
        let left = CGAffineTransform(translationX: -view.bounds.width, y: 0)
        
        ///  if grid is completed animate out gridview in proper direction
        let isGridComplete = gridManager.gridViewComplete(for: topImageStackView, and: bottomImageStackView, refImage: emptyStateGridButtonImage)
        
        if isGridComplete {
            UIView.animate(withDuration: 0.3) { [weak self] in
                /// Check which direction is passed in and assign proper up or left translation
                self?.gridView.transform = direction == .up ? up : left
            } completion: { _ in
                /// On completion share the gridView
                self.shareImageFromGrid()
            }
        } else {
            /// if grid not completed display an alert to the  user
            incompleteGridAlert()
        }
    }
    
    /// Animate gridView back to its orginial position
    private func gridViewAnimateIn() {
        UIView.animate(withDuration: 0.3) {
            self.gridView.transform = .identity
        }
    }
   
    // MARK: - Alert
    
    /// Present an alert to inform user, the grid is not complete with a simple message and a dismiss button.
    private func incompleteGridAlert() {
        let alert = UIAlertController(title: "Oups!", message: "You need to complete the chosen grid before sharing with your friends.", preferredStyle: .alert)
        let dismiss = UIAlertAction(title: "Dismiss", style: .default)
        alert.addAction(dismiss)
        present(alert, animated: true)
    }
    
    // MARK: UI orientation update
    
    /// Update the UI depending on device orientation
    /// Checks device orientation and updates the swipeIcon image and swipeLabel text.
    @objc private func updateUiOnOrientationChange() {
        if  UIApplication.shared.statusBarOrientation.isLandscape {
            swipeIcon.image = #imageLiteral(resourceName: "Arrow Left")
            swipeLabel.text = "Swipe left to share"
        } else  {
            swipeIcon.image = #imageLiteral(resourceName: "Arrow Up")
            swipeLabel.text = "Swipe up to share"
        }
    }
    
    
    
    // MARK: - Buttons Action
    
    /// Control the grid by hidding or showing button within the 2 stackviews.
    ///
    /// To match the layout Icons of the control button, image buttons are hidden depending on which control button is tapped.
    /// By hidding a button, the stackview streches the adjacent button to full width.
    /// - There are 3 cases:
    /// - Top right is hidden  TAG 1.
    /// - Bottom right is hidden  TAG 3.
    /// - None of the button are hidden then all 4 buttons are showing.
    ///
    /// - Parameter sender: Pass in the control button tapped
    @objc private func controlButtonsAction(_ sender: UIButton) {
        
        /// for loop to reset all control button in the collection to non selected state
        for button in controlButtonsArray {
            button.isSelected = false
        }
        /// set sender button to selected stated by using button tag property
        controlButtonsArray[sender.tag].isSelected = true
        
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
    /// - tappedImageButtonTag  property keeps track of the tapped button tag.
    /// - Parameter sender: Pass in the image button tapped
    @objc private func imageButtonAction(_ sender: UIButton) {
        
        tappedImageButtonTag = sender.tag
        presentImagePicker()
    }
    
    
    // MARK: - Share
    
    /// Share gridView as an image.
    ///
    /// After the gridView is converted to a UIImage, the return image is shared.
    private func shareImageFromGrid() {
      /// Converts the view to an image
        gridManager.viewToImage(for: gridView) { [weak self] image in
            
            /// pass in the image to the activity controller
            let activityController = UIActivityViewController(activityItems: [image],
                                                              applicationActivities: nil)
            /// on completion or dismissal animate the grid view back to its original position
            activityController.completionWithItemsHandler = { activity,
                                                              completed,
                                                              items,
                                                              error in
                if error != nil {
                    print("\(error?.localizedDescription ?? "")")
                    return
                }
                self?.gridViewAnimateIn()
            }
            /// present the activity controller
            DispatchQueue.main.async {
                self?.present(activityController, animated: true, completion: nil)
            }
        }
    }
    

    // MARK: - Image Picker
    
    /// Present Image Picker Controller
    private func presentImagePicker() {
        imagePickerController.allowsEditing = false
        imagePickerController.sourceType = .photoLibrary
        present(imagePickerController, animated: true, completion: nil)
    }
}


// MARK: Extension

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        /// Set the image to the proper button by using the tappedImageButtonTag property which keeps track of the button tag.
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageButtonsArray[tappedImageButtonTag].setImage(image, for: .normal)
        }
        self.dismiss(animated: true, completion: nil)
    }
  
    
    /// Delegate method to dismiss picker if cancel button is tapped
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}


