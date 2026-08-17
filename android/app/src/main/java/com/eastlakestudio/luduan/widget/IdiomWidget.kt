package com.eastlakestudio.luduan.widget

import android.content.Context
import com.eastlakestudio.luduan.R
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.glance.GlanceId
import androidx.glance.Image
import androidx.glance.GlanceModifier
import androidx.glance.GlanceTheme
import androidx.glance.action.ActionParameters
import androidx.glance.action.actionParametersOf
import androidx.glance.action.clickable
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.GlanceAppWidgetReceiver
import androidx.glance.appwidget.action.actionRunCallback
import androidx.glance.appwidget.provideContent
import androidx.glance.appwidget.updateAll
import androidx.glance.background
import androidx.glance.layout.Alignment
import androidx.glance.layout.Box
import androidx.glance.layout.Column
import androidx.glance.layout.Row
import androidx.glance.layout.Spacer
import androidx.glance.layout.fillMaxSize
import androidx.glance.layout.fillMaxWidth
import androidx.glance.layout.height
import androidx.glance.layout.padding
import androidx.glance.layout.size
import androidx.glance.text.FontWeight
import androidx.glance.text.Text
import androidx.glance.text.TextStyle
import androidx.glance.unit.ColorProvider
import org.json.JSONArray
import java.util.Random

data class DailyWord(val phrase: String, val story: String, val source: String)

object WordStore {
    private const val PREFS = "idiom_widget"
    private const val KEY_PHRASE = "phrase"
    private const val KEY_STORY = "story"
    private const val KEY_SOURCE = "source"

    private val presets = listOf(
        DailyWord("厚德载物", "地势坤，君子以厚德载物。", "《周易》"),
        DailyWord("温故知新", "温故而知新，可以为师矣。", "《论语·为政》"),
        DailyWord("桃之夭夭", "桃之夭夭，灼灼其华。", "《诗经·周南·桃夭》"),
        DailyWord("海纳百川", "海纳百川，有容乃大。", "《古训名联》"),
        DailyWord("自强不息", "天行健，君子以自强不息。", "《周易·乾卦》"),
        DailyWord("高山仰止", "高山仰止，景行行止。", "《诗经·小雅》"),
        DailyWord("三顾茅庐", "三顾臣于草庐之中。", "《出师表》"),
        DailyWord("鹏程万里", "抟扶摇而上者九万里。", "《庄子·逍遥游》"),
    )

    // 进程内缓存：只解析一次 2.8MB JSON，后续换词毫秒级
    @Volatile private var cachedWords: List<DailyWord>? = null
    private val rnd = java.util.Random()

    private fun library(context: Context): List<DailyWord> {
        cachedWords?.let { return it }
        return synchronized(this) {
            cachedWords?.let { return it }
            val list = try {
                val text = context.assets.open("seeds/words.json").bufferedReader().use { it.readText() }
                val arr = JSONArray(text)
                (0 until arr.length()).mapNotNull { i ->
                    val o = arr.getJSONObject(i)
                    val phrase = o.optString("phrase", "")
                    if (phrase.length == 4) {
                        DailyWord(phrase, o.optString("story", ""), o.optString("source", ""))
                    } else null
                }
            } catch (e: Exception) { emptyList() }
            cachedWords = list
            list
        }
    }

    fun current(context: Context): DailyWord {
        val prefs = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
        val p = prefs.getString(KEY_PHRASE, null)
            ?: return random(context)  // 首次：随机选并保存
        return DailyWord(p, prefs.getString(KEY_STORY, "")!!, prefs.getString(KEY_SOURCE, "")!!)
    }

    /** 随机换词，确保与当前不同 */
    fun next(context: Context): DailyWord {
        val cur = current(context).phrase
        val lib = library(context)
        var word: DailyWord
        var attempts = 0
        do {
            word = if (lib.isNotEmpty()) lib[rnd.nextInt(lib.size)] else presets[rnd.nextInt(presets.size)]
            attempts++
        } while (word.phrase == cur && attempts < 8)
        save(context, word)
        return word
    }

    private fun random(context: Context): DailyWord {
        val lib = library(context)
        val w = if (lib.isNotEmpty()) lib[rnd.nextInt(lib.size)] else presets[rnd.nextInt(presets.size)]
        save(context, w)
        return w
    }

    private fun save(context: Context, w: DailyWord) {
        context.getSharedPreferences(PREFS, Context.MODE_PRIVATE).edit()
            .putString(KEY_PHRASE, w.phrase)
            .putString(KEY_STORY, w.story)
            .putString(KEY_SOURCE, w.source)
            .apply()
    }
}

class IdiomWidget : GlanceAppWidget() {
    // 响应式布局：覆盖 2x2 / 2x3 / 3x2 / 4x2 / 4x3 / 4x4 / 5x4 等常见格
    // 原则：宽或高任一 >140dp 即显示原文+出处，仅 2x2 隐藏
    override val sizeMode = androidx.glance.appwidget.SizeMode.Responsive(setOf(
        androidx.compose.ui.unit.DpSize(140.dp, 140.dp),  // 2x2（无原文）
        androidx.compose.ui.unit.DpSize(140.dp, 250.dp),  // 2x3 / 2x4（有原文）
        androidx.compose.ui.unit.DpSize(250.dp, 140.dp),  // 3x2 / 4x2（有原文）
        androidx.compose.ui.unit.DpSize(250.dp, 250.dp),  // 4x3 / 4x4 / 5x4（有原文+大字）
        androidx.compose.ui.unit.DpSize(320.dp, 250.dp)   // 5x4+ 超宽
    ))

    override suspend fun provideGlance(context: Context, id: GlanceId) {
        val word = WordStore.current(context)
        provideContent {
            GlanceTheme {
                WidgetContent(word)
            }
        }
    }

    @Composable
    private fun WidgetContent(word: DailyWord) {
        val context = androidx.glance.LocalContext.current
        // LocalSize 由响应式 sizeMode 提供，据此动态调整字号与内容
        val size = androidx.glance.LocalSize.current
        // 全部尺寸都显示原文+出处；仅字号随尺寸缩放
        val isLarge = size.width > 260.dp && size.height > 200.dp
        val isCompact = size.width <= 145.dp && size.height <= 145.dp  // 2x2 紧凑档

        val phraseSize = if (isCompact) 22.sp else if (isLarge) 40.sp else 32.sp
        val annSize = if (isCompact) 13.sp else if (isLarge) 20.sp else 16.sp
        val srcSize = if (isCompact) 10.sp else if (isLarge) 14.sp else 12.sp
        val storyMax = if (isCompact) 16 else if (isLarge) 70 else 48
        val storyLines = if (isCompact) 2 else if (isLarge) 4 else 3

        Box(
            modifier = GlanceModifier.fillMaxSize()
                .background(Color(0xFFFCF8F0))
                .clickable(actionRunCallback<OpenAppAction>())
                .padding(if (isCompact) 8.dp else 12.dp)
        ) {
            Column(modifier = GlanceModifier.fillMaxSize()) {
                Text(
                    word.phrase,
                    style = TextStyle(color = ColorProvider(Color(0xFF8B1A1A)), fontSize = phraseSize, fontWeight = FontWeight.Bold, fontFamily = androidx.glance.text.FontFamily("serif")),
                    maxLines = 1
                )
                Spacer(GlanceModifier.height(if (isCompact) 4.dp else if (isLarge) 10.dp else 6.dp))
                Text(
                    word.story.take(storyMax) + if (word.story.length > storyMax) "…" else "",
                    style = TextStyle(color = ColorProvider(Color(0xFF333333)), fontSize = annSize, fontFamily = androidx.glance.text.FontFamily("serif")),
                    maxLines = storyLines
                )
                Spacer(GlanceModifier.defaultWeight())
                // 底部行：出处居左，箭头永远居右下角
                Row(modifier = GlanceModifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
                    Text(
                        word.source.take(if (isCompact) 10 else 20),
                        style = TextStyle(color = ColorProvider(Color(0xFF888888)), fontSize = srcSize, fontFamily = androidx.glance.text.FontFamily("serif")),
                        maxLines = 1
                    )
                    Spacer(GlanceModifier.defaultWeight())
                    Box(
                        modifier = GlanceModifier.clickable(
                            androidx.glance.appwidget.action.actionStartActivity(
                                android.content.Intent(context, NextWordTrampolineActivity::class.java)
                            )
                        ).padding(4.dp),
                        contentAlignment = Alignment.Center
                    ) {
                        Image(
                            provider = androidx.glance.ImageProvider(R.drawable.ic_next_word),
                            contentDescription = "下一词",
                            modifier = GlanceModifier.size(if (isCompact) 13.dp else 18.dp)
                        )
                    }
                }
            }
        }
    }
}

class IdiomWidgetReceiver : GlanceAppWidgetReceiver() {
    override val glanceAppWidget: GlanceAppWidget = IdiomWidget()
}

// 点击整个 widget 打开 App
class OpenAppAction : androidx.glance.appwidget.action.ActionCallback {
    override suspend fun onAction(context: Context, glanceId: GlanceId, parameters: ActionParameters) {
        val intent = context.packageManager.getLaunchIntentForPackage(context.packageName)
        intent?.addFlags(android.content.Intent.FLAG_ACTIVITY_NEW_TASK)
        intent?.let { context.startActivity(it) }
    }
}


