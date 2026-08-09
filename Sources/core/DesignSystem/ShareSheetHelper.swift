import SwiftUI
#if canImport(UIKit)
import UIKit

/// 原生 iOS 分享面板封装 (用于微信、朋友圈、保存相册等)
public struct ShareSheetView: UIViewControllerRepresentable {
    public let activityItems: [Any]
    public let applicationActivities: [UIActivity]?
    
    public init(activityItems: [Any], applicationActivities: [UIActivity]? = nil) {
        self.activityItems = activityItems
        self.applicationActivities = applicationActivities
    }
    
    public func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: applicationActivities
        )
        return controller
    }
    
    public func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
#endif

public struct ShareSheetHelper {
    #if canImport(UIKit)
    @MainActor
    public static func renderViewToImage<V: View>(_ view: V, width: CGFloat = 390, height: CGFloat = 680) -> UIImage? {
        let renderer = ImageRenderer(content: view.frame(width: width, height: height))
        renderer.scale = 2
        return renderer.uiImage
    }
    #endif
    
    public static func share(items: [Any]) {
        #if canImport(UIKit)
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            return
        }
        // 找到最顶层正在展示的 VC（root 可能已经在 present fullScreenCover + sheet）
        var topVC = rootViewController
        while let presented = topVC.presentedViewController {
            topVC = presented
        }
        let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)

        // iPad popover 居中展示
        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = topVC.view
            popover.sourceRect = CGRect(x: topVC.view.bounds.midX, y: topVC.view.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }

        topVC.present(activityVC, animated: true)
        #endif
    }
}
