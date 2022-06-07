//
//  UIImage+Extension.swift
//
//  Created by Lazar Sidor on 25.03.2022.
//

import UIKit
import MobileCoreServices
import ObjectiveC
import UniformTypeIdentifiers

// MARK: - UIImage (Base64 Encoding)
public enum ImageFormat {
    case PNG
    case JPEG(CGFloat)
}

@available(iOS 10.0, *)
extension UIImage {
    public func imageWithColor(_ color: UIColor) -> UIImage? {
        var image = withRenderingMode(.alwaysTemplate)
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        color.set()
        image.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }

    public func base64(format: ImageFormat) -> String {
        var imageData: Data
        switch format {
        case .PNG:
            imageData = self.pngData()!
        case .JPEG(let compression): imageData = self.jpegData(compressionQuality: compression)!
        }
        return imageData.base64EncodedString()
    }

    public class func base64Convert(base64String: String?) -> UIImage? {
        if base64String?.isEmpty ?? true {
            return nil
        } else {
            let dataDecoded = Data(base64Encoded: base64String!, options: .ignoreUnknownCharacters)!
            let decodedimage = UIImage(data: dataDecoded)
            return decodedimage!
        }
    }

    @objc public func imageRotatedByDegrees(degrees: CGFloat, flip: Bool) -> UIImage {
        let _: (CGFloat) -> CGFloat = {
            return $0 * (180.0 / CGFloat.pi)
        }
        let degreesToRadians: (CGFloat) -> CGFloat = {
            return $0 / 180.0 * CGFloat.pi
        }

        // calculate the size of the rotated view's containing box for our drawing space
        let rotatedViewBox = UIView(frame: CGRect(origin: .zero, size: size))
        let transform = CGAffineTransform(rotationAngle: degreesToRadians(degrees))
        rotatedViewBox.transform = transform
        let rotatedSize = rotatedViewBox.frame.size

        // Create the bitmap context
        UIGraphicsBeginImageContext(rotatedSize)
        let bitmap = UIGraphicsGetCurrentContext()

        // Move the origin to the middle of the image so we will rotate and scale around the center.
        bitmap?.translateBy(x: rotatedSize.width / 2.0, y: rotatedSize.height / 2.0)

        //   // Rotate the image context
        bitmap?.rotate(by: degreesToRadians(degrees))

        // Now, draw the rotated/scaled image into the context
        var yFlip: CGFloat

        if flip {
            yFlip = CGFloat(-1.0)
        } else {
            yFlip = CGFloat(1.0)
        }

        bitmap?.scaleBy(x: yFlip, y: -1.0)
        let rect = CGRect(x: -size.width / 2, y: -size.height / 2, width: size.width, height: size.height)

        bitmap?.draw(cgImage!, in: rect)

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage!
    }

    @objc class func drawPDFfromURL(url: URL, printerDpi: CGFloat, page: Int) -> UIImage? {
        guard let document = CGPDFDocument(url as CFURL) else { return nil }
        guard let page = document.page(at: page) else { return nil }
        let dpi: CGFloat = printerDpi / 72.0
        let pageRect = page.getBoxRect(.mediaBox)

        let renderer = UIGraphicsImageRenderer(size: CGSize(width: pageRect.size.width * dpi, height: pageRect.size.height * dpi))

        let img1 = renderer.jpegData(withCompressionQuality: 1.0) { cnv in
            UIColor.white.set()
            cnv.fill(pageRect)
            cnv.cgContext.translateBy(x: 0.0, y: pageRect.size.height * dpi)
            cnv.cgContext.scaleBy(x: dpi, y: -dpi)
            cnv.cgContext.drawPDFPage(page)
        }
        let img2 = UIImage(data: img1)
        return img2
    }

    public func toJpegData(compressionQuality: CGFloat, hasAlpha: Bool = true, orientation: Int = 6) -> Data? {
        guard cgImage != nil else { return nil }
        let options: NSDictionary = [
            kCGImagePropertyOrientation: orientation,
            kCGImagePropertyHasAlpha: hasAlpha,
            kCGImageDestinationLossyCompressionQuality: compressionQuality
        ]
        return toData(options: options, type: .jpeg)
    }

    public func toData (options: NSDictionary, type: ImageType) -> Data? {
        guard cgImage != nil else { return nil }
        return toData(options: options, type: type.value)
    }

    // about properties: https://developer.apple.com/documentation/imageio/1464962-cgimagedestinationaddimage
    public func toData (options: NSDictionary, type: CFString) -> Data? {
        guard let cgImage = cgImage else { return nil }
        return autoreleasepool { () -> Data? in
            let data = NSMutableData()
            guard let imageDestination = CGImageDestinationCreateWithData(data as CFMutableData, type, 1, nil) else { return nil }
            CGImageDestinationAddImage(imageDestination, cgImage, options)
            CGImageDestinationFinalize(imageDestination)
            return data as Data
        }
    }

    // https://developer.apple.com/documentation/mobilecoreservices/uttype/uti_image_content_types
    public enum ImageType {
        case image // abstract image data
        case jpeg                       // JPEG image
        case jpeg2000                   // JPEG-2000 image
        case tiff                       // TIFF image
        case pict                       // Quickdraw PICT format
        case gif                        // GIF image
        case png                        // PNG image
        case quickTimeImage             // QuickTime image format (OSType 'qtif')
        case appleICNS                  // Apple icon data
        case bmp                        // Windows bitmap
        case ico                        // Windows icon data
        case rawImage                   // base type for raw image data (.raw)
        case scalableVectorGraphics     // SVG image
        case livePhoto                  // Live Photo

        public var value: CFString {
            switch self {
            case .image: return kUTTypeImage
            case .jpeg: return kUTTypeJPEG
            case .jpeg2000: return kUTTypeJPEG2000
            case .tiff: return kUTTypeTIFF
            case .pict: return kUTTypePICT
            case .gif: return kUTTypeGIF
            case .png: return kUTTypePNG
            case .quickTimeImage: return kUTTypeQuickTimeImage
            case .appleICNS: return kUTTypeAppleICNS
            case .bmp: return kUTTypeBMP
            case .ico: return kUTTypeICO
            case .rawImage: return kUTTypeRawImage
            case .scalableVectorGraphics: return kUTTypeScalableVectorGraphics
            case .livePhoto: return kUTTypeLivePhoto
            }
        }
    }
}

extension UIImage {
    public func resizeWithPercentage(_ percentage: CGFloat) -> UIImage? {
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: size.width * percentage, height: size.height * percentage)))
        imageView.contentMode = .scaleAspectFit
        imageView.image = self
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }

        imageView.layer.render(in: context)
        guard let result = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return result
    }

    public func scaleImage(with scaleFactor: CGFloat) -> UIImage? {
        // Compute the new image size that preserves aspect ratio
        let scaledImageSize = CGSize(
            width: size.width * scaleFactor,
            height: size.height * scaleFactor
        )

        // Draw and return the resized UIImage
        let renderer = UIGraphicsImageRenderer(
            size: scaledImageSize
        )

        let scaledImage = renderer.image { _ in
            self.draw(in: CGRect(
                origin: .zero,
                size: scaledImageSize
            ))
        }

        return scaledImage
    }

    public func scalePreservingAspectRatio(targetSize: CGSize) -> UIImage {
        // Determine the scale factor that preserves aspect ratio
        let widthRatio = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height

        let scaleFactor = min(widthRatio, heightRatio)

        // Compute the new image size that preserves aspect ratio
        let scaledImageSize = CGSize(
            width: size.width * scaleFactor,
            height: size.height * scaleFactor
        )

        // Draw and return the resized UIImage
        let renderer = UIGraphicsImageRenderer(
            size: scaledImageSize
        )

        let scaledImage = renderer.image { _ in
            self.draw(in: CGRect(
                origin: .zero,
                size: scaledImageSize
            ))
        }

        return scaledImage
    }

    public func resizeToFitMaximumMBMemorySize(_ maxSize: Double, imageInfo: [AnyHashable: Any], completion:@escaping ((_ outputImage: UIImage?) -> Void)) {
        let resizeBlock = { (_ originalSize: Double) in
            DispatchQueue.global().async {
                if originalSize <= maxSize {
                    DispatchQueue.main.async {
                        completion(self)
                    }
                    return
                }

                let percent = CGFloat(maxSize / originalSize)

                DispatchQueue.main.async {
                    if let resizedImage: UIImage = self.resizeWithPercentage(percent - 0.1) {
                        if let imgData = resizedImage.pngData() {
                            completion(UIImage(data: imgData as Data))
                        } else if let jpgData = resizedImage.jpegData(compressionQuality: 1.0) {
                            completion(UIImage(data: jpgData as Data))
                        } else {
                            completion(self)
                        }
                    } else {
                        completion(self)
                    }
                }
            }
        }

        DispatchQueue.global().async {
            if let fileUrl = imageInfo["PHImageFileURLKey"] {
                guard let data = NSData.init(contentsOf: fileUrl as! URL) else {
                    DispatchQueue.main.async {
                        completion(self)
                    }
                    return
                }

                let originalSize = Double(data.length) / Double(1024 * 1024)
                resizeBlock(originalSize)
            } else {
                let width: CGFloat = self.size.width
                var bytesPerRow = Int(4 * width)
                if bytesPerRow % 16 != 0 {
                    bytesPerRow = ((bytesPerRow / 16) + 1) * 16
                }
                let dataSize = self.cgImage!.height * self.cgImage!.bytesPerRow
                let originalSize = Double(dataSize) / Double(1024 * 1024)
                resizeBlock(originalSize)
            }
        }
    }

    public func compressTo(toSizeInMB size: Double, compressingValue: CGFloat, scale: CGFloat) -> UIImage? {
        let bytes = size * 1024 * 1024
        let sizeInBytes = Int(bytes)
        var needCompress = true
        var imgData: Data?
        var comp = compressingValue

        while needCompress {
            if let resizedImage = scaleImage(byMultiplicationFactorOf: compressingValue, scale: scale), let data: Data = resizedImage.jpegData(compressionQuality: compressingValue) {
                if data.count < sizeInBytes || comp < 0.001 {
                    needCompress = false
                    imgData = data
                } else {
                    comp = 0.0001
                }
            }
        }

        if let data = imgData {
            print("Finished with compression value of: \(compressingValue)")
            return UIImage(data: data)
        }
        return nil
    }

    private func scaleImage(byMultiplicationFactorOf factor: CGFloat, scale: CGFloat) -> UIImage? {
        let size = CGSize(width: self.size.width * factor, height: self.size.height * factor)
        UIGraphicsBeginImageContextWithOptions(size, true, scale)
        draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))

        if let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext() {
            UIGraphicsEndImageContext()
            return newImage
        }
        return nil
    }
}

extension UIImage {
    public func resizeImage(_ dimension: CGFloat, opaque: Bool, contentMode: UIView.ContentMode = .scaleAspectFit, scale: CGFloat) -> UIImage {
        var width: CGFloat
        var height: CGFloat
        var newImage: UIImage

        let size = self.size
        let aspectRatio = size.width / size.height

        switch contentMode {
        case .scaleAspectFit:
            if aspectRatio > 1 {                            // Landscape image
                width = dimension
                height = dimension / aspectRatio
            } else {                                        // Portrait image
                height = dimension
                width = dimension * aspectRatio
            }

        default:
            fatalError("UIIMage.resizeToFit(): FATAL: Unimplemented ContentMode")
        }

        if #available(iOS 10.0, *) {
            let renderFormat = UIGraphicsImageRendererFormat.default()
            renderFormat.opaque = opaque
            let renderer = UIGraphicsImageRenderer(size: CGSize(width: width, height: height), format: renderFormat)
            newImage = renderer.image { _ in
                self.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
            }
        } else {
            UIGraphicsBeginImageContextWithOptions(CGSize(width: width, height: height), opaque, scale)
            self.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
            newImage = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
        }

        return newImage
    }

    public func cropImageToSquare() -> UIImage? {
        var imageHeight = self.size.height
        var imageWidth = self.size.width

        if imageHeight > imageWidth {
            imageHeight = imageWidth
        }
        else {
            imageWidth = imageHeight
        }

        let size = CGSize(width: imageWidth, height: imageHeight)

        let refWidth = CGFloat(self.cgImage?.width ?? 0)
        let refHeight = CGFloat(self.cgImage?.height ?? 0)

        let x = (refWidth - size.width) / 2
        let y = (refHeight - size.height) / 2

        let cropRect = CGRect(x: x, y: y, width: size.width, height: size.height)
        if let imageRef = self.cgImage!.cropping(to: cropRect) {
            return UIImage(cgImage: imageRef, scale: UIScreen.main.scale, orientation: self.imageOrientation)
        }

       return nil
    }
}
