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

data class DailyWord(val phrase: String, val annotation: String, val source: String)

object WordStore {
    private const val PREFS = "idiom_widget"
    private const val KEY_PHRASE = "phrase"
    private const val KEY_ANNOTATION = "annotation"
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

    fun current(context: Context): DailyWord {
        val prefs = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
        val p = prefs.getString(KEY_PHRASE, null) ?: return randomFromLibrary(context) ?: presets[0]
        return DailyWord(p, prefs.getString(KEY_ANNOTATION, "")!!, prefs.getString(KEY_SOURCE, "")!!)
    }

    /** 随机换词（手动"下一词"），确保与当前不同 */
    fun next(context: Context): DailyWord {
        val cur = current(context).phrase
        var word: DailyWord
        var attempts = 0
        do {
            word = randomFromLibrary(context) ?: presets[Random().nextInt(presets.size)]
            attempts++
        } while (word.phrase == cur && attempts < 8)
        save(context, word)
        return word
    }

    private fun save(context: Context, w: DailyWord) {
        context.getSharedPreferences(PREFS, Context.MODE_PRIVATE).edit()
            .putString(KEY_PHRASE, w.phrase)
            .putString(KEY_ANNOTATION, w.annotation)
            .putString(KEY_SOURCE, w.source)
            .apply()
    }

    private fun randomFromLibrary(context: Context): DailyWord? {
        return try {
            val text = context.assets.open("seeds/words.json").bufferedReader().use { it.readText() }
            val arr = JSONArray(text)
            if (arr.length() == 0) return null
            // 真·随机，优先 4 字词
            val rnd = Random(System.nanoTime())
            for (i in 0 until 12) {
                val o = arr.getJSONObject(rnd.nextInt(arr.length()))
                val phrase = o.optString("phrase", "")
                if (phrase.length == 4) {
                    val w = DailyWord(phrase, o.optString("annotation", ""), o.optString("source", ""))
                    save(context, w)
                    return w
                }
            }
            null
        } catch (e: Exception) { null }
    }
}

class IdiomWidget : GlanceAppWidget() {
    // 响应式布局：小 (2x2) / 中 (4x2) / 大 (4x4)
    override val sizeMode = androidx.glance.appwidget.SizeMode.Responsive(setOf(androidx.compose.ui.unit.DpSize(140.dp, 140.dp), androidx.compose.ui.unit.DpSize(250.dp, 140.dp), androidx.compose.ui.unit.DpSize(250.dp, 250.dp)))

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
        // LocalSize 由响应式 sizeMode 提供，据此动态调整字号与内容
        val size = androidx.glance.LocalSize.current
        val isSmall = size.width < 200.dp
        val isLarge = size.height > 200.dp

        val phraseSize = if (isSmall) 26.sp else if (isLarge) 40.sp else 32.sp
        val annSize = if (isSmall) 10.sp else if (isLarge) 16.sp else 13.sp
        val srcSize = if (isSmall) 9.sp else if (isLarge) 13.sp else 11.sp
        val brandSize = if (isSmall) 10.sp else if (isLarge) 14.sp else 12.sp

        Box(
            modifier = GlanceModifier.fillMaxSize().background(Color(0xFFFCF8F0)).padding(12.dp)
        ) {
            Column(modifier = GlanceModifier.fillMaxSize()) {
                Row(modifier = GlanceModifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
                    Text(
                        "文绉绉-甪端",
                        style = TextStyle(color = ColorProvider(Color(0xFF8B1A1A)), fontSize = brandSize, fontWeight = FontWeight.Bold)
                    )
                    Spacer(GlanceModifier.defaultWeight())
                    Text(
                        "每日一词",
                        style = TextStyle(color = ColorProvider(Color(0xFFBA860B)), fontSize = brandSize)
                    )
                }
                Spacer(GlanceModifier.height(6.dp))
                Text(
                    word.phrase,
                    style = TextStyle(color = ColorProvider(Color(0xFF8B1A1A)), fontSize = phraseSize, fontWeight = FontWeight.Bold),
                    maxLines = 1
                )
                if (!isSmall) {
                    // 小尺寸(2x2)不显示原文释义
                    Spacer(GlanceModifier.height(if (isLarge) 10.dp else 6.dp))
                    Text(
                        word.annotation.take(if (isLarge) 60 else 36) + if (word.annotation.length > (if (isLarge) 60 else 36)) "…" else "",
                        style = TextStyle(color = ColorProvider(Color(0xFF333333)), fontSize = annSize),
                        maxLines = if (isLarge) 3 else 2
                    )
                }
                Spacer(GlanceModifier.defaultWeight())
                // 底部行：出处居左，下一词箭头按钮居右下角
                Row(modifier = GlanceModifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
                    Text(
                        "—— ${word.source.take(18)}",
                        style = TextStyle(color = ColorProvider(Color(0xFF888888)), fontSize = srcSize),
                        maxLines = 1
                    )
                    Spacer(GlanceModifier.defaultWeight())
                    Box(
                        modifier = GlanceModifier.clickable(actionRunCallback<NextWordAction>())
                            .padding(6.dp),
                        contentAlignment = Alignment.Center
                    ) {
                        Image(
                            provider = androidx.glance.ImageProvider(R.drawable.ic_next_word),
                            contentDescription = "下一词",
                            modifier = GlanceModifier.size(if (isSmall) 14.dp else 18.dp)
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

// 下一词：随机换词并刷新所有 widget
class NextWordAction : androidx.glance.appwidget.action.ActionCallback {
    override suspend fun onAction(context: Context, glanceId: GlanceId, parameters: ActionParameters) {
        WordStore.next(context)
        IdiomWidget().update(context, glanceId)
    }
}
