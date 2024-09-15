import UIKit
import Vision

class FaceRecognizer {
    var outputLayer: CALayer?

    func start(image: CGImage, orientation: CGImagePropertyOrientation) {
        // Create a request handler.
        let imageRequestHandler = VNImageRequestHandler(cgImage: image,
                                                        orientation: orientation,
                                                        options: [:])

        // TODO quere削除を試す
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self else { return }

            let request = VNDetectFaceLandmarksRequest(completionHandler: handleDetectedFaceLandmarks)
            do {
                try imageRequestHandler.perform([request])
            } catch let error as NSError {
                print("Failed to perform image request: \(error)")
            }
        }
    }

    private func handleDetectedFaceLandmarks(request: VNRequest?, error: Error?) {
        if let error {
            print(error)
            return
        }

        // Perform drawing on the main thread.
        DispatchQueue.main.async { [weak self] in
            guard let self, let results = request?.results as? [VNFaceObservation] else {
                return
            }
            drawFeatures(onFaces: results)
        }
    }

    private func drawFeatures(onFaces faces: [VNFaceObservation]) {
        guard let outputLayer else { return }

        let bounds = outputLayer.bounds

        CATransaction.begin()
        for faceObservation in faces {
            let faceBounds = boundingBox(forRegionOfInterest: faceObservation.boundingBox, withinImageBounds: bounds)
            guard let landmarks = faceObservation.landmarks else {
                continue
            }

            // Iterate through landmarks detected on the current face.
            let landmarkLayer = CAShapeLayer()
            let landmarkPath = CGMutablePath()
            let affineTransform = CGAffineTransform(scaleX: faceBounds.size.width, y: faceBounds.size.height)

            // Treat eyebrows and lines as open-ended regions when drawing paths.
            let openLandmarkRegions: [VNFaceLandmarkRegion2D?] = [
                landmarks.leftEyebrow,
                landmarks.rightEyebrow,
                landmarks.faceContour,
            ]

            // Draw eyes, lips, and nose as closed regions.
            let closedLandmarkRegions = [
                landmarks.leftEye,
                landmarks.rightEye,
                landmarks.outerLips,
                landmarks.nose
            ].compactMap { $0 } // Filter out missing regions.

            // Draw paths for the open regions.
            for openLandmarkRegion in openLandmarkRegions where openLandmarkRegion != nil {
                landmarkPath.addPoints(in: openLandmarkRegion!,
                                       applying: affineTransform,
                                       closingWhenComplete: false)
            }

            // Draw paths for the closed regions.
            for closedLandmarkRegion in closedLandmarkRegions {
                landmarkPath.addPoints(in: closedLandmarkRegion,
                                       applying: affineTransform,
                                       closingWhenComplete: true)
            }

            // Format the path's appearance: color, thickness, shadow.
            landmarkLayer.path = landmarkPath
            landmarkLayer.lineWidth = 2
            landmarkLayer.strokeColor = UIColor.green.cgColor
            landmarkLayer.fillColor = nil
            landmarkLayer.shadowOpacity = 0.75
            landmarkLayer.shadowRadius = 4

            // Locate the path in the parent coordinate system.
            landmarkLayer.anchorPoint = .zero
            landmarkLayer.frame = faceBounds
            landmarkLayer.transform = CATransform3DMakeScale(1, -1, 1)

            // Add to pathLayer on top of image.
            outputLayer.addSublayer(landmarkLayer)
        }
        CATransaction.commit()
        outputLayer.setNeedsDisplay()
    }


    private func boundingBox(forRegionOfInterest: CGRect, withinImageBounds bounds: CGRect) -> CGRect {
        let imageWidth = bounds.width
        let imageHeight = bounds.height

        // Begin with input rect.
        var rect = forRegionOfInterest

        // Reposition origin.
        rect.origin.x *= imageWidth
        rect.origin.x += bounds.origin.x
        rect.origin.y = (1 - rect.origin.y) * imageHeight + bounds.origin.y

        // Rescale normalized coordinates.
        rect.size.width *= imageWidth
        rect.size.height *= imageHeight

        return rect
    }
}

extension CGMutablePath {
    // Helper function to add lines to a path.
    func addPoints(in landmarkRegion: VNFaceLandmarkRegion2D,
                   applying affineTransform: CGAffineTransform,
                   closingWhenComplete closePath: Bool) {
        let pointCount = landmarkRegion.pointCount

        // Draw line if and only if path contains multiple points.
        guard pointCount > 1 else {
            return
        }
        self.addLines(between: landmarkRegion.normalizedPoints, transform: affineTransform)

        if closePath {
            self.closeSubpath()
        }
    }
}

