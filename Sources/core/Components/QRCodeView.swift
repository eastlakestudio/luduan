import SwiftUI
import CoreImage.CIFilterBuiltins
#if canImport(UIKit)
import UIKit
#endif

/// 原生 CoreImage 矢量高保真 App Store 动态二维码生成器
public struct QRCodeView: View {
    public let urlString: String
    
    public init(urlString: String = "https://apps.apple.com/us/app/%E7%94%AA%E7%AB%AF/id6799431765") {
        self.urlString = urlString
    }
    
    #if canImport(UIKit)
    private var qrCodeImage: UIImage? {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(urlString.utf8)
        filter.correctionLevel = "M"
        
        if let outputImage = filter.outputImage {
            let transform = CGAffineTransform(scaleX: 10, y: 10)
            let scaledImage = outputImage.transformed(by: transform)
            if let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) {
                return UIImage(cgImage: cgImage)
            }
        }
        return nil
    }
    #endif
    
    public var body: some View {
        #if canImport(UIKit)
        if let uiImage = qrCodeImage {
            Image(uiImage: uiImage)
                .interpolation(.none)
                .resizable()
                .scaledToFit()
        } else {
            fallbackView
        }
        #else
        fallbackView
        #endif
    }
    
    private var fallbackView: some View {
        Image(systemName: "qrcode")
            .font(.title)
            .foregroundColor(.cloudGold)
    }
}
