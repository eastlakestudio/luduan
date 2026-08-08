import Foundation

public final class PuzzleEngine: ObservableObject {
    @Published public private(set) var level: LevelModel
    
    /// 盘面字块矩阵
    @Published public private(set) var tiles: [String]
    
    /// 当前玩家已选字的索引列表（保持选字顺序）
    @Published public private(set) var selectedIndices: [Int] = []
    
    /// 是否已成功通关
    @Published public private(set) var isCompleted: Bool = false
    
    /// 提示高亮字块索引（乘黄灵感提示）
    @Published public private(set) var highlightedTileIndex: Int? = nil
    
    /// 上一次提交结果状态
    @Published public private(set) var lastCheckState: CheckState = .idle
    
    public enum CheckState: Equatable {
        case idle
        case success
        case incorrect
    }
    
    public init(level: LevelModel) {
        self.level = level
        self.tiles = PuzzleEngine.generate16TileMatrix(for: level)
    }
    
    /// 生成 16 字 (4x4 矩阵) 包含目标成语与干扰字的随机乱序字块列表
    public static func generate16TileMatrix(for level: LevelModel) -> [String] {
        let targetChars = Array(level.targetPhrase).map { String($0) }
        var resultTiles = targetChars
        
        // 汇入 Level 预置字块
        for tile in level.tileMatrix {
            if !resultTiles.contains(tile) {
                resultTiles.append(tile)
            }
            if resultTiles.count >= 16 { break }
        }
        
        // 若不足 16 字，补充经典汉字典故字符池
        let noisePool = ["汉", "楚", "秦", "歌", "兵", "天", "下", "风", "云", "图", "志", "文", "武", "诗", "书", "画", "史", "霸", "成", "败", "古", "今", "千", "秋"]
        for noise in noisePool.shuffled() {
            if resultTiles.count >= 16 { break }
            if !resultTiles.contains(noise) {
                resultTiles.append(noise)
            }
        }
        
        return Array(resultTiles.prefix(16)).shuffled()
    }
    
    /// 当前已拼出的候选字符串
    public var currentInput: String {
        return selectedIndices.map { tiles[$0] }.joined()
    }
    
    /// 目标短语字符数组
    public var targetChars: [Character] {
        return Array(level.targetPhrase)
    }
    
    /// 点击字块矩阵中的字
    public func selectTile(at index: Int) {
        guard index >= 0 && index < tiles.count else { return }
        // 避重复选择同一位置
        guard !selectedIndices.contains(index) else { return }
        // 不能超过目标字数
        guard selectedIndices.count < level.targetPhrase.count else { return }
        
        selectedIndices.append(index)
        lastCheckState = .idle
        highlightedTileIndex = nil
        
        // 如果刚好选够目标字数，自动校验
        if selectedIndices.count == level.targetPhrase.count {
            checkAnswer()
        }
    }
    
    /// 点击输入框中已选的字，取消选择
    public func unselectTile(at selectedOrderIndex: Int) {
        guard selectedOrderIndex >= 0 && selectedOrderIndex < selectedIndices.count else { return }
        selectedIndices.remove(at: selectedOrderIndex)
        lastCheckState = .idle
        highlightedTileIndex = nil
    }
    
    /// 提示阶段：0 为未提示，1 为已提示 1 个字，2 为已提示 2 个字，3 为已提示全部
    @Published public private(set) var hintStage: Int = 0
    
    /// 重新载入新关卡（全量刷新 16 字乱序矩阵）
    public func resetForNewLevel(_ newLevel: LevelModel) {
        self.level = newLevel
        self.tiles = PuzzleEngine.generate16TileMatrix(for: newLevel)
        self.selectedIndices.removeAll()
        self.isCompleted = false
        self.highlightedTileIndex = nil
        self.lastCheckState = .idle
        self.hintStage = 0
    }
    
    /// 一键清空已选字块
    public func clearInput() {
        selectedIndices.removeAll()
        lastCheckState = .idle
        highlightedTileIndex = nil
    }
    
    /// 校验答案
    @discardableResult
    public func checkAnswer() -> Bool {
        if currentInput == level.targetPhrase {
            isCompleted = true
            lastCheckState = .success
            return true
        } else {
            lastCheckState = .incorrect
            return false
        }
    }
    
    /// 渐进式灵感提示：
    /// 第 1 次：提示/填入 1 个正确字
    /// 第 2 次：提示/填入 2 个正确字
    /// 第 3 次及以后：填入全部正确字完成解谜
    @discardableResult
    public func provideHintProgressive() -> Int {
        hintStage += 1
        
        let targetList = Array(level.targetPhrase).map { String($0) }
        
        if hintStage >= 3 {
            // 提示全部正确字
            selectedIndices.removeAll()
            for charStr in targetList {
                if let idx = tiles.enumerated().first(where: { (tIdx, tStr) in
                    tStr == charStr && !selectedIndices.contains(tIdx)
                })?.offset {
                    selectedIndices.append(idx)
                }
            }
            checkAnswer()
            return targetList.count
        } else {
            // 每次提示新增下一个正确字块
            let targetCount = min(selectedIndices.count + 1, targetList.count)
            while selectedIndices.count < targetCount {
                let neededChar = targetList[selectedIndices.count]
                if let idx = tiles.enumerated().first(where: { (tIdx, tStr) in
                    tStr == neededChar && !selectedIndices.contains(tIdx)
                })?.offset {
                    selectedIndices.append(idx)
                    highlightedTileIndex = idx
                } else {
                    break
                }
            }
            if selectedIndices.count == targetList.count {
                checkAnswer()
            }
            return selectedIndices.count
        }
    }
    
    /// 兼容性提示方法
    @discardableResult
    public func provideHint() -> Int? {
        _ = provideHintProgressive()
        return highlightedTileIndex
    }
    
    /// 匹配并选择语音识别出的文字
    /// - Parameter voiceText: 语音识别转换出来的汉字字符串 (例："野火烧不尽")
    /// - Returns: 成功选入的字数
    @discardableResult
    public func processVoiceInputString(_ voiceText: String) -> Int {
        let cleanText = voiceText.filter { !$0.isWhitespace && !$0.isPunctuation }
        let chars = Array(cleanText).map { String($0) }
        
        var count = 0
        for charStr in chars {
            guard selectedIndices.count < level.targetPhrase.count else { break }
            
            // 优先 1：汉字字形 100% 精确匹配
            if let exactIdx = tiles.enumerated().first(where: { (tIdx, tStr) in
                !selectedIndices.contains(tIdx) && tStr == charStr
            })?.offset {
                selectedIndices.append(exactIdx)
                count += 1
                continue
            }
            
            // 降级 2：拼音读音高精度匹配（仅作用于目标成语相关字，解决同音字/多音字识别误差）
            if let pinyinIdx = tiles.enumerated().first(where: { (tIdx, tStr) in
                guard !selectedIndices.contains(tIdx) else { return false }
                let p1 = PinyinHelper.pinyinWithoutTone(for: tStr)
                let p2 = PinyinHelper.pinyinWithoutTone(for: charStr)
                guard !p1.isEmpty && p1 == p2 else { return false }
                
                return level.targetPhrase.contains(tStr) || level.targetPhrase.contains(where: {
                    PinyinHelper.pinyinWithoutTone(for: String($0)) == p1
                })
            })?.offset {
                selectedIndices.append(pinyinIdx)
                count += 1
            }
        }
        
        if selectedIndices.count == level.targetPhrase.count {
            checkAnswer()
        }
        
        return count
    }
}
