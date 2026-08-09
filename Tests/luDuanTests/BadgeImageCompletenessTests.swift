import XCTest
import Foundation
@testable import luDuanCore

final class BadgeImageCompletenessTests: XCTestCase {
    
    /// 验证所有【人物名将】分类的勋章其肖像图片覆盖率达到 100%
    func testCharacterBadgeImagesCompleteness() {
        let repo = GameDataRepository.shared
        let allBadges = repo.badges
        
        let charBadges = allBadges.filter { $0.category == .character }
        XCTAssertGreaterThanOrEqual(charBadges.count, 62, "人物名将勋章数量应不少于 62 个")
        
        var missingImages: [String] = []
        
        // 尝试从 Bundle 或物理磁盘查找 BadgeImages 目录
        let fileManager = FileManager.default
        let currentDirectory = fileManager.currentDirectoryPath
        let badgeImagesPath = (currentDirectory as NSString).appendingPathComponent("Sources/core/Resources/BadgeImages")
        
        for badge in charBadges {
            guard let imageName = badge.imageName, !imageName.isEmpty else {
                missingImages.append("\(badge.id) (\(badge.name)): imageName 字段缺失或为空")
                continue
            }
            
            // 方式 1: 检查 SPM / Bundle
            let existsInBundle: Bool
            if Bundle.module.path(forResource: imageName, ofType: "jpg") != nil ||
               Bundle.module.path(forResource: imageName, ofType: "png") != nil ||
               Bundle.module.path(forResource: imageName, ofType: "jpg", inDirectory: "BadgeImages") != nil ||
               Bundle.module.path(forResource: imageName, ofType: "png", inDirectory: "BadgeImages") != nil {
                existsInBundle = true
            } else {
                existsInBundle = false
            }
            
            // 方式 2: 检查工程物理磁盘 Sources/core/Resources/BadgeImages
            let jpgDiskPath = (badgeImagesPath as NSString).appendingPathComponent("\(imageName).jpg")
            let pngDiskPath = (badgeImagesPath as NSString).appendingPathComponent("\(imageName).png")
            let existsOnDisk = fileManager.fileExists(atPath: jpgDiskPath) || fileManager.fileExists(atPath: pngDiskPath)
            
            if !existsInBundle && !existsOnDisk {
                missingImages.append("\(badge.id) (\(badge.name)): 缺失肖像图片资源 '\(imageName)'")
            }
        }
        
        XCTAssertTrue(missingImages.isEmpty, "以下人物勋章缺失肖像图片资源:\n" + missingImages.joined(separator: "\n"))
    }
}
