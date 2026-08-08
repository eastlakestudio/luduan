import Foundation
import SwiftUI
#if canImport(AudioToolbox)
import AudioToolbox
#endif
#if canImport(UIKit)
import UIKit
#endif

/// 跨平台游戏音效与触觉反馈管理器
public final class SoundManager {
    public static let shared = SoundManager()
    
    private init() {}
    
    /// 播放通关成功音效与触觉震动
    public func playSuccessSound() {
        #if canImport(AudioToolbox)
        // System Sound 1054: Heroic Chime / Fanfare
        AudioServicesPlaySystemSound(1054)
        #endif
        
        #if canImport(UIKit)
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        #endif
    }
    
    /// 播放解谜失败音效与错误震动
    public func playFailureSound() {
        #if canImport(AudioToolbox)
        // System Sound 1053: Error Buzzer / Thud
        AudioServicesPlaySystemSound(1053)
        #endif
        
        #if canImport(UIKit)
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
        #endif
    }
    
    /// 播放选字点击音效与轻触震动
    public func playTapSound() {
        #if canImport(AudioToolbox)
        // System Sound 1104: Crisp Tap
        AudioServicesPlaySystemSound(1104)
        #endif
        
        #if canImport(UIKit)
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        #endif
    }
}
