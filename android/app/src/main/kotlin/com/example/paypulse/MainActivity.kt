package com.example.paypulse

import android.os.Bundle
import android.util.Log
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
	override fun onCreate(savedInstanceState: Bundle?) {
		super.onCreate(savedInstanceState)

		// Install a default uncaught exception handler to catch/ignore
		// the specific NoSuchMethodError coming from EditorInfoCompat
		// while we work on a proper dependency fix. This prevents the
		// process from immediately crashing on that call.
		val previousHandler = Thread.getDefaultUncaughtExceptionHandler()
		Thread.setDefaultUncaughtExceptionHandler { thread, throwable ->
			if (throwable is NoSuchMethodError && throwable.message?.contains("setStylusHandwritingEnabled") == true) {
				Log.e("MainActivity", "Caught EditorInfoCompat NoSuchMethodError — swallowing to avoid crash", throwable)
				// swallow the specific error to keep the app alive; do not call previousHandler
			} else {
				previousHandler?.uncaughtException(thread, throwable)
			}
		}
	}
}
