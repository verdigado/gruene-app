package de.gruene.wkapp

import android.app.Activity
import android.os.Bundle
import io.flutter.plugin.common.MethodChannel

/** Hands MFA setup links (`de.gruene.wkapp.mfa://setup?url=<activation token url>`) to Flutter. */
object MfaSetupLinkChannel {
    var channel: MethodChannel? = null
}

/**
 * Receives MFA setup links tapped on the Keycloak setup page during an app login.
 *
 * Deliberately not handled by [MainActivity]: the link is tapped in the login Custom Tab, which is opened on top of
 * [MainActivity]. As [MainActivity] is not on top, the link would start a second [MainActivity] with its own Flutter
 * engine above the Custom Tab. This activity is started above the Custom Tab instead and finishes right away, so the
 * Custom Tab stays visible and continues the login once the app has registered as authenticator.
 */
class MfaSetupLinkActivity : Activity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        intent?.dataString?.let { MfaSetupLinkChannel.channel?.invokeMethod("onLink", it) }
        finish()
    }
}
