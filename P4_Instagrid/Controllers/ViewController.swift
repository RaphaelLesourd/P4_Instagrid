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
    
    @IBOutlet var imageButtons: [UIButton]!
    @IBOutlet var controlButtons: [UIButton]!
    
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
        controlButtonsAction(controlButtons[0])
        
        NotificationCenter.default.addObserver(self, selector: #selector(directionChange), name: UIDevice.orientationDidChangeNotification, object: nil)
        
    }
    
    // MARK: - Setup
    
    private func buttonsSetup() {
        
        for button in imageButtons {
            button.imageView?.contentMode = .scaleAspectFill
            button.setImage(emptyStateImageButton, for: .normal)
            button.addTarget(self, action: #selector(imageButtonAction(_:)), for: .touchUpInside)
        }
        
        for button in controlButtons {
            button.contentMode = .scaleAspectFill
            button.setImage(#imageLiteral(resourceName: "Selected"), for: .selected)
            button.addTarget(self, action: #selector(controlButtonsAction(_:)), for: .touchUpInside)
        }
    }
    
    
    
    // MARK: - Gesture
    
    private func gestureSetup() {
        gestureSwipeRecognizer.delegate = self
        
        let directions: [UISwipeGestureRecognizer.Direction] = [.up, .left]
        for direction in directions {
            gestureSwipeRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(self.handleGesture(gesture:)))
            gestureSwipeRecognizer.direction = direction
            self.view.addGestureRecognizer(gestureSwipeRecognizer)
        }
        
    }
    
    
    
    @objc func handleGesture(gesture: UISwipeGestureRecognizer) {
        
        let up = CGAffineTransform(translationX: 0, y: -UIScreen.main.bounds.height)
        let left = CGAffineTransform(translationX: -view.bounds.width, y: 0)
        
        if self.imageGridComplete() {
            if gesture.direction == .up && UIDevice.current.orientation.isPortrait {
                gridViewAnimateOut(up)
            } else if gesture.direction == .left && UIDevice.current.orientation.isLandscape {
                gridViewAnimateOut(left)
            }
        } else {
            print("Not finished")
        }
    }
    
    func gridViewAnimateOut(_ directtion:CGAffineTransform) {
        UIView.animate(withDuration: 0.3) {
            self.imageGridContainerView.transform = directtion
        } completion: { _ in
            self.shareCollage()
        }
    }
    
    func gridViewAnimateIn() {
        UIView.animate(withDuration: 0.3) {
            self.imageGridContainerView.transform = .identity
        }
    }
    
    
    @objc func directionChange() {
        if UIDevice.current.orientation.isLandscape {
            swipeIcon.image = #imageLiteral(resourceName: "Arrow Left")
            swipeLabel.text = "Swipe left to share"
        } else  {
            swipeIcon.image = #imageLiteral(resourceName: "Arrow Up")
            swipeLabel.text = "Swipe right to share"
        }
    }
    
    
    // MARK: - Buttons Action
    
    @objc private func controlButtonsAction(_ sender: UIButton) {
        
        for button in controlButtons {
            button.isSelected = false
        }
        controlButtons[sender.tag].isSelected = true
        
        for button in imageButtons {
            button.isHidden = false
        }
        
        switch sender.tag {
        case 0:
            imageButtons[1].isHidden = true
        case 1:
            imageButtons[3].isHidden = true
        default:
            return
        }
        
    }
    
    
    @objc func imageButtonAction(_ sender: UIButton) {
        tappedImageButtonId = sender.tag
        imagePicker?.present(from: imageButtons[tappedImageButtonId])
    }
    
    
    // MARK: Private Functions
    
    private func shareCollage() {
        
        imageGridContainerView.convertToImage { (image) in
            let activityController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
            activityController.completionWithItemsHandler = { _, _, _, _ in
                self.gridViewAnimateIn()
            }
            self.present(activityController, animated: true, completion: nil)
        }
    }
    
    
    private func imageGridComplete() -> Bool {
        var availableImageCount = 0
        var imageToSetCount = 0
        
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
    
    func didSelect(image: UIImage?) {
        guard let image = image else {return}
        imageButtons[tappedImageButtonId].setImage(image, for: .normal)
    }
    
}


