package com.felixdinh.secondary_screen

import android.content.Context
import android.hardware.display.DisplayManager
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.view.Display
import com.google.gson.Gson
import io.flutter.FlutterInjector
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.json.JSONObject

class SecondaryScreenPlugin : FlutterPlugin, ActivityAware, MethodChannel.MethodCallHandler {

    private lateinit var channel: MethodChannel
    private lateinit var eventChannel: EventChannel
    private var flutterEngineChannel: MethodChannel? = null
    private var flutterEngine: FlutterEngine? = null
    private var context: Context? = null
    private var presentation: PresentationDisplay? = null
    private var presentationDisplayId: Int? = null
    private var secondaryDisplayReady = false
    private var pendingData: Any? = null

    companion object {
        private const val methodChannelId = "secondary_screen"
        private const val eventChannelId = "secondary_screen_events"
        private const val engineChannelId = "secondary_screen_engine"
        private var displayManager: DisplayManager? = null
    }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, methodChannelId)
        channel.setMethodCallHandler(this)

        eventChannel = EventChannel(binding.binaryMessenger, eventChannelId)
        displayManager = binding.applicationContext
            .getSystemService(Context.DISPLAY_SERVICE) as DisplayManager
        eventChannel.setStreamHandler(DisplayConnectedStreamHandler(displayManager))
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        Log.d("SecondaryScreenPlugin", "method=${call.method} args=${call.arguments}")
        when (call.method) {
            "showPresentation" -> {
                try {
                    val obj = JSONObject(call.arguments as String)
                    val displayId = obj.getInt("displayId")
                    val routerName = obj.getString("routerName")
                    val display = displayManager?.getDisplay(displayId)
                    if (display != null) {
                        val existingEngine = flutterEngine
                        val engine = existingEngine ?: createFlutterEngine(routerName)
                        if (engine == null) {
                            result.error("404", "Can't create FlutterEngine", null)
                            return
                        }

                        secondaryDisplayReady = false
                        if (presentation != null && presentationDisplayId == displayId) {
                            engine.navigationChannel.pushRoute(routerName)
                        } else {
                            if (existingEngine != null) {
                                engine.navigationChannel.pushRoute(routerName)
                            }
                            presentation?.dismiss()
                            presentation = context?.let { PresentationDisplay(it, engine, display) }
                            presentationDisplayId = displayId
                            presentation?.show()
                        }
                        result.success(true)
                    } else {
                        result.error("404", "No display with id $displayId", null)
                    }
                } catch (e: Exception) {
                    result.error(call.method, e.message, null)
                }
            }
            "hidePresentation" -> {
                try {
                    presentation?.dismiss()
                    presentation = null
                    presentationDisplayId = null
                    secondaryDisplayReady = false
                    result.success(true)
                } catch (e: Exception) {
                    result.error(call.method, e.message, null)
                }
            }
            "listDisplay" -> {
                val category = call.arguments as String?
                val displays = displayManager?.getDisplays(category)
                val list = displays?.map { d ->
                    DisplayJson(d.displayId, d.flags, d.rotation, d.name)
                } ?: emptyList()
                result.success(Gson().toJson(list))
            }
            "transferDataToPresentation" -> {
                try {
                    if (secondaryDisplayReady) {
                        flutterEngineChannel?.invokeMethod("DataTransfer", call.arguments)
                    } else {
                        pendingData = call.arguments
                    }
                    result.success(true)
                } catch (e: Exception) {
                    result.success(false)
                }
            }
            else -> result.notImplemented()
        }
    }

    private fun createFlutterEngine(tag: String): FlutterEngine? {
        val ctx = context ?: return null
        val engine = FlutterEngine(ctx)
        engine.navigationChannel.setInitialRoute(tag)
        FlutterInjector.instance().flutterLoader().startInitialization(ctx)
        val path = FlutterInjector.instance().flutterLoader().findAppBundlePath()
        val entrypoint = DartExecutor.DartEntrypoint(path, "secondaryDisplayMain")
        engine.dartExecutor.executeDartEntrypoint(entrypoint)
        engine.lifecycleChannel.appIsResumed()

        flutterEngineChannel = MethodChannel(
            engine.dartExecutor.binaryMessenger, engineChannelId
        ).also { engineChannel ->
            engineChannel.setMethodCallHandler { call, result ->
                if (call.method == "SecondaryDisplayReady") {
                    secondaryDisplayReady = true
                    pendingData?.let { data ->
                        engineChannel.invokeMethod("DataTransfer", data)
                        pendingData = null
                    }
                    result.success(true)
                } else {
                    result.notImplemented()
                }
            }
        }
        flutterEngine = engine
        return engine
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        context = binding.activity
        displayManager = context?.getSystemService(Context.DISPLAY_SERVICE) as DisplayManager?
    }

    override fun onDetachedFromActivity() {}
    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {}
    override fun onDetachedFromActivityForConfigChanges() {}
}

class DisplayConnectedStreamHandler(private val displayManager: DisplayManager?) :
    EventChannel.StreamHandler {

    private var sink: EventChannel.EventSink? = null
    private var handler: Handler? = null

    private val displayListener = object : DisplayManager.DisplayListener {
        override fun onDisplayAdded(displayId: Int) { sink?.success(1) }
        override fun onDisplayRemoved(displayId: Int) { sink?.success(0) }
        override fun onDisplayChanged(displayId: Int) {}
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        sink = events
        handler = Handler(Looper.getMainLooper())
        displayManager?.registerDisplayListener(displayListener, handler)
    }

    override fun onCancel(arguments: Any?) {
        displayManager?.unregisterDisplayListener(displayListener)
        sink = null
        handler = null
    }
}
