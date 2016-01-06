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
    
    override func viewDidLoad() {
        imageView.contentMode = .ScaleAspectFit
        shareButton.enabled = false
        cameraButton.enabled = isCameraAvailable()
        super.viewDidLoad()
    }
    
    @IBAction func pickAnImageFromLibrary(sender: UIBarButtonItem) {
        pickAnImage(.SavedPhotosAlbum)
    }
    
    @IBAction func pickAnImageFromCamera(sender: UIBarButtonItem) {
        guard isCameraAvailable() else {
            return
        }
        
        pickAnImage(.Camera)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.image = image
        } else {
            showError("Could not select a picture")
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    private func pickAnImage(sourceType: UIImagePickerControllerSourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = sourceType
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    private func isCameraAvailable() -> Bool {
       return UIImagePickerController.isSourceTypeAvailable(.Camera)
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
