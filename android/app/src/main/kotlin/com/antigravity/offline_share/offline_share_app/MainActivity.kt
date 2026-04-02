package com.antigravity.offline_share.offline_share_app

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.net.wifi.WifiManager
import android.net.wifi.p2p.WifiP2pDevice
import android.net.wifi.p2p.WifiP2pManager
import android.os.Build
import android.os.Handler
import android.os.Looper
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val METHOD_CHANNEL = "com.antigravity.offline_share/native_connection"
    private val EVENT_CHANNEL = "com.antigravity.offline_share/connection_events"

    private var wifiP2pManager: WifiP2pManager? = null
    private var wifiP2pChannel: WifiP2pManager.Channel? = null
    private var eventSink: EventChannel.EventSink? = null

    private var wifiManager: WifiManager? = null
    private var hotspotReservation: WifiManager.LocalOnlyHotspotReservation? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        wifiP2pManager = getSystemService(Context.WIFI_P2P_SERVICE) as WifiP2pManager
        wifiP2pChannel = wifiP2pManager?.initialize(this, mainLooper, null)
        wifiManager = getSystemService(Context.WIFI_SERVICE) as WifiManager

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, METHOD_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "startDiscovery" -> startDiscovery(result)
                "stopDiscovery" -> stopDiscovery(result)
                "startHotspot" -> startHotspot(result)
                "stopHotspot" -> stopHotspot(result)
                "getDeviceName" -> result.success(Build.MODEL)
                else -> result.notImplemented()
            }
        }

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, EVENT_CHANNEL).setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                eventSink = events
            }

            override fun onCancel(arguments: Any?) {
                eventSink = null
            }
        })

        val filter = IntentFilter().apply {
            addAction(WifiP2pManager.WIFI_P2P_PEERS_CHANGED_ACTION)
            addAction(WifiP2pManager.WIFI_P2P_CONNECTION_CHANGED_ACTION)
            addAction(WifiP2pManager.WIFI_P2P_STATE_CHANGED_ACTION)
            addAction(WifiP2pManager.WIFI_P2P_THIS_DEVICE_CHANGED_ACTION)
        }
        registerReceiver(wifiP2pReceiver, filter)
    }

    private val wifiP2pReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            when (intent.action) {
                WifiP2pManager.WIFI_P2P_PEERS_CHANGED_ACTION -> {
                    wifiP2pManager?.requestPeers(wifiP2pChannel) { peers ->
                        val peerList = peers.deviceList.map { device ->
                            mapOf("name" to device.deviceName, "address" to device.deviceAddress)
                        }
                        eventSink?.success(mapOf("type" to "peers", "data" to peerList))
                    }
                }
                WifiP2pManager.WIFI_P2P_CONNECTION_CHANGED_ACTION -> {
                    wifiP2pManager?.requestConnectionInfo(wifiP2pChannel) { info ->
                        if (info.groupFormed) {
                            val data = mapOf(
                                "groupFormed" to true,
                                "isGroupOwner" to info.isGroupOwner,
                                "ownerAddress" to info.groupOwnerAddress?.hostAddress
                            )
                            eventSink?.success(mapOf("type" to "connection", "data" to data))
                        }
                    }
                }
            }
        }
    }

    private fun startDiscovery(result: MethodChannel.Result) {
        wifiP2pManager?.discoverPeers(wifiP2pChannel, object : WifiP2pManager.ActionListener {
            override fun onSuccess() = result.success(true)
            override fun onFailure(reason: Int) = result.error("DISCOVERY_FAILED", "Reason: $reason", null)
        })
    }

    private fun stopDiscovery(result: MethodChannel.Result) {
        wifiP2pManager?.stopPeerDiscovery(wifiP2pChannel, object : WifiP2pManager.ActionListener {
            override fun onSuccess() = result.success(true)
            override fun onFailure(reason: Int) = result.success(false)
        })
    }

    private fun startHotspot(result: MethodChannel.Result) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            try {
                wifiManager?.startLocalOnlyHotspot(object : WifiManager.LocalOnlyHotspotCallback() {
                    override fun onStarted(reservation: WifiManager.LocalOnlyHotspotReservation) {
                        hotspotReservation = reservation
                        val config = reservation.wifiConfiguration
                        val hotspotData = mapOf(
                            "ssid" to config?.SSID,
                            "password" to config?.preSharedKey
                        )
                        eventSink?.success(mapOf("type" to "hotspot", "data" to hotspotData))
                        result.success(true)
                    }

                    override fun onFailed(reason: Int) {
                        result.error("HOTSPOT_FAILED", "Reason: $reason", null)
                    }
                }, Handler(Looper.getMainLooper()))
            } catch (e: Exception) {
                result.error("HOTSPOT_ERROR", e.message, null)
            }
        } else {
            result.error("NOT_SUPPORTED", "Auto-hotspot requires Android 8.0+", null)
        }
    }

    private fun stopHotspot(result: MethodChannel.Result) {
        hotspotReservation?.close()
        hotspotReservation = null
        result.success(true)
    }

    override fun onDestroy() {
        super.onDestroy()
        try {
            unregisterReceiver(wifiP2pReceiver)
        } catch (e: Exception) { }
        hotspotReservation?.close()
    }
}
