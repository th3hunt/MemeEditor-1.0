//
//  EditorViewController.swift
//  MemeEditor
//
//  Created by Stratos Pavlakis on 05/01/16.
//  Copyright © 2016 Stratos Pavlakis. All rights reserved.
//

import UIKit

class EditorViewController: UIViewController {

    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        shareButton.enabled = false
        cameraButton.enabled = self.isCameraAvailable()
    }
    
    
    private func isCameraAvailable() -> Bool {
       return UIImagePickerController.isSourceTypeAvailable(.Camera)
    }
    
}
