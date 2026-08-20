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
    
    /// 生成 12 字 (3x4 矩阵) 包含目标成语与干扰字的随机乱序字块列表（确保 100% 无空白字符）
    public static func generate16TileMatrix(for level: LevelModel) -> [String] {
        let targetChars = Array(level.targetPhrase).filter { !$0.isWhitespace && !$0.isNewline && !$0.isPunctuation }.map { String($0) }
        var resultTiles = targetChars
        
        // 汇入 Level 预置字块（严格过滤空白与换行）
        for rawTile in level.tileMatrix {
            let tile = rawTile.trimmingCharacters(in: .whitespacesAndNewlines)
            if !tile.isEmpty && !resultTiles.contains(tile) {
                resultTiles.append(tile)
            }
            if resultTiles.count >= max(12, targetChars.count) { break }
        }
        
        // 若不足 12 字，补充经典汉字典故字符池
        let noisePool = ["汉", "楚", "秦", "歌", "兵", "天", "下", "风", "云", "图", "志", "文", "武", "诗", "书", "画", "史", "霸", "成", "败", "古", "今", "千", "秋"]
        for noise in noisePool.shuffled() {
            if resultTiles.count >= max(12, targetChars.count) { break }
            if !resultTiles.contains(noise) {
                resultTiles.append(noise)
            }
        }
        
        return Array(resultTiles.prefix(max(12, targetChars.count))).shuffled()
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
    
    /// 是否已提示读音（空槽位显示目标字拼音，不揭示汉字本身）
    @Published public private(set) var isPinyinHintRevealed: Bool = false
    
    /// 提示读音
    public func revealPinyinHint() {
        isPinyinHintRevealed = true
    }
    
    /// 重新载入新关卡（全量刷新 16 字乱序矩阵）
    public func resetForNewLevel(_ newLevel: LevelModel) {
        self.level = newLevel
        self.tiles = PuzzleEngine.generate16TileMatrix(for: newLevel)
        self.selectedIndices.removeAll()
        self.isCompleted = false
        self.highlightedTileIndex = nil
        self.lastCheckState = .idle
        self.hintStage = 0
        self.isPinyinHintRevealed = false
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
    
    /// 一键揭晓全句答案并完成解谜
    @discardableResult
    public func provideAllHints() -> Int {
        hintStage = 3
        let targetList = Array(level.targetPhrase).map { String($0) }
        
        selectedIndices.removeAll()
        for charStr in targetList {
            if let idx = tiles.enumerated().first(where: { (tIdx, tStr) in
                tStr == charStr && !selectedIndices.contains(tIdx)
            })?.offset {
                selectedIndices.append(idx)
            }
        }
        highlightedTileIndex = selectedIndices.last
        checkAnswer()
        return selectedIndices.count
    }
}
