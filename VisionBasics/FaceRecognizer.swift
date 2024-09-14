import Foundation
import Vision

class FaceRecognizer {
//    lazy var faceLandmarkRequest = VNDetectFaceLandmarksRequest(completionHandler: self.handleDetectedFaceLandmarks)

//    func performVisionRequest(image: CGImage, orientation: CGImagePropertyOrientation) {
//        // Create a request handler.
//        let imageRequestHandler = VNImageRequestHandler(cgImage: image,
//                                                        orientation: orientation,
//                                                        options: [:])
//
//        // Send the requests to the request handler.
//        DispatchQueue.global(qos: .userInitiated).async {
//            do {
//                try imageRequestHandler.perform([faceLandmarkRequest])
//            } catch let error as NSError {
//                print("Failed to perform image request: \(error)")
//                self.presentAlert("Image Request Failed", error: error)
//                return
//            }
//        }
//    }
//
//    fileprivate func handleDetectedFaceLandmarks(request: VNRequest?, error: Error?) {
//        if let nsError = error as NSError? {
//            self.presentAlert("Face Landmark Detection Error", error: nsError)
//            return
//        }
//
//        // Perform drawing on the main thread.
//        DispatchQueue.main.async {
//            guard let drawLayer = self.pathLayer,
//                let results = request?.results as? [VNFaceObservation] else {
//                    return
//            }
//            self.drawFeatures(onFaces: results, onImageWithBounds: drawLayer.bounds)
//            drawLayer.setNeedsDisplay()
//        }
//    }
}
