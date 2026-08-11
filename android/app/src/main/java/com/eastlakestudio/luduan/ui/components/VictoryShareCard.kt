package com.eastlakestudio.luduan.ui.components

import android.graphics.Bitmap
import android.graphics.BitmapFactory
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
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
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.eastlakestudio.luduan.ui.theme.*
import com.google.zxing.BarcodeFormat
import com.google.zxing.EncodeHintType
import com.google.zxing.qrcode.QRCodeWriter

object QRCodeGen {
    fun generate(content: String, size: Int = 200): Bitmap? {
        return try {
            val hints = mapOf(EncodeHintType.MARGIN to 1)
            val matrix = QRCodeWriter().encode(content, BarcodeFormat.QR_CODE, size, size, hints)
            val bmp = Bitmap.createBitmap(size, size, Bitmap.Config.RGB_565)
            for (x in 0 until size) {
                for (y in 0 until size) {
                    bmp.setPixel(x, y, if (matrix.get(x, y)) android.graphics.Color.BLACK else android.graphics.Color.WHITE)
                }
            }
            bmp
        } catch (e: Exception) { null }
    }
}

@Composable
fun VictoryShareCard(
    learnedCount: Int,
    source: String,
    story: String,
    modifier: Modifier = Modifier
) {
    val ctx = LocalContext.current

    val iosQR = remember { QRCodeGen.generate("https://apps.apple.com/app/id6799431765", 150) }
    val androidQR = remember { QRCodeGen.generate("https://eastlakestudio.github.io/luduan/luduan-v1.1.0.apk", 150) }
    val webQR = remember { QRCodeGen.generate("https://eastlakestudio.github.io/luduan/", 150) }
    val iconBmp = remember {
        try { BitmapFactory.decodeStream(ctx.assets.open("text/icon_beast.png")) }
        catch (e: Exception) { null }
    }

    Surface(
        modifier = modifier.clip(RoundedCornerShape(16.dp)),
        color = PaperWhite
    ) {
        Column(
            modifier = Modifier.padding(20.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                if (iconBmp != null) {
                    Image(
                        bitmap = iconBmp.asImageBitmap(),
                        contentDescription = null,
                        modifier = Modifier.size(40.dp).clip(RoundedCornerShape(8.dp)),
                        contentScale = ContentScale.Fit
                    )
                    Spacer(Modifier.width(10.dp))
                }
                LuText("\u752a\u7aef\u5b57\u6e38", color = adaptiveCinnabar(), fontSize = 22.sp, fontFamily = FontFamily.Serif)
            }

            Spacer(Modifier.height(4.dp))
            Text("\u795e\u517d\u752a\u7aef\u4f34\u5b66 \u00b7 \u4e07\u5173\u5178\u7c4d\u53e4\u98ce\u624b\u6e38", color = Color.Gray, fontSize = 11.sp)

            Spacer(Modifier.height(16.dp))

            if (story.isNotEmpty()) {
                Text(
                    story.take(120) + if (story.length > 120) "\u2026" else "",
                    color = Color(0xFF333333),
                    fontSize = 16.sp,
                    fontFamily = FontFamily.Serif,
                    lineHeight = 26.sp
                )
                Spacer(Modifier.height(8.dp))
                Text(
                    "\u2014\u2014 $source",
                    color = Color.Gray,
                    fontSize = 12.sp,
                    textAlign = TextAlign.End,
                    modifier = Modifier.fillMaxWidth()
                )
            }

            Spacer(Modifier.height(16.dp))
            Divider(color = adaptiveBorder())
            Spacer(Modifier.height(12.dp))

            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceEvenly
            ) {
                QrItem(androidQR, "\u5b89\u5353\u4e0b\u8f7d")
                QrItem(iosQR, "App Store")
                QrItem(webQR, "\u5b98\u7f51")
            }

            Spacer(Modifier.height(8.dp))
            Text("eastlakestudio.github.io/luduan", color = Color.Gray, fontSize = 10.sp)
        }
    }
}

@Composable
private fun QrItem(bmp: Bitmap?, label: String) {
    Column(horizontalAlignment = Alignment.CenterHorizontally) {
        if (bmp != null) {
            Image(
                bitmap = bmp.asImageBitmap(),
                contentDescription = label,
                modifier = Modifier.size(72.dp)
            )
        }
        Spacer(Modifier.height(2.dp))
        Text(label, color = adaptiveXuan(), fontSize = 10.sp)
    }
}
