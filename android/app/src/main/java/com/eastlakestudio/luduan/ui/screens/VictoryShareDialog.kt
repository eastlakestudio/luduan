package com.eastlakestudio.luduan.ui.screens

import android.graphics.Bitmap
import android.graphics.BitmapFactory
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.asImageBitmap
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.layout.boundsInRoot
import androidx.compose.ui.layout.onGloballyPositioned
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.LocalView
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.core.view.drawToBitmap
import com.eastlakestudio.luduan.ui.components.BadgeImageView
import com.eastlakestudio.luduan.ui.components.QRCodeGen
import com.eastlakestudio.luduan.ui.components.ShareHelper
import com.eastlakestudio.luduan.ui.theme.*
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

/** 每 10 词里程碑分享 */
@Composable
fun VictoryShareDialog(
    learnedCount: Int,
    source: String,
    story: String,
    onDismiss: () -> Unit
) {
    ShareDialogScaffold(
        title = "\u5206\u4eab\u6377\u62a5",
        shareText = "\u3010\u6587\u7EC9\u7EC9-\u752a\u7aef\u3011\u6211\u5df2\u7d2f\u8ba1\u901a\u5173 $learnedCount \u8bcd\u53e4\u98ce\u5b57\u6e38\uff01\u795e\u517d\u752a\u7aef\u4f34\u5b66\uff0c\u4e07\u5173\u5178\u7c4d\u540d\u7bc7\u3002",
        onDismiss = onDismiss
    ) { modifier ->
        MilestoneCardPreview(source, story, modifier)
    }
}

/** 勋章解锁分享 */
@Composable
fun BadgeShareDialog(
    badgeName: String,
    badgeImageName: String?,
    badgeSealText: String,
    badgeDescription: String,
    phrase: String,
    source: String,
    story: String,
    onDismiss: () -> Unit
) {
    ShareDialogScaffold(
        title = "\u52cb\u7ae0\u6377\u62a5",
        shareText = "\u3010\u6587\u7EC9\u7EC9-\u752a\u7aef\u3011\u6211\u89e3\u9501\u4e86\u52cb\u7ae0\u300c$badgeName\u300d\uff01$badgeDescription",
        onDismiss = onDismiss
    ) { modifier ->
        BadgeCardPreview(badgeName, badgeImageName, badgeSealText, badgeDescription, phrase, source, story, modifier)
    }
}

@Composable
private fun ShareDialogScaffold(
    title: String,
    shareText: String,
    onDismiss: () -> Unit,
    cardContent: @Composable (Modifier) -> Unit
) {
    val ctx = LocalContext.current
    val view = LocalView.current
    val scope = rememberCoroutineScope()
    var cardBounds by remember { mutableStateOf<androidx.compose.ui.geometry.Rect?>(null) }
    var sharing by remember { mutableStateOf(false) }

    Box(
        Modifier.fillMaxSize().background(Color.Black.copy(alpha = 0.5f)).clickable(onClick = onDismiss),
        contentAlignment = Alignment.Center
    ) {
        Surface(
            Modifier.fillMaxWidth(0.92f).clip(RoundedCornerShape(16.dp)).clickable(enabled = false) {},
            color = PaperWhite
        ) {
            Column(Modifier.padding(16.dp)) {
                Text(title, color = adaptiveCinnabar(), fontSize = 18.sp, fontFamily = FontFamily.Serif, modifier = Modifier.padding(bottom = 8.dp))

                cardContent(Modifier.onGloballyPositioned { coords ->
                    cardBounds = coords.boundsInRoot()
                })

                Spacer(Modifier.height(12.dp))
                Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                    TextButton(onDismiss, Modifier.weight(1f)) {
                        Text("\u5173\u95ed", color = Color.Gray, fontSize = 14.sp)
                    }
                    Button(
                        onClick = {
                            if (sharing || cardBounds == null) return@Button
                            sharing = true
                            scope.launch {
                                val bounds = cardBounds!!
                                val bmp = withContext(Dispatchers.Main) {
                                    val full = view.drawToBitmap(Bitmap.Config.ARGB_8888)
                                    val l = bounds.left.toInt().coerceIn(0, full.width - 1)
                                    val t = bounds.top.toInt().coerceIn(0, full.height - 1)
                                    val r = bounds.right.toInt().coerceIn(l + 1, full.width)
                                    val b = bounds.bottom.toInt().coerceIn(t + 1, full.height)
                                    Bitmap.createBitmap(full, l, t, r - l, b - t)
                                }
                                ShareHelper.shareImageAndText(ctx, bmp, shareText)
                                sharing = false
                            }
                        },
                        Modifier.weight(1f),
                        enabled = !sharing,
                        colors = ButtonDefaults.buttonColors(containerColor = adaptiveCinnabar())
                    ) {
                        Text(if (sharing) "\u5904\u7406\u4e2d..." else "\u5206\u4eab\u56fe\u7247", color = PaperWhite, fontSize = 14.sp)
                    }
                }
            }
        }
    }
}

// 公共头部：APP 图标 + 品牌文案
@Composable
private fun ShareCardHeader() {
    val ctx = LocalContext.current
    val iconBmp = remember {
        try { BitmapFactory.decodeStream(ctx.assets.open("text/icon_beast.png")) }
        catch (e: Exception) { null }
    }
    Row(verticalAlignment = Alignment.CenterVertically) {
        if (iconBmp != null) {
            Image(iconBmp.asImageBitmap(), null, Modifier.size(36.dp).clip(RoundedCornerShape(8.dp)), contentScale = ContentScale.Fit)
        }
        Spacer(Modifier.width(8.dp))
        Text("\u6587\u7EC9\u7EC9", color = adaptiveBamboo(), fontSize = 22.sp, fontWeight = FontWeight.Bold, fontFamily = FontFamily.Serif)
        Spacer(Modifier.width(8.dp))
        Text("\u752a\u7aef", color = adaptiveBamboo(), fontSize = 22.sp, fontWeight = FontWeight.Bold, fontFamily = FontFamily.Serif)
    }
}

// 公共尾部：三二维码
@Composable
private fun ShareCardFooter() {
    val iosQR = remember { QRCodeGen.generate("https://apps.apple.com/app/id6799431765", 150) }
    val androidQR = remember { QRCodeGen.generate("https://eastlakestudio.github.io/luduan/luduan-v1.1.0.apk", 150) }
    val webQR = remember { QRCodeGen.generate("https://eastlakestudio.github.io/luduan/", 150) }

    Column(horizontalAlignment = Alignment.CenterHorizontally) {
        Spacer(Modifier.height(16.dp))
        Divider(color = adaptiveBorder())
        Spacer(Modifier.height(12.dp))
        Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceEvenly) {
            QrPreview(androidQR, "\u5b89\u5353\u4e0b\u8f7d")
            QrPreview(iosQR, "\u82f9\u679c\u5e94\u7528")
            QrPreview(webQR, "\u5b98\u7f51")
        }
    }
}

/** 每 10 词分享卡片 */
@Composable
private fun MilestoneCardPreview(
    source: String,
    story: String,
    modifier: Modifier = Modifier
) {
    Surface(
        modifier.fillMaxWidth().clip(RoundedCornerShape(12.dp)),
        color = PaperWhite
    ) {
        Column(
            Modifier.padding(20.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            ShareCardHeader()
            Spacer(Modifier.height(4.dp))
            Text("\u795e\u517d\u752a\u7aef\u4f34\u5b66 \u00b7 \u4e07\u5173\u5178\u7c4d\u53e4\u98ce\u624b\u6e38", color = Color.Gray, fontSize = 11.sp)
            Spacer(Modifier.height(16.dp))
            if (story.isNotEmpty()) {
                Text(story.take(120) + if (story.length > 120) "\u2026" else "", color = Color(0xFF333333), fontSize = 16.sp, fontFamily = FontFamily.Serif, lineHeight = 26.sp)
                Spacer(Modifier.height(8.dp))
                Text(source, color = Color.Gray, fontSize = 12.sp, textAlign = TextAlign.End, modifier = Modifier.fillMaxWidth())
            }
            ShareCardFooter()
        }
    }
}

/** 勋章解锁分享卡片：徽章图 + 名号 + 随机原文之一 */
@Composable
private fun BadgeCardPreview(
    badgeName: String,
    badgeImageName: String?,
    badgeSealText: String,
    badgeDescription: String,
    phrase: String,
    source: String,
    story: String,
    modifier: Modifier = Modifier
) {
    val ctx = LocalContext.current
    Surface(
        modifier.fillMaxWidth().clip(RoundedCornerShape(12.dp)),
        color = PaperWhite
    ) {
        Column(
            Modifier.padding(20.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            ShareCardHeader()
            Spacer(Modifier.height(12.dp))

            // 徽章图
            BadgeImageView(ctx, badgeImageName, badgeSealText, true, 88)
            Spacer(Modifier.height(8.dp))
            Text("\u52cb\u7ae0\u89e3\u9501 \u00b7 $badgeName", color = adaptiveCinnabar(), fontSize = 18.sp, fontWeight = FontWeight.Bold, fontFamily = FontFamily.Serif)

            Spacer(Modifier.height(14.dp))
            Divider(color = adaptiveBorder())
            Spacer(Modifier.height(10.dp))

            // 原文之一（随机选定的词句）
            if (story.isNotEmpty()) {
                Text("\u3010$phrase\u3011", color = Color(0xFF333333), fontSize = 15.sp, fontWeight = FontWeight.Bold, fontFamily = FontFamily.Serif)
                Spacer(Modifier.height(4.dp))
                Text(story.take(100) + if (story.length > 100) "\u2026" else "", color = Color(0xFF333333), fontSize = 13.sp, fontFamily = FontFamily.Serif, lineHeight = 21.sp)
                Spacer(Modifier.height(4.dp))
                Text(source, color = Color.Gray, fontSize = 11.sp, textAlign = TextAlign.End, modifier = Modifier.fillMaxWidth())
            }
            ShareCardFooter()
        }
    }
}

@Composable
private fun QrPreview(bmp: Bitmap?, label: String) {
    Column(horizontalAlignment = Alignment.CenterHorizontally) {
        if (bmp != null) Image(bmp.asImageBitmap(), null, Modifier.size(72.dp))
        Spacer(Modifier.height(4.dp))
        Text(label, color = Color(0xFF333333), fontSize = 11.sp)
    }
}
