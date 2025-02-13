////
////  MaskImageView.swift
////  Photo Editing App
////
////  Created by h-yang-24 on 2025/02/06.
////
//
//import SwiftUI
//import Vision
//import CoreImage
//import CoreImage.CIFilterBuiltins
//
//struct ContentView1: View {
//    @State private var processedImage: UIImage?
//
//    let inputImage = UIImage(named: "example")!
//
//    var body: some View {
//        VStack {
//            if let image = processedImage {
//                Image(uiImage: image)
//                    .resizable()
//                    .scaledToFit()
//            } else {
//                Text("处理中...")
//            }
//
//            Button("处理图片") {
//                processImage()
//            }
//            .padding()
//        }
//    }
//
//    func processImage() {
//        let ciImage = CIImage(image: inputImage)!
//        let request = VNGenerateForegroundInstanceMaskRequest()
//        
//        let requestHandler = VNImageRequestHandler(ciImage: ciImage, options: [:])
//
//        do {
//            try requestHandler.perform([request])
//            if let maskPixelBuffer = request.results?.first?.foregroundInstanceMask {
//                let maskImage = CIImage(cvPixelBuffer: maskPixelBuffer)
//                let finalImage = applyBlurAndCombine(ciImage, maskImage: maskImage)
//                processedImage = finalImage
//            }
//        } catch {
//            print("Error processing image: \(error)")
//        }
//    }
//
//    func applyBlurAndCombine(_ image: CIImage, maskImage: CIImage) -> UIImage {
//        let context = CIContext()
//        let filter = CIFilter.gaussianBlur()
//        filter.inputImage = image
//        filter.radius = 10 // 模糊程度
//
//        guard let blurredImage = filter.outputImage else { return UIImage(ciImage: image) }
//        
//        let blendFilter = CIFilter.blendWithMask()
//        blendFilter.inputImage = image
//        blendFilter.backgroundImage = blurredImage
//        blendFilter.maskImage = maskImage
//        
//        if let outputImage = blendFilter.outputImage,
//           let cgImage = context.createCGImage(outputImage, from: image.extent) {
//            return UIImage(cgImage: cgImage)
//        }
//        
//        return UIImage(ciImage: image)
//    }
//}
