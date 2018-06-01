package io.intheloup.beacons.logic

import android.app.Application
import android.content.Context
import io.intheloup.beacons.data.BackgroundMonitoringEvent
import io.intheloup.beacons.data.MonitoringState
import io.intheloup.beacons.data.RegionModel
import org.altbeacon.beacon.Region
import org.altbeacon.beacon.startup.BootstrapNotifier

class BackgroundNotifier(private val application: Application) : BootstrapNotifier {

    private val events = ArrayList<BackgroundMonitoringEvent>()
    private val listeners = ArrayList<Listener>()

    fun addCallback(listener: Listener) {
        listeners.add(listener)

        if (events.isNotEmpty()) {
            events.forEach { listener.callback(it) }
            events.clear()
        }
    }

    fun removeCallback(listener: Listener) {
        listeners.remove(listener)
    }

    private fun notify(event: BackgroundMonitoringEvent) {
        if (listeners.isNotEmpty()) {
            listeners.forEach { it.callback(event) }
        } else {
            events.add(event)
        }
    }

    override fun getApplicationContext(): Context {
        return application
    }

    override fun didDetermineStateForRegion(p0: Int, p1: Region?) {

    }

    override fun didEnterRegion(region: Region) {
        notify(BackgroundMonitoringEvent("didEnterRegion", RegionModel.parse(region), MonitoringState.EnterOrInside))
    }

    override fun didExitRegion(region: Region) {
        notify(BackgroundMonitoringEvent("didExitRegion", RegionModel.parse(region), MonitoringState.ExitOrOutside))
    }

    class Listener(val callback: (BackgroundMonitoringEvent) -> Unit)
}