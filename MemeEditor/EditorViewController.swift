//
//  EditorViewController.swift
//  MemeEditor
//
//  Created by Stratos Pavlakis on 05/01/16.
//  Copyright © 2016 Stratos Pavlakis. All rights reserved.
//

import UIKit

class EditorViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var blankSlateLabel: UILabel!

    var meme: Meme!
    
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
        shareButton.enabled = false
        cameraButton.enabled = isCameraAvailable()
        
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
    
    @IBAction func shareMeme(sender: UIBarButtonItem) {
        guard hasMemeToShare() else {
            return
        }
        
        let memedImage = generateMemedImage()
        let activityController = UIActivityViewController(activityItems: [memedImage], applicationActivities: [])
        activityController.completionWithItemsHandler = {
            (activityType, completed, items, error) in
            if completed {
                self.meme = Meme(memedImage, topText: self.topTextField.text!, bottomText: self.bottomTextField.text!,
                    originalImage: self.imageView.image!)
            }
        }
        
        presentViewController(activityController, animated: true, completion: nil)
    }
    
    
    //
    // UIImagePickerControllerDelegate
    //
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        dismissViewControllerAnimated(true) {
            if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
                self.imageView.image = image
                self.showTextFields()
                self.toggleShareButton()
                self.blankSlateLabel.hidden = true
            } else {
                self.showError("Could not select a picture")
            }
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    //
    // UITextFieldDelegate
    //
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        shareButton.enabled = false
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        toggleShareButton()
    }
    
    //
    // Keyboard events
    //
    
    func keyboardWillShow(notification: NSNotification) {
        if bottomTextField.isFirstResponder() {
            view.frame.origin.y = -getKeyboardHeight(notification)
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        view.frame.origin.y = 0
    }
    
    
    //
    // Core Business methods
    //
    
    private func pickAnImage(sourceType: UIImagePickerControllerSourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = sourceType
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    private func generateMemedImage() -> UIImage {
        // Hide toolbar and navbar
        navigationBar.hidden = true
        toolbar.hidden = true
        
        // Hide empty text fields
        topTextField.hidden = topTextField.text!.isEmpty
        bottomTextField.hidden = bottomTextField.text!.isEmpty
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        self.view.drawViewHierarchyInRect(self.view.frame, afterScreenUpdates: true)
        let memedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // Show toolbar and navbar
        navigationBar.hidden = false
        toolbar.hidden = false
        
        // Restore empty text fields
        topTextField.hidden = false
        bottomTextField.hidden = false
        
        return memedImage
    }
    
    private func hasMemeToShare() -> Bool {
        // we require an image and at least one piece of text
        return imageView.image != nil && (!topTextField.text!.isEmpty || !bottomTextField.text!.isEmpty)
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
    
    
    //
    // Other private methods
    //
    
    private func isCameraAvailable() -> Bool {
       return UIImagePickerController.isSourceTypeAvailable(.Camera)
    }
    
    private func setupTextFields() {
        topTextField.defaultTextAttributes = EditorViewController.memeTextAttributes
        topTextField.textAlignment = .Center
        topTextField.delegate = self

        bottomTextField.defaultTextAttributes = EditorViewController.memeTextAttributes
        bottomTextField.textAlignment = .Center
        bottomTextField.delegate = self
    }
    
    private func showTextFields() {
        topTextField.hidden = false
        bottomTextField.hidden = false
    }
    
    private func hideTextFields() {
        topTextField.hidden = true
        bottomTextField.hidden = true
    }
    
    private func toggleShareButton() {
        shareButton.enabled = hasMemeToShare()
    }
    
    private func subscribeToKeyboardNotifications() {
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    private func unsubscribeFromKeyboardNotifications() {
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        notificationCenter.removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    private func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.CGRectValue().height
    }
    
}
