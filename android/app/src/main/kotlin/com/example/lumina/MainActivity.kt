package com.example.lumina

import android.content.Context
import com.google.firebase.remoteconfig.FirebaseRemoteConfig
import android.os.Bundle
import com.google.firebase.Firebase
import com.google.firebase.ai.InferenceMode
import com.google.firebase.ai.OnDeviceConfig
import com.google.firebase.ai.OnDeviceModelOption
import com.google.firebase.ai.ai
import com.google.firebase.ai.type.GenerativeBackend
import com.google.firebase.ai.type.PublicPreviewAPI
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

class MainActivity : FlutterActivity() {
    private val channelName = "com.example.lumina/hybrid_ai"
    private val fixedDebugToken = "4148e175-6ca1-48d5-80b9-0d789dd8a330"

    override fun onCreate(savedInstanceState: Bundle?) {
        val appId = "1:1074412583426:android:54d1d3be1054cd4a6b051b"
        val prefs = getSharedPreferences(
            "com.google.firebase.appcheck.debug.store.$appId",
            Context.MODE_PRIVATE
        )
        prefs.edit().putString(
            "com.google.firebase.appcheck.debug.DEBUG_SECRET",
            fixedDebugToken
        ).apply()

        super.onCreate(savedInstanceState)
    }

    @Volatile
    private var hybridModel: com.google.firebase.ai.GenerativeModel? = null

    @OptIn(PublicPreviewAPI::class)
    private fun getHybridModel(): com.google.firebase.ai.GenerativeModel {
        return hybridModel ?: synchronized(this) {
            hybridModel ?: run {
                val remoteConfig = FirebaseRemoteConfig.getInstance()
                val modelName = remoteConfig.getString("hybrid_model_name")
                    .ifEmpty { "gemini-3.5-flash-lite" }

                Firebase.ai(
                    backend = GenerativeBackend.googleAI()
                ).generativeModel(
                    modelName = modelName,
                    onDeviceConfig = OnDeviceConfig(
                        mode = InferenceMode.PREFER_ON_DEVICE,
                        modelOption = OnDeviceModelOption.PREVIEW_FAST
                    )
                ).also { hybridModel = it }
            }
        }
    }

    @OptIn(PublicPreviewAPI::class)
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            channelName
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "checkOnDeviceAvailability" -> {
                    CoroutineScope(Dispatchers.IO).launch {
                        try {
                            val model = getHybridModel()
                            val status = model.onDeviceExtension?.checkStatus()
                            val statusStr = status?.toString() ?: "UNSUPPORTED"
                            val available = statusStr.contains("AVAILABLE", ignoreCase = true) &&
                                !statusStr.contains("UNAVAILABLE", ignoreCase = true)

                            withContext(Dispatchers.Main) {
                                result.success(mapOf("available" to available, "status" to statusStr))
                            }
                        } catch (e: Exception) {
                            withContext(Dispatchers.Main) {
                                result.error("AVAILABILITY_ERROR", e.message, null)
                            }
                        }
                    }
                }
                "prepareOnDeviceModel" -> {
                    CoroutineScope(Dispatchers.IO).launch {
                        try {
                            val model = getHybridModel()
                            val extension = model.onDeviceExtension
                            val statusStr = extension?.checkStatus()?.toString() ?: "UNSUPPORTED"

                            if (statusStr.contains("DOWNLOADABLE", ignoreCase = true)) {
                                launch {
                                    try {
                                        extension?.download()?.collect { _ -> }
                                    } catch (_: Exception) {}
                                }
                            } else if (statusStr.contains("AVAILABLE", ignoreCase = true) &&
                                !statusStr.contains("UNAVAILABLE", ignoreCase = true)) {
                                launch {
                                    try { extension?.warmUp() } catch (_: Exception) {}
                                }
                            }

                            withContext(Dispatchers.Main) {
                                result.success(mapOf("status" to statusStr))
                            }
                        } catch (e: Exception) {
                            withContext(Dispatchers.Main) {
                                result.error("PREPARE_ERROR", e.message, null)
                            }
                        }
                    }
                }
                "generateHybrid" -> {
                    val prompt = call.argument<String>("prompt")
                    if (prompt == null) {
                        result.error("INVALID_ARGUMENT", "prompt is required", null)
                        return@setMethodCallHandler
                    }

                    CoroutineScope(Dispatchers.IO).launch {
                        try {
                            val model = getHybridModel()
                            val response = model.generateContent(prompt)
                            val rawSource = response.inferenceSource.toString()
                            val normalizedSource = if (rawSource.contains("ON_DEVICE", ignoreCase = true)) {
                                "ON_DEVICE"
                            } else {
                                "IN_CLOUD"
                            }

                            withContext(Dispatchers.Main) {
                                result.success(
                                    mapOf(
                                        "text" to (response.text ?: ""),
                                        "inferenceSource" to normalizedSource
                                    )
                                )
                            }
                        } catch (e: Exception) {
                            withContext(Dispatchers.Main) {
                                result.error("GENERATION_ERROR", e.message, null)
                            }
                        }
                    }
                }
                else -> result.notImplemented()
            }
        }
    }
}