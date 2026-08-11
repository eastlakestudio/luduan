package com.eastlakestudio.luduan.engine
import com.eastlakestudio.luduan.data.models.*
import org.json.JSONArray

object LevelEngine {
    const val TOTAL_LEVELS = 10000
    private val seedFiles = listOf("words")
    private val seedsCache = mutableMapOf<String, List<ClassicalSeedItem>>()
    private val allSeeds: List<ClassicalSeedItem> get() = seedFiles.flatMap { loadSeeds(it) }
    private fun loadSeeds(name: String): List<ClassicalSeedItem> = seedsCache.getOrPut(name) { emptyList() }
    fun loadSeeds(name: String, jsonLoader: (String) -> String?): List<ClassicalSeedItem> {
        seedsCache[name]?.let { return it }
        val json = jsonLoader(name) ?: return emptyList()
        val items = parseSeeds(json)
        if (items.isNotEmpty()) seedsCache[name] = items
        return items
    }
    private fun allSeedsDynamic(jsonLoader: (String) -> String?): List<ClassicalSeedItem> = seedFiles.flatMap { loadSeeds(it, jsonLoader) }
    private fun parseSeeds(json: String): List<ClassicalSeedItem> = try {
        val arr = JSONArray(json)
        (0 until arr.length()).map { i -> val o = arr.getJSONObject(i)
            ClassicalSeedItem(o.getString("phrase"), o.getString("annotation"), o.getString("story"), o.getString("source")) }
    } catch (e: Exception) { emptyList() }

    fun level(index: Int, jsonLoader: (String) -> String?, categoryName: String = ""): LevelModel {
        val si = index.coerceIn(0, TOTAL_LEVELS - 1); val ln = si + 1
        val seeds = allSeedsDynamic(jsonLoader)
        val seed = seeds.getOrElse(si) { seeds[si % maxOf(1, seeds.size)] }
        val theme = CultureTheme.SHIJING
        return LevelModel("level_$ln", theme, "第 $ln 关", categoryName, seed.phrase,
            genTiles(seed.phrase, si), seed.annotation, seed.story, seed.source)
    }
    fun parseSeedsPublic(json: String): List<ClassicalSeedItem> = parseSeeds(json)

    fun levelFromWord(seed: ClassicalSeedItem, categoryName: String, badgeId: String? = null): LevelModel {
        val si = (seed.phrase.hashCode() and 0x7fffffff)
        return LevelModel("badge_word_$si", CultureTheme.SHIJING, categoryName, categoryName,
            seed.phrase, genTiles(seed.phrase, si), seed.annotation, seed.story, seed.source, null, badgeId)
    }

    private val pool = listOf(
        "天","地","人","心","上","下","不","一","大","小","中","分","生","年","道","说",
        "子","水","火","木","金","土","日","月","星","山","河","海","云","雨","风","雪",
        "春","夏","秋","冬","花","草","树","石","龙","凤","虎","鹤","马","牛","羊","鱼",
        "诗","书","画","剑","琴","棋","茶","酒","梦","情","义","信","德","善","美","真",
        "行","知","思","言","声","色","光","影","空","满","开","落","飞","远","近","高",
        "白","青","红","黑","黄","紫","翠","碧","苍","丹","朱","素","彩","辉","灿","霞",
        "朝","暮","晨","夕","岁","时","今","古","先","后","始","终","来","去","起","伏",
        "国","家","城","门","路","桥","船","车","钟","鼓","旗","弓","刀","枪","盾","甲"
    )
    private fun genTiles(phrase: String, si: Int): List<String> {
        val r = phrase.map { it.toString() }.toMutableList()
        val t = maxOf(16, r.size + 4)
        val phraseSet = r.toSet()
        var s = si * 997 + 13
        fun rng(): Int { s = (s * 1103515245 + 12345) and 0x7fffffff; return s }
        while (r.size < t) {
            val c = pool[rng() % pool.size]
            if (c !in phraseSet && c !in r) { r.add(c); phraseSet.plus(c) }
        }
        for (i in r.size - 1 downTo 1) { val j = rng() % (i + 1); val tmp = r[i]; r[i] = r[j]; r[j] = tmp }
        return r
    }
}
