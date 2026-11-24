package de.gruene.wkapp

import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterFragmentActivity

class MainActivity: FlutterFragmentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        // Android relaunches a killed app from the recent apps with the link it was originally opened with.
        // Drop the link so it isn't handled again, e.g. a guest invitation that was already accepted.
        if ((intent.flags and Intent.FLAG_ACTIVITY_LAUNCHED_FROM_HISTORY) != 0) intent.data = null
        super.onCreate(savedInstanceState)
    }
}
