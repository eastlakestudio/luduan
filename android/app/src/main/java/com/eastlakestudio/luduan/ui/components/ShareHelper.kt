package com.eastlakestudio.luduan.ui.components
import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import androidx.core.content.FileProvider
import java.io.File
import java.io.FileOutputStream

object ShareHelper {
    fun shareText(ctx: Context, text: String) { ctx.startActivity(Intent.createChooser(Intent(Intent.ACTION_SEND).apply { type = "text/plain"; putExtra(Intent.EXTRA_TEXT, text) }, "分享")) }
    fun shareImageAndText(ctx: Context, bmp: Bitmap, text: String) {
        try { val d = File(ctx.cacheDir, "share"); d.mkdirs(); val f = File(d, "share.png")
            FileOutputStream(f).use { bmp.compress(Bitmap.CompressFormat.PNG, 100, it) }
            val uri = FileProvider.getUriForFile(ctx, "${ctx.packageName}.fileprovider", f)
            ctx.startActivity(Intent.createChooser(Intent(Intent.ACTION_SEND).apply { type = "image/png"; putExtra(Intent.EXTRA_STREAM, uri); putExtra(Intent.EXTRA_TEXT, text); addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION) }, "分享捷报"))
        } catch (e: Exception) { shareText(ctx, text) }
    }
}
