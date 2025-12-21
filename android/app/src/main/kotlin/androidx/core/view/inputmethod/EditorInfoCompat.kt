package androidx.core.view.inputmethod

import android.view.inputmethod.EditorInfo

/**
 * Compatibility shim: provide a no-op implementation of
 * `setStylusHandwritingEnabled` for platforms where the
 * method is missing in the bundled androidx.core runtime.
 */
class EditorInfoCompat {
    companion object {
        @JvmStatic
        fun setStylusHandwritingEnabled(editorInfo: EditorInfo?, enabled: Boolean) {
            // Intentionally no-op. This prevents NoSuchMethodError
            // when Flutter's TextInputPlugin calls this API on older
            // runtime variants that don't include it.
        }
    }
}
