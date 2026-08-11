package com.eastlakestudio.luduan.data.models
import kotlinx.serialization.Serializable

@Serializable
enum class CultureTheme(val rawValue: String) {
    SHIHAN("史汉典故"), SHIJING("诗经风雅"), TANGSONG("唐诗宋词");
    companion object { fun from(raw: String) = entries.firstOrNull { it.rawValue == raw } ?: SHIHAN }
}
@Serializable
enum class BadgeCategory(val rawValue: String) {
    CHARACTER("人物名将"), ACADEMIC("功名学阶"), CLASSICS("典籍名篇"), PRACTICAL("处世修养");
    companion object { fun from(raw: String) = entries.firstOrNull { it.rawValue == raw } ?: CHARACTER }
}
@Serializable
data class LevelModel(val id: String, val theme: CultureTheme, val title: String, val categoryName: String = "",
    val targetPhrase: String, val tileMatrix: List<String>, val annotation: String,
    val story: String, val source: String, val rewardBadgeId: String? = null, val badgeId: String? = null)
@Serializable
data class BadgeModel(val id: String, val name: String, val sealText: String, val category: String,
    val description: String, val requirementDescription: String, val imageName: String? = null)
@Serializable
data class ClassicalSeedItem(val phrase: String, val annotation: String, val story: String, val source: String)
