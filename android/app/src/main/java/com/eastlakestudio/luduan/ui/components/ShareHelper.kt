package com.eastlakestudio.luduan.ui.components

import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.Canvas
import android.net.Uri
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.drawWithContent
import androidx.compose.ui.graphics.asAndroidBitmap
import androidx.compose.ui.graphics.ImageBitmap
import androidx.compose.ui.graphics.asImageBitmap
import androidx.compose.ui.graphics.layer.GraphicsLayer
import androidx.compose.ui.graphics.rememberGraphicsLayer
import androidx.compose.runtime.remember
import androidx.compose.ui.platform.LocalContext
import androidx.compose.runtime.Composable
import java.io.File
import java.io.FileOutputStream

object ShareHelper {
    fun shareText(context: Context, text: String) {
        val intent = Intent(Intent.ACTION_SEND).apply {
            type = "text/plain"
            putExtra(Intent.EXTRA_TEXT, text)
        }
        context.startActivity(Intent.createChooser(intent, "分享"))
    }

    fun shareImageAndText(context: Context, bitmap: Bitmap, text: String) {
        try {
            val cacheDir = File(context.cacheDir, "share")
            cacheDir.mkdirs()
            val imageFile = File(cacheDir, "luduan_share.png")
            FileOutputStream(imageFile).use { out -> bitmap.compress(Bitmap.CompressFormat.PNG, 100, out) }

            val uri = androidx.core.content.FileProvider.getUriForFile(
                context,
                "${context.packageName}.fileprovider",
                imageFile
            )

            val intent = Intent(Intent.ACTION_SEND).apply {
                type = "image/png"
                putExtra(Intent.EXTRA_STREAM, uri)
                putExtra(Intent.EXTRA_TEXT, text)
                addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            }
            context.startActivity(Intent.createChooser(intent, "分享捷报"))
        } catch (e: Exception) {
            shareText(context, text)
        }
    }

    fun captureComposable(
        composable: @Composable () -> Unit,
        width: Int,
        height: Int
    ): Bitmap? {
        // 用 Compose 的 GraphicsLayer 渲染（需要在 Composable 上下文中调用）
        // 实际实现见 PuzzleGameScreen 中的 rememberGraphicsLayer 方式
        return null
    }
}
