package dev.kraftartz.friendo

import android.os.Bundle
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    /**
     * Sets FLAG_SECURE on the window, once, for the life of the app.
     *
     * It blanks the preview in the task switcher and it blocks screenshots,
     * so that a glance at the phone shows no Friend and no Note.
     */
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        window.setFlags(
            WindowManager.LayoutParams.FLAG_SECURE,
            WindowManager.LayoutParams.FLAG_SECURE,
        )
    }
}
