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

class GameRepository private constructor(private val ctx: Context) {
    companion object {
        @Volatile private var I: GameRepository? = null
        fun get(c: Context): GameRepository = I ?: synchronized(this) { I ?: GameRepository(c.applicationContext).also { I = it } }
    }
    private val prefs: SharedPreferences = ctx.getSharedPreferences("luduan_progress", Context.MODE_PRIVATE)
    private val _phrases = MutableStateFlow<Set<String>>(emptySet()); val learnedPhrases: StateFlow<Set<String>> = _phrases
    private val _badges2 = MutableStateFlow<Set<String>>(emptySet()); val unlockedBadges: StateFlow<Set<String>> = _badges2
    val badges: List<BadgeModel> by lazy { try { Json { ignoreUnknownKeys = true }.decodeFromString(ListSerializer(BadgeModel.serializer()), ctx.assets.open("badges.json").bufferedReader().use { it.readText() }) } catch (e: Exception) { emptyList() } }
    private val jl: (String) -> String? = { n -> try { ctx.assets.open("seeds/$n.json").bufferedReader().use { it.readText() } } catch (e: Exception) { null } }
    init { _phrases.value = prefs.getStringSet("p", emptySet()) ?: emptySet(); _badges2.value = (prefs.getStringSet("b", emptySet()) ?: emptySet()).intersect(badges.map { it.id }.toSet()) }
    private fun save() { prefs.edit().putStringSet("p", _phrases.value).putStringSet("b", _badges2.value).apply() }
    fun level(index: Int, cn: String = ""): LevelModel = LevelEngine.level(index, jl, cn)
    fun isLevelCompleted(id: String): Boolean { val n = id.removePrefix("level_").toIntOrNull() ?: return false; return _phrases.value.contains(level(index = n - 1).targetPhrase) }
    fun completeLevel(l: LevelModel) { _phrases.value = _phrases.value + l.targetPhrase; l.rewardBadgeId?.let { _badges2.value = _badges2.value + it }; unlock(); save() }
    private fun unlock() {
        val c = _phrases.value.size; val g = badges.groupBy { BadgeCategory.from(it.category) }
        for ((_, cb) in g) { val s = cb.sortedBy { it.id }; val step = maxOf(1, 200 / maxOf(1, s.size)); for ((i, b) in s.withIndex()) { if (c >= (i+1)*step) _badges2.value = _badges2.value + b.id } }
    }
    fun isBadgeUnlocked(id: String) = id in _badges2.value
    fun nextLevel(cur: LevelModel): LevelModel? {
        val s = cur.id.removePrefix("level_").toIntOrNull()?.minus(1) ?: return null
        for (i in (s+1) until LevelEngine.TOTAL_LEVELS) { val l = level(index = i); if (l.targetPhrase !in _phrases.value) return l }
        for (i in 0 until LevelEngine.TOTAL_LEVELS) { val l = level(index = i); if (l.targetPhrase !in _phrases.value) return l }
        return level(index = 0)
    }
}
