//
//  ImagePicker.swift
//  Photo Editing App
//
//  Created by Burak Cüce on 04.07.22.
//

import UIKit
import SwiftUI

struct ImagePicker: UIViewControllerRepresentable {
    
    @Binding var showPicker: Bool
    @Binding var imageData: Data
    @Binding var maskImage: CIImage
    
    func makeCoordinator() -> Coordinator {
        return ImagePicker.Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        
        let controller = UIImagePickerController()
        controller.sourceType = .photoLibrary
        controller.delegate = context.coordinator
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        
        
    }
    
    class Coordinator: NSObject,UIImagePickerControllerDelegate,UINavigationControllerDelegate{

        var parent: ImagePicker
        
        init(parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.maskImage = CIImage(image: uiImage)!
                if let imageData = uiImage.pngData(){
                    parent.imageData = imageData
                    parent.showPicker.toggle()
                }
            }
//            if let imageData = (info[.originalImage] as? UIImage)?.pngData(){
//                
//            }
            
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {

            parent.showPicker.toggle()
        }
    }
}
