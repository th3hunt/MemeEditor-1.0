//
//  EditorViewController.swift
//  MemeEditor
//
//  Created by Stratos Pavlakis on 05/01/16.
//  Copyright © 2016 Stratos Pavlakis. All rights reserved.
//

import UIKit

class EditorViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    
    static let memeTextAttributes = [
        NSStrokeColorAttributeName: UIColor.blackColor(),
        NSForegroundColorAttributeName: UIColor.whiteColor(),
        NSFontAttributeName: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSStrokeWidthAttributeName: -2.0 // a negative value indicates stroke with fill https://developer.apple.com/library/mac/qa/qa1531/_index.html
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTextFields()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        imageView.contentMode = .ScaleAspectFit
        toggleButtons()
        hideTextFields()
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    
    //
    // Actions
    //
    
    @IBAction func pickAnImageFromAlbum(sender: UIBarButtonItem) {
        pickAnImage(.SavedPhotosAlbum)
    }
    
    @IBAction func pickAnImageFromCamera(sender: UIBarButtonItem) {
        guard isCameraAvailable() else {
            return
        }
        
        pickAnImage(.Camera)
    }
    
    
    //
    // UIImagePickerControllerDelegate
    //
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        dismissViewControllerAnimated(true) {
            if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
                self.imageView.image = image
                self.showTextFields()
            } else {
                self.showError("Could not select a picture")
            }
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    //
    // Keyboard Notification Handlers
    //
    
    func keyboardWillShow(notification: NSNotification) {
        if bottomTextField.isFirstResponder() {
            view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        view.frame.origin.y = 0
    }
    
    
    //
    // Private Methods
    //
    
    private func pickAnImage(sourceType: UIImagePickerControllerSourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = sourceType
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    private func isCameraAvailable() -> Bool {
       return UIImagePickerController.isSourceTypeAvailable(.Camera)
    }
    
    private func setupTextFields() {
        topTextField.defaultTextAttributes = EditorViewController.memeTextAttributes
        topTextField.textAlignment = .Center

        bottomTextField.defaultTextAttributes = EditorViewController.memeTextAttributes
        bottomTextField.textAlignment = .Center
    }
    
    private func showTextFields() {
        topTextField.hidden = false
        bottomTextField.hidden = false
    }
    
    private func hideTextFields() {
        topTextField.hidden = true
        bottomTextField.hidden = true
    }
    
    private func toggleButtons() {
        shareButton.enabled = false
        cameraButton.enabled = isCameraAvailable()
    }
    
    private func subscribeToKeyboardNotifications() {
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    private func unsubscribeFromKeyboardNotifications() {
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        notificationCenter.removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.CGRectValue().height
    }
    
    private func showError(message: String = "Oops! An unknown error occurred.") {
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(
            UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default) {
                [unowned self] (UIAlertAction) in
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        )
        presentViewController(alertController, animated: true, completion: nil)
    }
    
}
