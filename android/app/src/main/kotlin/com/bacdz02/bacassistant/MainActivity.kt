package com.bacdz02.bacassistant

import android.os.Build
import android.view.View
import android.view.Window
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "bacassistant/system_ui"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                if (call.method != "setColors") {
                    result.notImplemented()
                    return@setMethodCallHandler
                }

                val color = call.argument<Number>("color")?.toInt()
                val darkIcons = call.argument<Boolean>("darkIcons")
                if (color == null || darkIcons == null) {
                    result.error(
                        "INVALID_ARGUMENTS",
                        "System UI color arguments are required",
                        null,
                    )
                    return@setMethodCallHandler
                }

                applySystemBarColors(window, color, darkIcons)
                result.success(null)
            }
    }

    private fun applySystemBarColors(window: Window, color: Int, darkIcons: Boolean) {
        window.addFlags(WindowManager.LayoutParams.FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS)
        window.statusBarColor = color
        window.navigationBarColor = color

        var flags = window.decorView.systemUiVisibility
        flags = if (darkIcons) {
            flags or View.SYSTEM_UI_FLAG_LIGHT_STATUS_BAR or
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    View.SYSTEM_UI_FLAG_LIGHT_NAVIGATION_BAR
                } else {
                    0
                }
        } else {
            flags and View.SYSTEM_UI_FLAG_LIGHT_STATUS_BAR.inv() and
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    View.SYSTEM_UI_FLAG_LIGHT_NAVIGATION_BAR.inv()
                } else {
                    -1
                }
        }
        window.decorView.systemUiVisibility = flags
    }
}
