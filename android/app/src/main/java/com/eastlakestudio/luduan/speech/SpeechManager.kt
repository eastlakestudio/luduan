package com.eastlakestudio.luduan.speech

import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.speech.RecognitionListener
import android.speech.RecognizerIntent
import android.speech.SpeechRecognizer
import android.util.Log
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow

class SpeechManager private constructor(private val context: Context) {

    companion object {
        @Volatile private var INSTANCE: SpeechManager? = null
        fun get(context: Context): SpeechManager = INSTANCE ?: synchronized(this) {
            INSTANCE ?: SpeechManager(context.applicationContext).also { INSTANCE = it }
        }
    }

    private var recognizer: SpeechRecognizer? = null
    private var debounceTimer: java.util.Timer? = null
    private var onResult: ((String) -> Unit)? = null

    val isRecording = MutableStateFlow(false)
    val recognizedText = MutableStateFlow("")

    fun startRecording(onTextRecognized: (String) -> Unit) {
        if (isRecording.value) return
        onResult = onTextRecognized
        recognizedText.value = ""

        recognizer?.destroy()
        recognizer = SpeechRecognizer.createSpeechRecognizer(context).apply {
            setRecognitionListener(object : RecognitionListener {
                override fun onReadyForSpeech(params: Bundle?) {}
                override fun onBeginningOfSpeech() {}
                override fun onRmsChanged(rmsdB: Float) {}
                override fun onBufferReceived(buffer: ByteArray?) {}
                override fun onEndOfSpeech() {}

                override fun onError(error: Int) {
                    isRecording.value = false
                    debounceTimer?.cancel()
                    val last = recognizedText.value
                    if (last.isNotEmpty()) {
                        onResult?.invoke(last)
                    }
                }

                override fun onResults(results: Bundle?) {
                    isRecording.value = false
                    debounceTimer?.cancel()
                    val matches = results?.getStringArrayList(SpeechRecognizer.RESULTS_RECOGNITION)
                    val text = matches?.firstOrNull() ?: recognizedText.value
                    if (text.isNotEmpty()) {
                        onResult?.invoke(text)
                    }
                }

                override fun onPartialResults(partialResults: Bundle?) {
                    val matches = partialResults?.getStringArrayList(SpeechRecognizer.RESULTS_RECOGNITION)
                    val text = matches?.firstOrNull() ?: return
                    recognizedText.value = text

                    // debounce：0.3 秒无新结果才触发选字
                    debounceTimer?.cancel()
                    debounceTimer = java.util.Timer()
                    debounceTimer?.schedule(object : java.util.TimerTask() {
                        override fun run() {
                            onResult?.invoke(text)
                        }
                    }, 300)
                }

                override fun onEvent(eventType: Int, params: Bundle?) {}
            })
        }

        val intent = Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH).apply {
            putExtra(RecognizerIntent.EXTRA_LANGUAGE_MODEL, RecognizerIntent.LANGUAGE_MODEL_FREE_FORM)
            putExtra(RecognizerIntent.EXTRA_LANGUAGE, "zh-CN")
            putExtra(RecognizerIntent.EXTRA_PARTIAL_RESULTS, true)
            putExtra(RecognizerIntent.EXTRA_MAX_RESULTS, 1)
        }

        isRecording.value = true
        recognizer?.startListening(intent)
    }

    fun stopRecording() {
        isRecording.value = false
        debounceTimer?.cancel()
        recognizer?.stopListening()
        recognizer?.destroy()
        recognizer = null
    }
}
