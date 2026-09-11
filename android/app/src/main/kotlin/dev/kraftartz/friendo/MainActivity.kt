package dev.kraftartz.friendo

import android.os.Bundle
import android.view.WindowManager
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * Hosts the Flutter engine, and owns this window's FLAG_SECURE.
 *
 * A FragmentActivity rather than a plain FlutterActivity, because the
 * biometric prompt is a fragment and cannot be shown from anything less.
 *
 * The flag is set before the first frame and stays set until the app is told
 * otherwise. A window that started without it would show one preview in the
 * task switcher before the setting had been read, and the setting lives in the
 * encrypted database, which is not open at that moment.
 */
class MainActivity : FlutterFragmentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setScreenshotsAllowed(false)
    }

    override fun configureFlutterEngine(engine: FlutterEngine) {
        super.configureFlutterEngine(engine)
        MethodChannel(engine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "allowScreenshots" -> {
                        setScreenshotsAllowed(call.arguments as? Boolean ?: false)
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun setScreenshotsAllowed(allowed: Boolean) {
        if (allowed) {
            window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
        } else {
            window.setFlags(
                WindowManager.LayoutParams.FLAG_SECURE,
                WindowManager.LayoutParams.FLAG_SECURE,
            )
        }
    }

    private companion object {
        const val CHANNEL = "friendo/screen_privacy"
    }
}
