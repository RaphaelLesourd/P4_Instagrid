//
//  ViewController.swift
//  TestInstagrid
//
//  Created by Birkyboy on 20/03/2021.
//

import UIKit
import Photos

class ViewController: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var imageGridContainerView: UIView!
    @IBOutlet weak var topImageStackView: UIStackView!
    @IBOutlet weak var bottomImageStackView: UIStackView!
   
    @IBOutlet var imageButtonsArray: [UIButton]!
    @IBOutlet var controlButtonsArray: [UIButton]!
    
    @IBOutlet weak var swipeIcon: UIImageView!
    @IBOutlet weak var swipeLabel: UILabel!
    
    var imagePicker: ImagePicker?
    var tappedImageButtonId = Int()
    var imageGridVisble = true
    var gestureSwipeRecognizer = UISwipeGestureRecognizer()
    
    let emptyStateImageButton = #imageLiteral(resourceName: "Plus")
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        buttonsSetup()
        gestureSetup()
        
        self.imagePicker = ImagePicker(presentationController: self, delegate: self)
        controlButtonsAction(controlButtonsArray[0])
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateUiOnOrientationChange), name: UIDevice.orientationDidChangeNotification, object: nil)
        
    }
    
    // MARK: - Setup
    
    /// Sets up all the the Buttons
    private func buttonsSetup() {
        
        /// for loop assigning the same empty state image to all 4 buttons
        /// set contentmode to keep image proportions and fill the button
        /// assign same taget function to all 4 buttons
        for button in imageButtonsArray {
            button.imageView?.contentMode = .scaleAspectFill
            button.setImage(emptyStateImageButton, for: .normal)
            button.addTarget(self, action: #selector(imageButtonAction(_:)), for: .touchUpInside)
        }
        
        /// for loop assigning the same selected state image to all 3 coltrol buttons
        /// set content mode to keep image proportions and fill the button
        /// assign same taget function to all 3 control buttons
        for button in controlButtonsArray {
            button.contentMode = .scaleAspectFill
            button.setImage(#imageLiteral(resourceName: "Selected"), for: .selected)
            button.addTarget(self, action: #selector(controlButtonsAction(_:)), for: .touchUpInside)
        }
    }
    
    
    // MARK: - Gesture
    
    /// Gesture Recognizer setup
    private func gestureSetup() {
        gestureSwipeRecognizer.delegate = self
        
        /// Assign gesture handler to 2 case .up and .left
        let directions: [UISwipeGestureRecognizer.Direction] = [.up, .left]
        for direction in directions {
            gestureSwipeRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(self.handleGesture(gesture:)))
            gestureSwipeRecognizer.direction = direction
            self.view.addGestureRecognizer(gestureSwipeRecognizer)
        }
        
    }
    
    
    /// Handles the swipe gesture recognizer
    /// - Parameter gesture: pass in swipe gesture recognizer
    @objc func handleGesture(gesture: UISwipeGestureRecognizer) {
        ///
       
        if self.imageGridComplete() {
            if gesture.direction == .up && UIDevice.current.orientation.isPortrait {
                gridViewAnimateOut(for: .up)
            } else if gesture.direction == .left && UIDevice.current.orientation.isLandscape {
                gridViewAnimateOut(for: .left)
            }
        } else {
            
            /// TO_DO: Add Alert View with single Ok button
            print("Not finished")
        }
    }
    
    
    
    // MARK: - UI Animation
    
    /// Animate the girdView out of the view
    /// - Parameter direction: pass in gesture recognizer direction
    func gridViewAnimateOut(for direction: UISwipeGestureRecognizer.Direction ) {
        
        let up = CGAffineTransform(translationX: 0, y: -UIScreen.main.bounds.height)
        let left = CGAffineTransform(translationX: -view.bounds.width, y: 0)
        
        UIView.animate(withDuration: 0.3) {
            /// Check which direction is passed in and assign proper up or left translation
            self.imageGridContainerView.transform = direction == .up ? up : left
        } completion: { _ in
            /// On completion share the gridView
            self.shareGridView()
        }
    }
    
    /// Animate gridView back to orginial position
    func gridViewAnimateIn() {
        UIView.animate(withDuration: 0.3) {
            self.imageGridContainerView.transform = .identity
        }
    }
    
    
    /// Update the UI depending on device orientation
    @objc func updateUiOnOrientationChange() {
        if UIDevice.current.orientation.isLandscape {
            swipeIcon.image = #imageLiteral(resourceName: "Arrow Left")
            swipeLabel.text = "Swipe left to share"
        } else  {
            swipeIcon.image = #imageLiteral(resourceName: "Arrow Up")
            swipeLabel.text = "Swipe right to share"
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
    @objc func imageButtonAction(_ sender: UIButton) {
        /// the tappedImageButtonId var keep tracked of the  tag for the button tapped
        /// so the image is assigned to the proper button
        tappedImageButtonId = sender.tag
        imagePicker?.present(from: imageButtonsArray[tappedImageButtonId])
    }
    
    
    // MARK: Private Functions
    
    /// Share gridView as an image
    private func shareGridView() {
        
        /// convert uiview to image, returns an image in the closure .
        /// assign weak self to avoid retain cycles and memory leak
        imageGridContainerView.convertToImage { [weak self] image in
            
            /// pass in the image to the activity controller
            let activityController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
            
            /// on completion or dismissal animate the grid view back to its original position
            /// _ are put in the closure as we re not using any of these datas
            activityController.completionWithItemsHandler = { _, _, _, _ in
                self?.gridViewAnimateIn()
            }
            /// present the activity controller
            self?.present(activityController, animated: true, completion: nil)
        }
    }
    
    
    /// Keep track if all images are set for the given layout
    /// - Returns: return true if all images required are present
    private func imageGridComplete() -> Bool {
        
        var availableImageCount = 0
        var imageToSetCount = 0
        
        /// for loop counting how many images are not hidden in the top image stackview
        ///
        for view in topImageStackView.arrangedSubviews {
            if !view.isHidden {
                availableImageCount += 1
            }
            if let button = view as? UIButton, button.imageView?.image != emptyStateImageButton {
                imageToSetCount += 1
            }
        }
        for view in bottomImageStackView.arrangedSubviews {
            if !view.isHidden {
                availableImageCount += 1
            }
            if let button = view as? UIButton, button.imageView?.image != emptyStateImageButton {
                imageToSetCount += 1
            }
        }
        
        print("Max image to set: \(availableImageCount), image set: \(imageToSetCount)" )
        return imageToSetCount >= availableImageCount
    }
    
    
}

// MARK: Extension

extension ViewController: ImagePickerDelegate {
    
    /// imagepicker selected image
    /// - Parameter image: optional returned from the image picker
    func didSelect(image: UIImage?) {
        /// unwraped the optional to use the iamge if not nil
        guard let image = image else {return}
        /// assigned the image to the button by using the tappedImageButtonId var that keeps track of the button tag pproperty
        imageButtonsArray[tappedImageButtonId].setImage(image, for: .normal)
    }
    
}


