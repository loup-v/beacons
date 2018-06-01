package io.intheloup.beaconsexample

import android.content.Intent
import io.flutter.app.FlutterApplication
import io.intheloup.beacons.BeaconsPlugin
import io.intheloup.beacons.data.BackgroundMonitoringEvent

class App : FlutterApplication() {

    override fun onCreate() {
        super.onCreate()

        BeaconsPlugin.init(this, object : BeaconsPlugin.BackgroundMonitoringCallback {
            override fun onBackgroundMonitoringEvent(event: BackgroundMonitoringEvent): Boolean {
                val intent = Intent(this@App, MainActivity::class.java)
                startActivity(intent)
                return true
            }
        })
    }
}