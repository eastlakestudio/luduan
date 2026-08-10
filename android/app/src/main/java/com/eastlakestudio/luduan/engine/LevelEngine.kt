package com.eastlakestudio.luduan.engine

import com.eastlakestudio.luduan.data.models.*

object LevelEngine {
    const val TOTAL_LEVELS = 10000

    private val seedFiles = listOf(
        "shihan", "shijing", "tangsong", "lunyu", "daodejing",
        "mengzi", "zhongyong", "guoyu", "chunqiu", "yanshijiaxun",
        "chuanxilu", "caigentan", "rizhilu", "xiaochuangyouji",
        "zengguofanjiashu", "xiyouji", "hongloumeng"
    )

    private val seedsCache = mutableMapOf<String, List<ClassicalSeedItem>>()

    private val allSeeds: List<ClassicalSeedItem>
        get() = seedFiles.flatMap { loadSeeds(it) }

    fun loadSeeds(name: String, jsonLoader: (String) -> String?): List<ClassicalSeedItem> {
        seedsCache[name]?.let { return it }
        val json = jsonLoader(name) ?: return emptyList()
        val items = parseSeeds(json)
        if (items.isNotEmpty()) seedsCache[name] = items
        return items
    }

    private fun parseSeeds(json: String): List<ClassicalSeedItem> {
        return try {
            val arr = org.json.JSONArray(json)
            (0 until arr.length()).map { i ->
                val o = arr.getJSONObject(i)
                ClassicalSeedItem(
                    phrase = o.getString("phrase"),
                    annotation = o.getString("annotation"),
                    story = o.getString("story"),
                    source = o.getString("source")
                )
            }
        } catch (e: Exception) { emptyList() }
    }

    fun level(at index: Int, jsonLoader: (String) -> String?, categoryName: String = ""): LevelModel {
        val safeIndex = index.coerceIn(0, TOTAL_LEVELS - 1)
        val levelNumber = safeIndex + 1

        val theme: CultureTheme
        val rawSeed: ClassicalSeedItem

        if (safeIndex < 2500) {
            theme = CultureTheme.SHIJING
            val items = loadSeeds("shijing", jsonLoader) + loadSeeds("lunyu", jsonLoader) +
                        loadSeeds("daodejing", jsonLoader) + loadSeeds("mengzi", jsonLoader) +
                        loadSeeds("zhongyong", jsonLoader) + loadSeeds("guoyu", jsonLoader) +
                        loadSeeds("chunqiu", jsonLoader)
            rawSeed = if (items.isEmpty()) allSeeds.getOrElse(safeIndex % allSeeds.size) { allSeeds[0] }
                      else items[safeIndex % items.size]
        } else if (safeIndex < 5500) {
            theme = CultureTheme.SHIHAN
            val items = loadSeeds("shihan", jsonLoader)
            rawSeed = if (items.isEmpty()) allSeeds[safeIndex % allSeeds.size]
                      else items[(safeIndex - 2500) % items.size]
        } else if (safeIndex < 7000) {
            theme = CultureTheme.SHIHAN
            val items = loadSeeds("yanshijiaxun", jsonLoader) + loadSeeds("shihan", jsonLoader)
            rawSeed = if (items.isEmpty()) allSeeds[safeIndex % allSeeds.size]
                      else items[(safeIndex - 5500) % items.size]
        } else if (safeIndex < 8800) {
            theme = CultureTheme.TANGSONG
            val items = loadSeeds("tangsong", jsonLoader)
            rawSeed = if (items.isEmpty()) allSeeds[safeIndex % allSeeds.size]
                      else items[(safeIndex - 7000) % items.size]
        } else {
            theme = CultureTheme.SHIJING
            val items = loadSeeds("chuanxilu", jsonLoader) + loadSeeds("caigentan", jsonLoader) +
                        loadSeeds("rizhilu", jsonLoader) + loadSeeds("xiaochuangyouji", jsonLoader) +
                        loadSeeds("zengguofanjiashu", jsonLoader) + loadSeeds("xiyouji", jsonLoader) +
                        loadSeeds("hongloumeng", jsonLoader)
            rawSeed = if (items.isEmpty()) allSeeds[safeIndex % allSeeds.size]
                      else items[(safeIndex - 8800) % items.size]
        }

        return LevelModel(
            id = "level_$levelNumber",
            theme = theme,
            title = "第 $levelNumber 关",
            categoryName = categoryName,
            targetPhrase = rawSeed.phrase,
            tileMatrix = generateTiles(rawSeed.phrase, safeIndex),
            annotation = rawSeed.annotation,
            story = rawSeed.story,
            source = rawSeed.source
        )
    }

    private val distractors = listOf(
        "天","地","玄","黄","宇","宙","洪","荒","日","月",
        "盈","昃","辰","宿","列","张","寒","来","暑","往",
        "秋","收","冬","藏","闰","余","成","岁","律","吕",
        "调","阳","云","腾","致","雨","露","结","为","霜",
        "金","生","丽","水","玉","出","昆","冈","剑","号",
        "巨","阙","珠","称","夜","光","果","珍","李","柰"
    )

    private fun generateTiles(phrase: String, seedIndex: Int): List<String> {
        val targetChars = phrase.toCharArray().map { it.toString() }.toMutableList()
        val result = targetChars.toMutableList()
        val targetGridCount = maxOf(16, targetChars.size + 4)
        var dIndex = seedIndex % distractors.size

        while (result.size < targetGridCount) {
            val candidate = distractors[dIndex % distractors.size]
            if (candidate !in result) result.add(candidate)
            dIndex += 7
        }

        var pseudoSeed = seedIndex * 997 + 13
        for (i in result.size - 1 downTo 1) {
            pseudoSeed = (pseudoSeed * 1103515245 + 12345) and 0x7fffffff
            val j = pseudoSeed % (i + 1)
            result[i] = result[j].also { result[j] = result[i] }
        }
        return result
    }
}
