//
//  ProfileViewController.swift
//  Reconnect
//
//  Created by Alexandra Negru on 03/01/2022.
//

import UIKit

class ProfileViewController: UIViewController {
    @IBOutlet weak var tabBarProfile: UITabBar!
    @IBOutlet weak var conversationsTab: UITabBarItem!
    @IBOutlet weak var calendarTab: UITabBarItem!
    
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var statusTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profilePicture.layer.cornerRadius = 25.0
        
        profilePicture.isUserInteractionEnabled = true
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapProfilePicture))
        profilePicture.addGestureRecognizer(gesture)
        // Do any additional setup after loading the view.
    }
    
    @objc private func didTapProfilePicture() {
        presentPhotoActionSheet()
    }

    @IBAction func saveProfileDetails(_ sender: UIButton) {
    }
}

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func presentPhotoActionSheet() {
        print("etwas")
        let actionSheet = UIAlertController(title: "Profile Picture", message: "How would you like to select a picture", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        actionSheet.addAction(UIAlertAction(title: "Take photo", style: .default, handler: { [weak self] _ in
            self?.presentCamera()
        }))
        actionSheet.addAction(UIAlertAction(title: "Choose photo", style: .default, handler: { [weak self] _ in
            self?.presentPhotoPicker()
        }))
        present(actionSheet, animated: true)
    }
    
    func presentCamera() {
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    func presentPhotoPicker() {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        
        profilePicture.image = selectedImage
    }
}
