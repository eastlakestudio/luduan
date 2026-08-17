package com.eastlakestudio.luduan.ui.components
import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Text
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.asImageBitmap
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.ColorFilter
import androidx.compose.ui.graphics.ColorMatrix
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

// 功名学阶徽章图映射（对应 iOS ChineseSealView.loadCartoonImage）
// badge_acad_N_* -> badge_academic_*.jpg
private fun academicImageMapping(imageName: String): String {
    val clean = imageName.removeSuffix(".png").removeSuffix(".jpg")
    if (!clean.startsWith("badge_acad_")) return clean
    return when {
        clean.startsWith("badge_acad_1") -> "badge_academic_tongsheng"  // 童生
        clean.startsWith("badge_acad_2") -> "badge_academic_xiucai"     // 秀才
        clean.startsWith("badge_acad_3") -> "badge_academic_juren"      // 贡生(举人级)
        clean.startsWith("badge_acad_4") -> "badge_academic_jinshi"     // 举人(进士级)
        clean.startsWith("badge_acad_5") -> "badge_academic_hanlin"     // 贡士(翰林级)
        else -> "badge_academic_shoufu"                                // 进士/鼎甲/翰林/宰辅/帝师
    }
}

@Composable
fun BadgeImageView(ctx: Context, imageName: String?, sealText: String, isUnlocked: Boolean, size: Int = 72) {
    val bmp = remember(imageName) {
        if (imageName != null) {
            val mapped = academicImageMapping(imageName)
            var b: Bitmap? = null
            for (ext in listOf("png", "jpg")) {
                try { ctx.assets.open("badges/$mapped.$ext").use { b = BitmapFactory.decodeStream(it) }; if (b != null) break } catch (e: Exception) {}
            }
            b
        } else null
    }
    if (bmp != null) {
        val colorFilter = if (isUnlocked) null
            else ColorFilter.colorMatrix(androidx.compose.ui.graphics.ColorMatrix().apply { setToSaturation(0f) })
        Image(
            bmp.asImageBitmap(), sealText,
            Modifier.size(size.dp).clip(RoundedCornerShape((size*0.15).dp)),
            contentScale = ContentScale.Crop,
            colorFilter = colorFilter,
            alpha = if (isUnlocked) 1f else 0.45f
        )
    } else {
        Box(Modifier.size(size.dp).clip(RoundedCornerShape((size*0.12).dp))
            .background(if (isUnlocked) Color(0xFFD4A04A).copy(alpha=0.15f) else Color.Gray.copy(alpha=0.1f))
            .border(2.dp, if (isUnlocked) Color(0xFFC73C1E) else Color.Gray.copy(alpha=0.3f), RoundedCornerShape((size*0.12).dp)), Alignment.Center) {
            Text(text = sealText.replace("\n",""), color = if (isUnlocked) Color(0xFFC73C1E) else Color.Gray.copy(alpha=0.4f), fontFamily = FontFamily.Serif, fontSize = (size*0.2).sp, textAlign = TextAlign.Center, maxLines = 2)
        }
    }
}