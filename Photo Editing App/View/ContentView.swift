//
//  ContentView.swift
//  Photo Editing App
//
//  Created by Burak Cüce on 02.07.22.
//

import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins
import PencilKit
import Vision

struct ContentView: View {
    
    @State private var showImagePicker : Bool = false
    @State private var image : Image? = nil
    @State private var showCameraPicker : Bool = false
    
    @State private var blurAmount = 0.0
    @State private var sepiaAmount = 0.0
    
    //@State private var inputImage: UIImage?
    
    @State private var resImage: UIImage?
    @State private var maskImage: CIImage?
    @State private var blurRadius: Float = 0.0
    
    @State private var currentFilter = CIFilter.sepiaTone()
    let context = CIContext()
    
    @StateObject var model = DrawingViewModel()
    @ObservedObject var camera = CameraModel()
    
    var body: some View {
        ZStack {
            NavigationView {
                VStack {
                    if let pickImage = UIImage(data: model.imageData) {
                        //Spacer()
                        
//                        DrawingScreen()
//                            .environmentObject(model)
//                            .blur(radius: blurAmount)
//                        
//                            .toolbar {
//                                ToolbarItem(placement: .navigationBarLeading) {
//                                    Button {
//                                        model.cancelImageEditing()
//                                    } label: {
//                                        Image(systemName: "xmark")
//                                    }
//                                }
//                            }
                        VStack {
                            if let uiImage = resImage {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFit()
                            } else {
                                Image(uiImage: pickImage)
                                    .resizable()
                                    .scaledToFit()
                            }
                            
                            Button("Edit Background") {
                                processImage(inputImage: pickImage)
                            }
                            .padding()
                            
                            Slider(value: $blurRadius, in: 0...100) { _ in
                                applyBlurAndCombine(pickImage, maskImage: self.maskImage ?? model.maskImage, radius: blurRadius)
                            }
                            .padding()
                            Spacer()
//                            HStack {
//                                Text("Blur")
//                                Slider(value: $blurAmount, in: 0...10)
//
//                                Button(action: actionSheet) {
//                                    Image(systemName: "square.and.arrow.up")
//                                        .resizable()
//                                        .aspectRatio(contentMode: .fit)
//                                        .frame(width: 36, height: 36)
//                                }
//                            }
//                            .padding(.horizontal)
                        }
                        .toolbar {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button(action: model.saveImage, label: {
                                    Text("Save")
                                })
                            }
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button {
                                    model.textBoxes.append(TextBox())
                                    model.currentIndex = model.textBoxes.count - 1
                                    withAnimation {
                                        model.addNewBox.toggle()
                                    }
                                    model.toolPicker.setVisible(false, forFirstResponder: model.canvas)
                                    model.canvas.resignFirstResponder()
                                } label: {
                                    Image(systemName: "plus")
                                }
                            }
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button {
                                    model.cancelImageEditing()
                                } label: {
                                    Image(systemName: "xmark")
                                }
                            }
                        }
                    } else {
                        Button {
                            model.showImagePicker.toggle()
                        } label: {
                            Image(systemName: "photo.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 200, height: 200, alignment: .center)
                        }
                    }
                }
                .navigationTitle("Photo edit")
                .navigationBarItems(trailing:
                                        Button {
                    self.showCameraPicker = true
                } label: {
                    Image(systemName: "camera.circle")
                        .resizable()
                        .renderingMode(.original)
                        .foregroundColor(Color(red: 4 / 255, green: 150 / 255, blue: 255 / 255))
                        .frame(width: 35, height: 35)
                        .cornerRadius(10)
                })
                .sheet(isPresented: self.$showCameraPicker) {
                    CameraView()
                }
            }
            
            if model.addNewBox {
                
                Color.black.opacity(0.75)
                    .ignoresSafeArea()
                
                TextField("Tap here", text: $model.textBoxes[model.currentIndex].text)
                    .font(.system(size: 35))
                    .colorScheme(.dark)
                    .foregroundColor(model.textBoxes[model.currentIndex].textColor)
                    .padding()
                
                HStack {
                    Button {
                        model.toolPicker.setVisible(true, forFirstResponder: model.canvas)
                        model.canvas.becomeFirstResponder()
                        
                        withAnimation {
                            model.addNewBox = false
                        }
                    } label: {
                        Text("Add")
                            .fontWeight(.heavy)
                            .foregroundColor(.white)
                            .padding()
                    }
                    Spacer()
                    
                    Button {
                        model.cancelTextView()
                    } label: {
                        Text("Cancel")
                            .fontWeight(.heavy)
                            .foregroundColor(.white)
                            .padding()
                    }
                }
                .overlay(
                    HStack(spacing: 15){
                        
                        // Color Picker...
                        ColorPicker("", selection: $model.textBoxes[model.currentIndex].textColor)
                            .labelsHidden()
                        
                        Button(action: {
                            model.textBoxes[model.currentIndex].isBold.toggle()
                        }, label: {
                            Text(model.textBoxes[model.currentIndex].isBold ? "Normal" : "Bold")
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        })
                    }
                )
                .frame(maxHeight: .infinity, alignment: .top)
            }
        }
        .sheet(isPresented: $model.showImagePicker, content: {
            ImagePicker(showPicker: $model.showImagePicker, imageData: $model.imageData, maskImage: $model.maskImage)
        })
        .alert(isPresented: $model.showAlert, content: {
            Alert(title: Text("Alert"), message: Text(model.message), dismissButton: .destructive(Text("Ok")))
        })
        .onReceive(model.$imageData) { newValue in
            if let uiImage = UIImage(data: newValue) {
                resImage = uiImage
            }
        }
    }
    func actionSheet() {
       guard let urlShare = URL(string: "https://facebook.com") else { return }
       let activityVC = UIActivityViewController(activityItems: [urlShare], applicationActivities: nil)
       UIApplication.shared.windows.first?.rootViewController?.present(activityVC, animated: true, completion: nil)
    }
    func processImage(inputImage: UIImage) -> CIImage? {
        let ciImage = CIImage(image: inputImage)!
        let request = VNGenerateForegroundInstanceMaskRequest()
        
        let requestHandler = VNImageRequestHandler(ciImage: ciImage, options: [:])
        //return ciImage

        do {
            try requestHandler.perform([request])
            print("requestHandler perform request")
            if let result = request.results?.first {
                print("Get request.results?.first")
                let maskPixelBuffer = try result.generateScaledMaskForImage(forInstances: result.allInstances, from: requestHandler)
                //let maskPixelBuffer = try result.globalSegmentationMask?.pixelBuffer
//                return CIImage(cvPixelBuffer: mask)
//            }
//            if let maskPixelBuffer = request.results?.first?.generateScaledMaskForImage(forInstances: .allInstances, from: requestHandler) {
                print("try result.generateScaledMaskForImage")
                maskImage = CIImage(cvPixelBuffer: maskPixelBuffer)
                
//                let finalImage = applyBlurAndCombine(ciImage, maskImage: maskImage)
//                return finalImage
                //processedImage = finalImage
            } else {return nil}
        } catch {
            print("Error processing image: \(error)")
        }
        return nil
    }

    func applyBlurAndCombine(_ uiImage: UIImage, maskImage: CIImage, radius: Float) -> UIImage {
        let context = CIContext()
        let filter = CIFilter.gaussianBlur()
        let image = CIImage(image: uiImage)!
        filter.inputImage = image
        filter.radius = radius

        guard let blurredImage = filter.outputImage else { return UIImage(ciImage: image) }
        
        let blendFilter = CIFilter.blendWithMask()
        blendFilter.inputImage = image
        blendFilter.backgroundImage = blurredImage
        blendFilter.maskImage = maskImage
        
        if let outputImage = blendFilter.outputImage,
           let cgImage = context.createCGImage(outputImage, from: image.extent) {
            resImage = UIImage(cgImage: cgImage, scale: uiImage.scale, orientation: uiImage.imageOrientation)
            return UIImage(cgImage: cgImage)
        }
        resImage = UIImage(ciImage: image)
        return UIImage(ciImage: image)
    }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
