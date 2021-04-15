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
    private var tappedImageButtonId = Int()
    private var imageGridVisble = true
    private var gestureSwipeRecognizer = UISwipeGestureRecognizer()
    private let emptyStateImageButton = #imageLiteral(resourceName: "Plus")
    private let imagePickerController = UIImagePickerController()
    
    private let gridManager = GridManager()
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        buttonsSetup()
        gestureSetup()
        
        /// add a notification observer to keep track when the device orientation changes and update the ui
        NotificationCenter.default.addObserver(self, selector: #selector(updateUiOnOrientationChange), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    // MARK: - button setup
    
    /// Sets up all the the Buttons
    private func buttonsSetup() {
        
        /// for loop assigning the same empty state image to all 4 buttons
        /// set contentmode to keep image proportions and fill the button
        /// assign same taget function to all 4 buttons
        imageButtonsArray.forEach { button in
            button.imageView?.contentMode = .scaleAspectFill
            button.setImage(emptyStateImageButton, for: .normal)
            button.addTarget(self, action: #selector(imageButtonAction(_:)), for: .touchUpInside)
        }
        
        /// for loop assigning the same selected state image to all 3 coltrol buttons
        /// set content mode to keep image proportions and fill the button
        /// assign same taget function to all 3 control buttons
        controlButtonsArray.forEach { (button) in
            button.contentMode = .scaleAspectFill
            button.setImage(#imageLiteral(resourceName: "Selected"), for: .selected)
            button.addTarget(self, action: #selector(controlButtonsAction(_:)), for: .touchUpInside)
        }
        /// selects the firrst layout when the app is first opened
        controlButtonsAction(controlButtonsArray[0])
    }
    
    // MARK: - Gesture
    
    /// Gesture Recognizer setup
    private func gestureSetup() {
        gestureSwipeRecognizer.delegate = self
    
        let leftSwipe =  UISwipeGestureRecognizer(target: self, action: #selector(self.handleGesture(gesture:)))
        leftSwipe.direction = .left
        view.addGestureRecognizer(leftSwipe)
        
        let upSwipe =  UISwipeGestureRecognizer(target: self, action: #selector(self.handleGesture(gesture:)))
        upSwipe.direction = .up
        view.addGestureRecognizer(upSwipe)
    }
    
    /// Handles the swipe gesture recognizer
    /// - Parameter gesture: pass in swipe gesture recognizer
    @objc private func handleGesture(gesture: UISwipeGestureRecognizer) {
        switch gesture.direction {
        case .left:
            if UIApplication.shared.statusBarOrientation.isLandscape {
                gridViewAnimateOut(for: .left)
            }
        case .up:
            if UIApplication.shared.statusBarOrientation.isPortrait {
                gridViewAnimateOut(for: .up)
            }
        default:
            break
        }
    }
    
    
    // MARK: - UI Animation
    
    /// Animate the girdView out of the view
    /// - Parameter direction: pass in gesture recognizer direction
    private func gridViewAnimateOut(for direction: UISwipeGestureRecognizer.Direction ) {
        
        let up = CGAffineTransform(translationX: 0, y: -UIScreen.main.bounds.height)
        let left = CGAffineTransform(translationX: -view.bounds.width, y: 0)
        
        ///  if grid is completed animate out gridview in proper direction
        let isGridComplete = gridManager.gridViewComplete(for: topImageStackView, and: bottomImageStackView, refImage: emptyStateImageButton)
        
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
    
    /// Animate gridView back to orginial position
    private func gridViewAnimateIn() {
        UIView.animate(withDuration: 0.3) {
            self.gridView.transform = .identity
        }
    }
   
    // MARK: - Alert
    private func incompleteGridAlert() {
        let alert = UIAlertController(title: "Oups!", message: "Vous devez compléter la grille avant de pouvoir partager avec vos amis.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alert.addAction(okAction)
        present(alert, animated: true)
    }
    
    // MARK: UI orientation update
    
    /// Update the UI depending on device orientation
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
    
    /// Control the grid by hidding or showing button within the 2 stackviews
    /// - Parameter sender: pass in the control button tapped
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
        /// To match the layout Icons of the control button
        /// image buttons are hidden depending on which control button is tapped
        /// there are 3 cases:    top right is hidden  (imageButton tag 1)
        ///                bottom right is hidden  (imageButton tag 3)
        ///                none of the button are hidden then all 4 button are showing
        /// by hidding those 2 button , the stack view streches the adjacent button to full width
        switch sender.tag {
        case 0:
            imageButtonsArray[1].isHidden = true
        case 1:
            imageButtonsArray[3].isHidden = true
        default:
            return
        }
    }
    
    /// Presents the image picker whe, an image button is tapped
    /// - Parameter sender: pass in the image button tapped
    @objc private func imageButtonAction(_ sender: UIButton) {
        /// the tappedImageButtonId var keep tracked of the  tag for the button tapped
        /// so the image is assigned to the proper button
        tappedImageButtonId = sender.tag
        presentImagePicker()
    }
    
    
    // MARK: - Share
    
    /// Share gridView as an image
    private func shareImageFromGrid() {
        /// convert uiview to image, returns an image in the closure .
        /// assign weak self to avoid retain cycles
        gridManager.viewToImage(for: gridView) { [weak self] image in
            
            /// pass in the image to the activity controller
            let activityController = UIActivityViewController(activityItems: [image],
                                                              applicationActivities: nil)
            /// on completion or dismissal animate the grid view back to its original position
            /// _ are put in the closure as we re not using any of these datas
            activityController.completionWithItemsHandler = { activity, completed, items, error in
                if error != nil {
                    print("\(error?.localizedDescription ?? "")")
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
    
    /// Presente Image Picker Controller
    private func presentImagePicker() {
        imagePickerController.allowsEditing = false
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
}


// MARK: Extension

extension ViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate  {
    
    /// Delegate function returning a selected image
    /// - Parameters:
    ///   - picker: UIImagePickerController
    ///   - info: return image info
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        /// assigned the image to the button by using the tappedImageButtonId var that keeps track of the button tag pproperty
        imageButtonsArray[tappedImageButtonId].setImage(image, for: .normal)
        self.dismiss(animated: true, completion: nil)
    }
    
    /// Delegate method to dismiss picker if cancel button is tapped
    /// - Parameter picker: UIImagePickerController
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}


