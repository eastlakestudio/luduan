package com.eastlakestudio.luduan.ui.components

import android.graphics.BitmapFactory
import androidx.compose.foundation.Image
import androidx.compose.foundation.layout.*
import androidx.compose.material3.Text
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.asImageBitmap
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.TextUnit
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

/**
 * 把「甪」用图片显示的 Text（Android 系统字体把「甪」显示成「由」）。
 * 逐字渲染：普通字符用 Text，「甪」用 Image。
 */
@Composable
fun LuText(
    text: String,
    modifier: Modifier = Modifier,
    color: Color = Color.Unspecified,
    fontSize: TextUnit = 15.sp,
    fontFamily: FontFamily? = null,
    textAlign: TextAlign? = null,
    maxLines: Int = Int.MAX_VALUE
) {
    val ctx = LocalContext.current
    val luBmp = remember {
        try { BitmapFactory.decodeStream(ctx.assets.open("text/lu_char_20.png")) } catch (e: Exception) { null }
    }

    if (!text.contains("甪") || luBmp == null) {
        Text(text = text, modifier = modifier, color = color, fontSize = fontSize,
            fontFamily = fontFamily, textAlign = textAlign, maxLines = maxLines)
        return
    }

    // 逐字拆成 Row，甪 用 Image，其余用 Text
    Row(
        modifier = modifier,
        horizontalArrangement = Arrangement.Center,
        verticalAlignment = Alignment.CenterVertically
    ) {
        text.forEach { ch ->
            if (ch == '甪' && luBmp != null) {
                Image(
                    bitmap = luBmp.asImageBitmap(),
                    contentDescription = "甪",
                    modifier = Modifier.height((fontSize.value * 1.2f).dp)
                )
            } else {
                Text(
                    text = ch.toString(),
                    color = color,
                    fontSize = fontSize,
                    fontFamily = fontFamily
                )
            }
        }
    }
}