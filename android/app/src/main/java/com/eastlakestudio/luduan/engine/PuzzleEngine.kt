package com.eastlakestudio.luduan.engine
import androidx.compose.runtime.mutableStateListOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.getValue
import androidx.compose.runtime.setValue
import androidx.compose.runtime.snapshots.SnapshotStateList
import com.eastlakestudio.luduan.data.models.*

class PuzzleEngine(val level: LevelModel) {
    val tiles: List<String> = level.tileMatrix
    val selectedIndices: SnapshotStateList<Int> = mutableStateListOf()
    var isCompleted by mutableStateOf(false); private set
    var hintStage by mutableStateOf(0); private set
    var highlightedTileIndex by mutableStateOf<Int?>(null); private set
    enum class CheckState { IDLE, SUCCESS, INCORRECT }
    var lastCheckState by mutableStateOf(CheckState.IDLE); private set
    val currentInput: String get() = selectedIndices.map { tiles[it] }.joinToString("")

    fun selectTile(index: Int) {
        if (index !in tiles.indices || index in selectedIndices || selectedIndices.size >= level.targetPhrase.length) return
        selectedIndices.add(index); lastCheckState = CheckState.IDLE; highlightedTileIndex = null
        if (selectedIndices.size == level.targetPhrase.length) checkAnswer()
    }
    fun unselectTile(orderIndex: Int) {
        if (orderIndex in selectedIndices.indices) { selectedIndices.removeAt(orderIndex); lastCheckState = CheckState.IDLE }
    }
    fun clearInput() { selectedIndices.clear(); lastCheckState = CheckState.IDLE; highlightedTileIndex = null }
    fun checkAnswer(): Boolean {
        return if (currentInput == level.targetPhrase) { isCompleted = true; lastCheckState = CheckState.SUCCESS; true }
        else { lastCheckState = CheckState.INCORRECT; false }
    }
    fun provideHintProgressive(): Int {
        hintStage += 1; val tc = level.targetPhrase.map { it.toString() }
        if (hintStage >= 3) {
            selectedIndices.clear()
            for (c in tc) { val idx = tiles.indices.firstOrNull { i -> tiles[i] == c && i !in selectedIndices }; if (idx != null) selectedIndices.add(idx) }
            return tc.size
        }
        val cnt = minOf(hintStage, tc.size); selectedIndices.clear()
        for (i in 0 until cnt) { val idx = tiles.indices.firstOrNull { j -> tiles[j] == tc[i] && j !in selectedIndices }; if (idx != null) { selectedIndices.add(idx); highlightedTileIndex = idx } }
        return cnt
    }
}
