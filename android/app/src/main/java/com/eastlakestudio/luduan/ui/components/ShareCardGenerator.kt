package com.eastlakestudio.luduan.ui.components

import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.LinearGradient
import android.graphics.Paint
import android.graphics.Rect
import android.graphics.RectF
import android.graphics.Shader
import android.graphics.Typeface
import com.google.zxing.BarcodeFormat
import com.google.zxing.EncodeHintType
import com.google.zxing.qrcode.QRCodeWriter

object ShareCardGenerator {

    private const val W = 750
    private const val PAD = 48

    fun generate(ctx: android.content.Context, source: String, story: String): Bitmap {
        val H = 900
        val bmp = Bitmap.createBitmap(W, H, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bmp)
        val serif = Typeface.create("serif", Typeface.NORMAL)

        val bgPaint = Paint().apply {
            shader = LinearGradient(0f, 0f, 0f, H.toFloat(),
                Color.rgb(252, 248, 240), Color.rgb(245, 235, 220), Shader.TileMode.CLAMP)
        }
        canvas.drawRect(0f, 0f, W.toFloat(), H.toFloat(), bgPaint)

        var y = PAD

        // Row: icon + title
        val iconSize = 70
        try {
            val iconBmp = BitmapFactory.decodeStream(ctx.assets.open("text/icon_beast.png"))
            val dst = RectF(PAD.toFloat(), y.toFloat(), (PAD + iconSize).toFloat(), (y + iconSize).toFloat())
            canvas.drawRoundRect(dst, 14f, 14f, Paint().apply { color = Color.WHITE })
            canvas.drawBitmap(iconBmp, null, Rect(PAD + 5, y + 5, PAD + iconSize - 5, y + iconSize - 5), null)
            iconBmp.recycle()
        } catch (e: Exception) {}

        val titlePaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = Color.rgb(139, 26, 26); textSize = 38f; typeface = serif
        }
        canvas.drawText("\u752a\u7aef\u5b57\u6e38", (PAD + iconSize + 16).toFloat(), (y + 48).toFloat(), titlePaint)
        y += iconSize + 18

        // Subtitle
        val subPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = Color.GRAY; textSize = 22f; textAlign = Paint.Align.CENTER
        }
        canvas.drawText("\u795e\u517d\u7531\u7aef\u4f34\u5b66 \u00b7 \u4e07\u5173\u5178\u7c4d\u53e4\u98ce\u624b\u6e38", (W / 2).toFloat(), y.toFloat(), subPaint)
        y += 36

        // Story
        if (story.isNotEmpty()) {
            val storyPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = Color.rgb(51, 51, 51); textSize = 30f; typeface = serif
            }
            val excerpt = if (story.length > 120) story.take(120) + "\u2026" else story
            y = drawWrappedText(canvas, excerpt, PAD.toFloat(), y.toFloat(), W - 2 * PAD, storyPaint, 46f).toInt()
            y += 12

            val srcPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = Color.GRAY; textSize = 22f; textAlign = Paint.Align.RIGHT
            }
            canvas.drawText("\u2014\u2014 $source", (W - PAD).toFloat(), y.toFloat(), srcPaint)
            y += 30
        }

        // Divider
        y = maxOf(y + 12, H - 300)
        val divPaint = Paint().apply { color = Color.rgb(200, 185, 160); strokeWidth = 2f }
        canvas.drawLine(PAD.toFloat(), y.toFloat(), (W - PAD).toFloat(), y.toFloat(), divPaint)
        y += 28

        // QR codes
        val qrSize = 130
        val labels = listOf("\u5b89\u5353\u4e0b\u8f7d", "App Store", "\u5b98\u7f51")
        val urls = listOf(
            "https://eastlakestudio.github.io/luduan/luduan-v1.1.0.apk",
            "https://apps.apple.com/app/id6799431765",
            "https://eastlakestudio.github.io/luduan/"
        )
        val gap = (W - 2 * PAD - qrSize * 3) / 2
        val labelPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = Color.rgb(51, 51, 51); textSize = 22f; textAlign = Paint.Align.CENTER
        }
        for (i in urls.indices) {
            val px = PAD + i * (qrSize + gap)
            val qr = QRCodeGen.generate(urls[i], qrSize)
            if (qr != null) {
                canvas.drawBitmap(qr, null, Rect(px, y, px + qrSize, y + qrSize), null)
                qr.recycle()
            }
            canvas.drawText(labels[i], (px + qrSize / 2).toFloat(), (y + qrSize + 30).toFloat(), labelPaint)
        }
        y += qrSize + 56

        // URL
        val urlPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = Color.GRAY; textSize = 20f; textAlign = Paint.Align.CENTER
        }
        canvas.drawText("eastlakestudio.github.io/luduan", (W / 2).toFloat(), y.toFloat(), urlPaint)

        return bmp
    }

    private fun drawWrappedText(canvas: Canvas, text: String, x: Float, y: Float, maxWidth: Int, paint: Paint, lineHeight: Float): Float {
        var currentY = y
        var line = StringBuilder()
        for (ch in text) {
            val test = line.toString() + ch
            if (paint.measureText(test) > maxWidth && line.isNotEmpty()) {
                canvas.drawText(line.toString(), x, currentY, paint)
                currentY += lineHeight
                line = StringBuilder().append(ch)
            } else {
                line.append(ch)
            }
        }
        if (line.isNotEmpty()) {
            canvas.drawText(line.toString(), x, currentY, paint)
            currentY += lineHeight
        }
        return currentY
    }
}
