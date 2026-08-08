import SwiftUI
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

#if canImport(UIKit)
public typealias FireworksPlatformImage = UIImage
#elseif canImport(AppKit)
public typealias FireworksPlatformImage = NSImage
#endif

public struct FireworksStyle {
    public let name: String
    public let imageName: String
    public let burstCount: Int
    public let totalDuration: Double

    public static var styles: [FireworksStyle] {
        [
            .init(name: "金榜绽放", imageName: "fw_01", burstCount: 4, totalDuration: 1.8),
            .init(name: "朱砂红雨", imageName: "fw_02", burstCount: 4, totalDuration: 1.8),
            .init(name: "翠竹光环", imageName: "fw_03", burstCount: 5, totalDuration: 1.7),
            .init(name: "玉宇双层", imageName: "fw_04", burstCount: 4, totalDuration: 1.8),
            .init(name: "紫气菊花", imageName: "fw_05", burstCount: 4, totalDuration: 1.8),
            .init(name: "满堂富贵", imageName: "fw_06", burstCount: 5, totalDuration: 2.0),
            .init(name: "金菊绽放", imageName: "fw_07", burstCount: 4, totalDuration: 1.8),
            .init(name: "朱砂光环", imageName: "fw_08", burstCount: 5, totalDuration: 1.7),
            .init(name: "翠竹垂柳", imageName: "fw_09", burstCount: 4, totalDuration: 1.9),
            .init(name: "碧海繁星", imageName: "fw_10", burstCount: 4, totalDuration: 1.8),
            .init(name: "紫气光环", imageName: "fw_11", burstCount: 5, totalDuration: 1.7),
            .init(name: "万紫千红", imageName: "fw_12", burstCount: 5, totalDuration: 2.0)
        ]
    }

    public static func random() -> FireworksStyle {
        styles.randomElement() ?? styles[0]
    }
}

enum FireworksImageCache {
    private static var cache: [String: FireworksPlatformImage] = [:]

    static func image(_ name: String) -> FireworksPlatformImage? {
        if let cached = cache[name] { return cached }
        let loaded = load(name)
        if let loaded { cache[name] = loaded }
        return loaded
    }

    private static func load(_ name: String) -> FireworksPlatformImage? {
        let url = Bundle.module.url(forResource: name, withExtension: "png")
            ?? Bundle.module.url(forResource: name, withExtension: "png", subdirectory: "Fireworks")
        guard let url, let data = try? Data(contentsOf: url) else { return nil }
        #if canImport(UIKit)
        return UIImage(data: data)
        #else
        return NSImage(data: data)
        #endif
    }
}

public struct FireworksShow {
    public struct Shot {
        public let image: FireworksPlatformImage?
        public let posX: CGFloat
        public let posY: CGFloat
        public let scaleStart: CGFloat
        public let scaleEnd: CGFloat
        public let rotation: Double
        public let startDelay: Double
        public let duration: Double
        public let baseSize: CGFloat
    }

    public let style: FireworksStyle
    public let shots: [Shot]
    public let startTime: TimeInterval

    public init(style: FireworksStyle) {
        self.style = style
        self.startTime = Date().timeIntervalSinceReferenceDate
        var rng = SystemRandomNumberGenerator()
        let n = style.burstCount
        let stagger = min(0.4, style.totalDuration / Double(n + 1))
        var generated: [Shot] = []
        for i in 0..<n {
            generated.append(Shot(
                image: FireworksImageCache.image(style.imageName),
                posX: CGFloat.random(in: 0.2...0.8, using: &rng),
                posY: CGFloat.random(in: 0.18...0.55, using: &rng),
                scaleStart: CGFloat.random(in: 0.25...0.4, using: &rng),
                scaleEnd: CGFloat.random(in: 1.0...1.45, using: &rng),
                rotation: Double.random(in: 0...360, using: &rng),
                startDelay: Double(i) * stagger,
                duration: Double.random(in: 0.9...1.2, using: &rng),
                baseSize: CGFloat.random(in: 200...280, using: &rng)
            ))
        }
        self.shots = generated
    }
}

public struct FireworksCelebrationView: View {
    public let show: FireworksShow

    public init(show: FireworksShow) {
        self.show = show
    }

    public var body: some View {
        GeometryReader { geo in
            TimelineView(.animation) { timeline in
                let elapsed = timeline.date.timeIntervalSinceReferenceDate - show.startTime
                ZStack {
                    ForEach(show.shots.indices, id: \.self) { i in
                        shotView(show.shots[i], elapsed: elapsed, size: geo.size)
                    }
                }
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }

    @ViewBuilder
    private func shotView(_ shot: FireworksShow.Shot, elapsed: Double, size: CGSize) -> some View {
        let p = (elapsed - shot.startDelay) / shot.duration
        if p > 0 && p < 1, let image = shot.image {
            let eased = 1 - (1 - p) * (1 - p)
            let scale = shot.scaleStart + (shot.scaleEnd - shot.scaleStart) * eased
            let opacity = p < 0.12 ? (p / 0.12) : (1 - (p - 0.12) / 0.88)
            let rot = shot.rotation + p * 30
            platformImage(image)
                .frame(width: shot.baseSize, height: shot.baseSize)
                .opacity(max(0, opacity))
                .scaleEffect(scale)
                .rotationEffect(.degrees(rot))
                .position(x: shot.posX * size.width, y: shot.posY * size.height)
        }
    }

    @ViewBuilder
    private func platformImage(_ image: FireworksPlatformImage) -> some View {
        #if canImport(UIKit)
        Image(uiImage: image).resizable().scaledToFit()
        #else
        Image(nsImage: image).resizable().scaledToFit()
        #endif
    }
}
