package com.eastlakestudio.luduan.data

import android.content.Context
import android.content.SharedPreferences
import androidx.security.crypto.EncryptedSharedPreferences
import androidx.security.crypto.MasterKey
import com.eastlakestudio.luduan.data.models.*
import com.eastlakestudio.luduan.engine.LevelEngine
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.serialization.json.Json
import kotlinx.serialization.builtins.ListSerializer

class GameRepository private constructor(private val context: Context) {

    companion object {
        @Volatile private var INSTANCE: GameRepository? = null
        fun get(context: Context): GameRepository = INSTANCE ?: synchronized(this) {
            INSTANCE ?: GameRepository(context.applicationContext).also { INSTANCE = it }
        }
        private const val PREFS_KEY = "luduan_progress"
        private const val KEY_LEARNED_PHRASES = "learnedPhrases"
        private const val KEY_UNLOCKED_BADGES = "unlockedBadges"
        private const val KEY_TOTAL_SCORE = "totalScore"
    }

    private val prefs: SharedPreferences by lazy {
        val masterKey = MasterKey.Builder(context).setKeyScheme(MasterKey.KeyScheme.AES256_GCM).build()
        EncryptedSharedPreferences.create(
            context, PREFS_KEY, masterKey,
            EncryptedSharedPreferences.PrefKeyEncryptionScheme.AES256_SIV,
            EncryptedSharedPreferences.PrefValueEncryptionScheme.AES256_GCM
        )
    }

    private val _learnedPhrases = MutableStateFlow<Set<String>>(emptySet())
    val learnedPhrases: StateFlow<Set<String>> = _learnedPhrases

    private val _unlockedBadges = MutableStateFlow<Set<String>>(emptySet())
    val unlockedBadges: StateFlow<Set<String>> = _unlockedBadges

    private val _totalScore = MutableStateFlow(0)
    val totalScore: StateFlow<Int> = _totalScore

    val badges: List<BadgeModel> by lazy { loadBadges() }

    // JSON loader for seed files
    private val jsonLoader: (String) -> String? = { name ->
        try {
            context.assets.open("seeds/$name.json").bufferedReader().use { it.readText() }
        } catch (e: Exception) { null }
    }

    init {
        loadProgress()
    }

    private fun loadProgress() {
        _learnedPhrases.value = prefs.getStringSet(KEY_LEARNED_PHRASES, emptySet()) ?: emptySet()
        _unlockedBadges.value = prefs.getStringSet(KEY_UNLOCKED_BADGES, emptySet()) ?: emptySet()
        _totalScore.value = prefs.getInt(KEY_TOTAL_SCORE, 0)
        // 清理废弃勋章 ID
        val validIds = badges.map { it.id }.toSet()
        _unlockedBadges.value = _unlockedBadges.value.intersect(validIds)
    }

    private fun saveProgress() {
        prefs.edit()
            .putStringSet(KEY_LEARNED_PHRASES, _learnedPhrases.value)
            .putStringSet(KEY_UNLOCKED_BADGES, _unlockedBadges.value)
            .putInt(KEY_TOTAL_SCORE, _totalScore.value)
            .apply()
    }

    private fun loadBadges(): List<BadgeModel> {
        return try {
            val json = context.assets.open("badges.json").bufferedReader().use { it.readText() }
            Json { ignoreUnknownKeys = true }.decodeFromString(ListSerializer(BadgeModel.serializer()), json)
        } catch (e: Exception) {
            emptyList()
        }
    }

    // === 关卡逻辑 ===

    fun level(at index: Int, categoryName: String = ""): LevelModel =
        LevelEngine.level(at, jsonLoader, categoryName)

    fun isLevelCompleted(levelId: String): Boolean {
        if (levelId.startsWith("level_")) {
            val n = levelId.removePrefix("level_").toIntOrNull()
            if (n != null) {
                val phrase = level(at = n - 1).targetPhrase
                if (_learnedPhrases.value.contains(phrase)) return true
            }
        }
        return false
    }

    fun completeLevel(level: LevelModel) {
        _learnedPhrases.value = _learnedPhrases.value + level.targetPhrase
        _totalScore.value = _totalScore.value + 10
        level.rewardBadgeId?.let { _unlockedBadges.value = _unlockedBadges.value + it }
        unlockMilestoneBadges()
        saveProgress()
    }

    private fun unlockMilestoneBadges() {
        val count = _learnedPhrases.value.size
        val grouped = badges.groupBy { BadgeCategory.from(it.category) }
        for ((_, catBadges) in grouped) {
            val sorted = catBadges.sortedBy { it.id }
            val step = maxOf(1, 200 / maxOf(1, sorted.size))
            for ((i, badge) in sorted.withIndex()) {
                if (count >= (i + 1) * step) {
                    _unlockedBadges.value = _unlockedBadges.value + badge.id
                }
            }
        }
    }

    fun isBadgeUnlocked(badgeId: String): Boolean = _unlockedBadges.value.contains(badgeId)

    fun nextLevel(after current: LevelModel): LevelModel? {
        val startIdx = current.id.removePrefix("level_").toIntOrNull()?.minus(1) ?: return null
        for (i in (startIdx + 1) until LevelEngine.TOTAL_LEVELS) {
            val candidate = level(at = i)
            if (candidate.targetPhrase !in _learnedPhrases.value) return candidate
        }
        // 从头搜
        for (i in 0 until LevelEngine.TOTAL_LEVELS) {
            val candidate = level(at = i)
            if (candidate.targetPhrase !in _learnedPhrases.value) return candidate
        }
        return level(at = 0)
    }
}
