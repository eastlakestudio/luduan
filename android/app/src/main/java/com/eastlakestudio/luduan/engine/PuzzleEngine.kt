package com.eastlakestudio.luduan.engine

import com.eastlakestudio.luduan.data.models.*

class PuzzleEngine(val level: LevelModel) {
    val tiles: List<String> = level.tileMatrix
    var selectedIndices: List<Int> = emptyList()
        private set
    var isCompleted: Boolean = false
        private set
    var highlightedTileIndex: Int? = null
        private set

    enum class CheckState { IDLE, SUCCESS, INCORRECT }
    var lastCheckState: CheckState = CheckState.IDLE
        private set

    val currentInput: String
        get() = selectedIndices.map { tiles[it] }.joinToString("")

    fun selectTile(at index: Int) {
        if (index !in tiles.indices) return
        if (selectedIndices.contains(index)) return
        if (selectedIndices.size >= level.targetPhrase.length) return
        selectedIndices = selectedIndices + index
        lastCheckState = CheckState.IDLE
        highlightedTileIndex = null
        if (selectedIndices.size == level.targetPhrase.length) checkAnswer()
    }

    fun unselectTile(at selectedOrderIndex: Int) {
        if (selectedOrderIndex !in selectedIndices.indices) return
        selectedIndices = selectedIndices.toMutableList().also { it.removeAt(selectedOrderIndex) }
        lastCheckState = CheckState.IDLE
        highlightedTileIndex = null
    }

    fun clearInput() {
        selectedIndices = emptyList()
        lastCheckState = CheckState.IDLE
        highlightedTileIndex = null
    }

    fun checkAnswer(): Boolean {
        if (currentInput == level.targetPhrase) {
            isCompleted = true
            lastCheckState = CheckState.SUCCESS
            return true
        } else {
            lastCheckState = CheckState.INCORRECT
            return false
        }
    }

    fun resetForNewLevel(newLevel: LevelModel) {
        // PuzzleEngine is per-level in the iOS version; Android recreates it
    }

    // 语音输入处理（含乱序容错）
    fun processVoiceInput(voiceText: String): Int {
        val cleanText = voiceText.filter { !it.isWhitespace() && !it.isPunctuation() }
        val chars = cleanText.map { it.toString() }
        val targetChars = level.targetPhrase.map { it.toString() }

        // 乱序容错：字符集合一致时按正确顺序选入
        if (chars.size == targetChars.size && chars.sorted() == targetChars.sorted()) {
            selectedIndices = emptyList()
            for (targetChar in targetChars) {
                val idx = tiles.indexOfFirst { it == targetChar && it !in selectedIndices.map { i -> tiles[i] } }
                if (idx >= 0 && idx !in selectedIndices) selectedIndices = selectedIndices + idx
            }
            if (selectedIndices.size == targetChars.size) checkAnswer()
            return selectedIndices.size
        }

        // 逐字匹配
        var count = 0
        for (charStr in chars) {
            if (selectedIndices.size >= level.targetPhrase.length) break
            val exactIdx = tiles.indexOfFirst { it == charStr && it !in selectedIndices.map { i -> tiles[i] } }
            if (exactIdx >= 0 && exactIdx !in selectedIndices) {
                selectedIndices = selectedIndices + exactIdx
                count++
            }
        }
        if (selectedIndices.size == level.targetPhrase.length) checkAnswer()
        return count
    }
}
