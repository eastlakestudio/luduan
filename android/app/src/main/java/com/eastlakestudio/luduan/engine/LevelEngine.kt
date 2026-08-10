package com.eastlakestudio.luduan.engine
import com.eastlakestudio.luduan.data.models.*
import org.json.JSONArray

object LevelEngine {
    const val TOTAL_LEVELS = 10000
    private val seedFiles = listOf("shihan","shijing","tangsong","lunyu","daodejing","mengzi","zhongyong","guoyu","chunqiu","yanshijiaxun","chuanxilu","caigentan","rizhilu","xiaochuangyouji","zengguofanjiashu","xiyouji","hongloumeng")
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
        val theme: CultureTheme; val seed: ClassicalSeedItem
        if (si < 2500) { theme = CultureTheme.SHIJING
            val items = listOf("shijing","lunyu","daodejing","mengzi","zhongyong","guoyu","chunqiu").flatMap { loadSeeds(it, jsonLoader) }
            seed = items.getOrElse(si % items.size) { allSeedsDynamic(jsonLoader)[si % allSeedsDynamic(jsonLoader).size] }
        } else if (si < 5500) { theme = CultureTheme.SHIHAN
            val items = loadSeeds("shihan", jsonLoader)
            seed = items.getOrElse((si-2500) % items.size) { allSeedsDynamic(jsonLoader)[si % allSeedsDynamic(jsonLoader).size] }
        } else if (si < 7000) { theme = CultureTheme.SHIHAN
            val items = loadSeeds("yanshijiaxun", jsonLoader) + loadSeeds("shihan", jsonLoader)
            seed = items.getOrElse((si-5500) % items.size) { allSeedsDynamic(jsonLoader)[si % allSeedsDynamic(jsonLoader).size] }
        } else if (si < 8800) { theme = CultureTheme.TANGSONG
            val items = loadSeeds("tangsong", jsonLoader)
            seed = items.getOrElse((si-7000) % items.size) { allSeedsDynamic(jsonLoader)[si % allSeedsDynamic(jsonLoader).size] }
        } else { theme = CultureTheme.SHIJING
            val items = listOf("chuanxilu","caigentan","rizhilu","xiaochuangyouji","zengguofanjiashu","xiyouji","hongloumeng").flatMap { loadSeeds(it, jsonLoader) }
            seed = items.getOrElse((si-8800) % items.size) { allSeedsDynamic(jsonLoader)[si % allSeedsDynamic(jsonLoader).size] }
        }
        return LevelModel("level_$ln", theme, "第 $ln 关", categoryName, seed.phrase,
            genTiles(seed.phrase, si), seed.annotation, seed.story, seed.source)
    }
    private val dis = listOf("天","地","玄","黄","宇","宙","洪","荒","日","月","盈","昂","辰","宿","列","张")
    private fun genTiles(phrase: String, si: Int): List<String> {
        val r = phrase.map { it.toString() }.toMutableList(); val t = maxOf(16, r.size + 4)
        var d = si % dis.size
        while (r.size < t) { val c = dis[d % dis.size]; if (c !in r) r.add(c); d += 7 }
        var s = si * 997 + 13
        for (i in r.size - 1 downTo 1) { s = (s * 1103515245 + 12345) and 0x7fffffff; val j = s % (i + 1); val tmp = r[i]; r[i] = r[j]; r[j] = tmp }
        return r
    }
}
