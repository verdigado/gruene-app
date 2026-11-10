package de.gruene.wkapp

import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        // Android relaunches a killed app from the recent apps with the link it was originally opened with.
        // Drop the link so it isn't handled again, e.g. a guest invitation that was already accepted.
        if ((intent.flags and Intent.FLAG_ACTIVITY_LAUNCHED_FROM_HISTORY) != 0) intent.data = null
        super.onCreate(savedInstanceState)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MfaSetupLinkChannel.channel =
            MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "de.gruene.wkapp/mfa_setup_link")
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        MfaSetupLinkChannel.channel = null
        super.cleanUpFlutterEngine(flutterEngine)
    }
}
