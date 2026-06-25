package com.felixdinh.secondary_screen

import android.app.Presentation
import android.content.Context
import android.os.Bundle
import android.view.Display
import android.view.ViewGroup
import android.widget.FrameLayout
import io.flutter.embedding.android.FlutterView
import io.flutter.embedding.engine.FlutterEngine

class PresentationDisplay(
    context: Context,
    private val flutterEngine: FlutterEngine,
    display: Display
) :
    Presentation(context, display) {

    private var flutterView: FlutterView? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val flContainer = FrameLayout(context)
        val params = FrameLayout.LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT,
            ViewGroup.LayoutParams.MATCH_PARENT
        )
        flContainer.layoutParams = params
        setContentView(flContainer)

        flutterView = FlutterView(context).also {
            flContainer.addView(it, params)
            it.attachToFlutterEngine(flutterEngine)
        }
    }

    override fun onStop() {
        flutterView?.detachFromFlutterEngine()
        flutterView = null
        super.onStop()
    }
}
