package com.eastlakestudio.luduan.data

import android.content.Context
import android.content.SharedPreferences
import android.util.Log
import com.eastlakestudio.luduan.data.models.*
import com.eastlakestudio.luduan.engine.LevelEngine
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.serialization.json.Json
import kotlinx.serialization.builtins.ListSerializer
import kotlinx.serialization.builtins.MapSerializer
import kotlinx.serialization.builtins.SetSerializer
import kotlinx.serialization.builtins.serializer
import java.io.File

class GameRepository private constructor(private val ctx: Context) {
    companion object {
        @Volatile private var I: GameRepository? = null
        fun get(c: Context): GameRepository = I ?: synchronized(this) { I ?: GameRepository(c.applicationContext).also { I = it } }
        private const val TAG = "LuDuanRepo"
    }

    private val prefs: SharedPreferences = ctx.getSharedPreferences("luduan", Context.MODE_PRIVATE)
    private val backupFile: File by lazy { File(ctx.filesDir, "progress.json") }
    private val json = Json { ignoreUnknownKeys = true }

    private val _phrases = MutableStateFlow<Set<String>>(emptySet()); val learnedPhrases: StateFlow<Set<String>> = _phrases
    private val _badges2 = MutableStateFlow<Set<String>>(emptySet()); val unlockedBadges: StateFlow<Set<String>> = _badges2
    val badges: List<BadgeModel> by lazy {
        try { json.decodeFromString(ListSerializer(BadgeModel.serializer()), ctx.assets.open("badges.json").bufferedReader().use { it.readText() }) }
        catch (e: Exception) { emptyList() }
    }
    private val jl: (String) -> String? = { n -> try { ctx.assets.open("seeds/$n.json").bufferedReader().use { it.readText() } } catch (e: Exception) { null } }

    // Issue 3: 每枚勋章分配不同的词池（不再用关卡区段，直接均分全部去重词）
    data class BadgeRange(val badge: BadgeModel, val uniquePhrases: Set<String>)
    val badgeRanges: Map<String, BadgeRange> by lazy { computeBadgeRanges() }

    init { loadFromStorage() }

    private fun loadFromStorage() {
        var phrases: Set<String>? = prefs.getStringSet("p", null)
        var badgeIds: Set<String>? = prefs.getStringSet("b", null)
        if (phrases == null && backupFile.exists()) {
            try {
                val data: Map<String, Set<String>> = json.decodeFromString(backupFile.readText())
                phrases = data["phrases"] ?: emptySet()
                badgeIds = data["badges"] ?: emptySet()
                Log.d(TAG, "restored from backup: ${phrases.size} phrases")
            } catch (e: Exception) { Log.e(TAG, "backup read failed", e) }
        }
        _phrases.value = phrases ?: emptySet()
        val validIds = badges.map { it.id }.toSet()
        _badges2.value = (badgeIds ?: emptySet()).intersect(validIds)
        Log.d(TAG, "loaded: ${_phrases.value.size} phrases, ${_badges2.value.size} badges")
    }

    private fun saveToStorage() {
        prefs.edit().putStringSet("p", HashSet(_phrases.value)).putStringSet("b", HashSet(_badges2.value)).commit()
        try {
            val data = mapOf("phrases" to _phrases.value, "badges" to _badges2.value)
            backupFile.writeText(json.encodeToString(MapSerializer(String.serializer(), SetSerializer(String.serializer())), data))
        } catch (e: Exception) { Log.e(TAG, "backup write failed", e) }
    }

    private fun computeBadgeRanges(): Map<String, BadgeRange> {
        val result = mutableMapOf<String, BadgeRange>()
        try {
            // 加载 words.json 建立索引→词语映射
            val wordsText = ctx.assets.open("seeds/words.json").bufferedReader().use { it.readText() }
            val wordsArr = org.json.JSONArray(wordsText)
            val idxToPhrase = mutableMapOf<Int, String>()
            for (i in 0 until wordsArr.length()) {
                val o = wordsArr.getJSONObject(i)
                idxToPhrase[o.getInt("idx")] = o.getString("phrase")
            }
            // 加载 badge_word_map.json（存的是索引）
            val mapText = ctx.assets.open("badge_word_map.json").bufferedReader().use { it.readText() }
            val rawMap = org.json.JSONObject(mapText)
            for (badge in badges) {
                val arr = rawMap.optJSONArray(badge.id)
                val phrases = if (arr != null) {
                    (0 until arr.length()).mapNotNull { idxToPhrase[arr.getInt(it)] }.toSet()
                } else emptySet()
                result[badge.id] = BadgeRange(badge, phrases)
            }
        } catch (e: Exception) {
            Log.e(TAG, "badge_word_map load failed", e)
            for (badge in badges) result[badge.id] = BadgeRange(badge, emptySet())
        }
        return result
    }

    fun level(index: Int, cn: String = ""): LevelModel = LevelEngine.level(index, jl, cn)

    fun completeLevel(l: LevelModel): String? {
        _phrases.value = _phrases.value + l.targetPhrase
        l.rewardBadgeId?.let { _badges2.value = _badges2.value + it }
        var newlyUnlocked: String? = null
        for ((bid, range) in badgeRanges) {
            if (bid in _badges2.value) continue
            if (range.uniquePhrases.isNotEmpty() && range.uniquePhrases.all { it in _phrases.value }) {
                _badges2.value = _badges2.value + bid
                newlyUnlocked = bid
            }
        }
        saveToStorage()
        return newlyUnlocked
    }

    fun isBadgeUnlocked(id: String) = id in _badges2.value

    fun badgeProgress(badgeId: String): Pair<Int, Int> {
        val range = badgeRanges[badgeId] ?: return Pair(0, 1)
        return Pair(range.uniquePhrases.count { it in _phrases.value }, range.uniquePhrases.size)
    }

    private var wordsCache: List<ClassicalSeedItem>? = null
    fun allWordsPublic(): List<ClassicalSeedItem> = allWords()
    private fun allWords(): List<ClassicalSeedItem> {
        wordsCache?.let { return it }
        val text = jl("words") ?: return emptyList()
        val items = LevelEngine.parseSeedsPublic(text)
        wordsCache = items
        return items
    }

    fun levelForBadge(badgeId: String, skipCompleted: Boolean = true): LevelModel? {
        val range = badgeRanges[badgeId] ?: return null
        val words = allWords()
        val phrases = range.uniquePhrases
        val categoryName = range.badge.name
        for (w in words) {
            if (w.phrase in phrases && (!skipCompleted || w.phrase !in _phrases.value)) {
                return LevelEngine.levelFromWord(w, categoryName, badgeId)
            }
        }
        // All completed, return first
        for (w in words) {
            if (w.phrase in phrases) return LevelEngine.levelFromWord(w, categoryName, badgeId)
        }
        return null
    }

    fun nextLevelForBadge(badgeId: String, currentPhrase: String): LevelModel? {
        val range = badgeRanges[badgeId] ?: return null
        val words = allWords()
        val phrases = range.uniquePhrases
        val categoryName = range.badge.name
        var foundCurrent = false
        for (w in words) {
            if (w.phrase in phrases) {
                if (foundCurrent && w.phrase !in _phrases.value) {
                    return LevelEngine.levelFromWord(w, categoryName, badgeId)
                }
                if (w.phrase == currentPhrase) foundCurrent = true
            }
        }
        // Wrap around
        return levelForBadge(badgeId, skipCompleted = true)
    }

    fun nextLevel(cur: LevelModel): LevelModel? {
        // If in a badge context, navigate within badge
        if (cur.badgeId != null) {
            return nextLevelForBadge(cur.badgeId, cur.targetPhrase)
        }
        val s = cur.id.removePrefix("level_").toIntOrNull()?.minus(1) ?: return null
        for (i in (s+1) until LevelEngine.TOTAL_LEVELS) { val l = level(index = i); if (l.targetPhrase !in _phrases.value) return l }
        for (i in 0 until LevelEngine.TOTAL_LEVELS) { val l = level(index = i); if (l.targetPhrase !in _phrases.value) return l }
        return level(index = 0)
    }
}
