package com.eastlakestudio.luduan.ui.components

import android.content.Context
import android.graphics.BitmapFactory
import androidx.compose.foundation.Image
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.border
import androidx.compose.material3.Text
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.asImageBitmap
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

@Composable
fun BadgeImageView(
    context: Context,
    imageName: String?,
    sealText: String,
    isUnlocked: Boolean,
    size: Int = 72
) {
    val bitmap = remember(imageName) {
        if (imageName != null) {
            try {
                context.assets.open("badges/$imageName.png").use {
                    BitmapFactory.decodeStream(it)
                } ?: context.assets.open("badges/$imageName.jpg").use {
                    BitmapFactory.decodeStream(it)
                }
            } catch (e: Exception) { null }
        } else null
    }

    if (bitmap != null && isUnlocked) {
        Image(
            bitmap = bitmap.asImageBitmap(),
            contentDescription = sealText,
            modifier = Modifier
                .size(size.dp)
                .clip(RoundedCornerShape((size * 0.15).dp))
                .border(2.dp, Color(0xD4A04A), RoundedCornerShape((size * 0.15).dp)),
            contentScale = ContentScale.Crop
        )
    } else {
        // 印章占位
        Box(
            modifier = Modifier
                .size(size.dp)
                .clip(RoundedCornerShape((size * 0.12).dp))
                .background(
                    if (isUnlocked) Color(0xD4A04A).copy(alpha = 0.15f)
                    else Color.Gray.copy(alpha = 0.1f)
                )
                .border(
                    2.dp,
                    if (isUnlocked) Color(0xC73921) else Color.Gray.copy(alpha = 0.3f),
                    RoundedCornerShape((size * 0.12).dp)
                ),
            contentAlignment = Alignment.Center
        ) {
            Text(
                sealText.replace("\n", ""),
                color = if (isUnlocked) Color(0xC73921) else Color.Gray.copy(alpha = 0.4f),
                fontSize = (size * 0.2).sp,
                fontFamily = FontFamily.Serif,
                textAlign = TextAlign.Center,
                maxLines = 2
            )
        }
    }
}
