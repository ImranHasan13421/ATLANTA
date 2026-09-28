package com.ezzeai.atlanta

import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.AlarmClock
import android.provider.MediaStore
import android.provider.Settings
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.ezzeai.atlanta/native_bridge"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "launchApp" -> {
                    val appName = call.argument<String>("appName")?.lowercase()?.trim() ?: ""
                    val success = launchDeviceApp(appName)
                    result.success(success)
                }
                "setAlarm" -> {
                    val hour = call.argument<Int>("hour") ?: 8
                    val minutes = call.argument<Int>("minutes") ?: 0
                    val message = call.argument<String>("message") ?: "Atlanta Alarm"
                    val skipUi = call.argument<Boolean>("skipUi") ?: false
                    val success = setDeviceAlarm(hour, minutes, message, skipUi)
                    result.success(success)
                }
                "openSettings" -> {
                    val settingType = call.argument<String>("type") ?: "general"
                    val success = openDeviceSettings(settingType)
                    result.success(success)
                }
                "openUrl" -> {
                    val url = call.argument<String>("url") ?: ""
                    val success = openBrowserUrl(url)
                    result.success(success)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun launchDeviceApp(name: String): Boolean {
        return try {
            when {
                name.contains("clock") || name.contains("alarm") || name.contains("timer") || name.contains("stopwatch") -> {
                    val intent = Intent(AlarmClock.ACTION_SHOW_ALARMS).apply {
                        flags = Intent.FLAG_ACTIVITY_NEW_TASK
                    }
                    if (intent.resolveActivity(packageManager) != null) {
                        startActivity(intent)
                        true
                    } else {
                        launchPackageOrFallback(listOf(
                            "com.google.android.deskclock",
                            "com.android.deskclock",
                            "com.sec.android.app.clockpackage",
                            "com.transsion.deskclock"
                        ))
                    }
                }
                name.contains("camera") -> {
                    val intent = Intent(MediaStore.INTENT_ACTION_STILL_IMAGE_CAMERA).apply {
                        flags = Intent.FLAG_ACTIVITY_NEW_TASK
                    }
                    startActivity(intent)
                    true
                }
                name.contains("calculator") -> {
                    launchPackageOrFallback(listOf(
                        "com.google.android.calculator",
                        "com.android.calculator2",
                        "com.sec.android.app.popupcalculator",
                        "com.transsion.calculator"
                    ))
                }
                name.contains("calendar") -> {
                    val intent = Intent(Intent.ACTION_MAIN).apply {
                        addCategory(Intent.CATEGORY_APP_CALENDAR)
                        flags = Intent.FLAG_ACTIVITY_NEW_TASK
                    }
                    if (intent.resolveActivity(packageManager) != null) {
                        startActivity(intent)
                        true
                    } else {
                        launchPackageOrFallback(listOf(
                            "com.google.android.calendar",
                            "com.android.calendar",
                            "com.transsion.calendar"
                        ))
                    }
                }
                name.contains("youtube") -> {
                    launchPackageOrFallback(listOf("com.google.android.youtube"), "https://youtube.com")
                }
                name.contains("whatsapp") -> {
                    launchPackageOrFallback(listOf("com.whatsapp", "com.whatsapp.w4b"))
                }
                name.contains("map") || name.contains("navigation") -> {
                    val intent = Intent(Intent.ACTION_VIEW, Uri.parse("geo:0,0?q=")).apply {
                        flags = Intent.FLAG_ACTIVITY_NEW_TASK
                    }
                    if (intent.resolveActivity(packageManager) != null) {
                        startActivity(intent)
                        true
                    } else {
                        launchPackageOrFallback(listOf("com.google.android.apps.maps"), "https://maps.google.com")
                    }
                }
                name.contains("setting") -> {
                    val intent = Intent(Settings.ACTION_SETTINGS).apply {
                        flags = Intent.FLAG_ACTIVITY_NEW_TASK
                    }
                    startActivity(intent)
                    true
                }
                name.contains("browser") || name.contains("chrome") || name.contains("internet") -> {
                    val intent = Intent(Intent.ACTION_VIEW, Uri.parse("https://google.com")).apply {
                        flags = Intent.FLAG_ACTIVITY_NEW_TASK
                    }
                    startActivity(intent)
                    true
                }
                name.contains("phone") || name.contains("dialer") || name.contains("call") -> {
                    val intent = Intent(Intent.ACTION_DIAL).apply {
                        flags = Intent.FLAG_ACTIVITY_NEW_TASK
                    }
                    startActivity(intent)
                    true
                }
                name.contains("message") || name.contains("sms") -> {
                    val intent = Intent(Intent.ACTION_MAIN).apply {
                        addCategory(Intent.CATEGORY_APP_MESSAGING)
                        flags = Intent.FLAG_ACTIVITY_NEW_TASK
                    }
                    if (intent.resolveActivity(packageManager) != null) {
                        startActivity(intent)
                        true
                    } else {
                        launchPackageOrFallback(listOf("com.google.android.apps.messaging", "com.android.mms"))
                    }
                }
                name.contains("gallery") || name.contains("photo") -> {
                    // Try known gallery packages first (Infinix, Transsion, Google, Samsung, Xiaomi)
                    val launched = launchPackageOrFallback(listOf(
                        "com.transsion.ai_gallery",
                        "com.transsion.gallery",
                        "com.google.android.apps.photos",
                        "com.sec.android.gallery3d",
                        "com.miui.gallery",
                        "com.oneplus.gallery",
                        "com.coloros.gallery3d",
                        "com.android.gallery3d"
                    ))
                    if (launched) {
                        true
                    } else {
                        val intent = Intent(Intent.ACTION_VIEW).apply {
                            setDataAndType(Uri.parse("content://media/external/images/media"), "image/*")
                            flags = Intent.FLAG_ACTIVITY_NEW_TASK
                        }
                        if (intent.resolveActivity(packageManager) != null) {
                            startActivity(intent)
                            true
                        } else {
                            searchAndLaunchByName("gallery") || searchAndLaunchByName("photos")
                        }
                    }
                }
                name.contains("file") || name.contains("manager") -> {
                    val launched = launchPackageOrFallback(listOf(
                        "com.transsion.filemanager",
                        "com.google.android.apps.nbu.files",
                        "com.android.documentsui",
                        "com.sec.android.app.myfiles",
                        "com.mi.android.globalFileexplorer"
                    ))
                    if (launched) {
                        true
                    } else {
                        searchAndLaunchByName("files") || searchAndLaunchByName("file manager")
                    }
                }
                else -> {
                    // Dynamic: Search through all installed apps by name/label
                    searchAndLaunchByName(name)
                }
            }
        } catch (e: Exception) {
            e.printStackTrace()
            false
        }
    }

    private fun launchPackageOrFallback(packages: List<String>, webFallbackUrl: String? = null): Boolean {
        for (pkg in packages) {
            try {
                val launchIntent = packageManager.getLaunchIntentForPackage(pkg)
                if (launchIntent != null) {
                    launchIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    startActivity(launchIntent)
                    return true
                }
            } catch (ignored: Exception) {}
        }

        if (webFallbackUrl != null) {
            return openBrowserUrl(webFallbackUrl)
        }
        return false
    }

    /**
     * Dynamically searches through ALL installed apps on the device by their display label.
     * Finds the best match for the given name query and launches it.
     */
    private fun searchAndLaunchByName(query: String): Boolean {
        try {
            val mainIntent = Intent(Intent.ACTION_MAIN, null).apply {
                addCategory(Intent.CATEGORY_LAUNCHER)
            }
            val resolveInfos = packageManager.queryIntentActivities(mainIntent, 0)
            val lowerQuery = query.lowercase().trim()
            val cleanQuery = lowerQuery.replace(" ", "").replace("-", "").replace("_", "")

            // First pass: exact label match
            for (info in resolveInfos) {
                val label = info.loadLabel(packageManager).toString().lowercase().trim()
                val cleanLabel = label.replace(" ", "").replace("-", "").replace("_", "")
                if (label == lowerQuery || cleanLabel == cleanQuery) {
                    val launchIntent = packageManager.getLaunchIntentForPackage(info.activityInfo.packageName)
                    if (launchIntent != null) {
                        launchIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        startActivity(launchIntent)
                        return true
                    }
                }
            }

            // Second pass: label contains query or starts with query
            for (info in resolveInfos) {
                val label = info.loadLabel(packageManager).toString().lowercase().trim()
                val cleanLabel = label.replace(" ", "").replace("-", "").replace("_", "")
                if (label.contains(lowerQuery) || cleanLabel.contains(cleanQuery) || cleanQuery.contains(cleanLabel)) {
                    val launchIntent = packageManager.getLaunchIntentForPackage(info.activityInfo.packageName)
                    if (launchIntent != null) {
                        launchIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        startActivity(launchIntent)
                        return true
                    }
                }
            }

            // Third pass: package name contains query
            for (info in resolveInfos) {
                val pkgName = info.activityInfo.packageName.lowercase()
                if (pkgName.contains(cleanQuery)) {
                    val launchIntent = packageManager.getLaunchIntentForPackage(info.activityInfo.packageName)
                    if (launchIntent != null) {
                        launchIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        startActivity(launchIntent)
                        return true
                    }
                }
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
        return false
    }

    private fun setDeviceAlarm(hour: Int, minutes: Int, message: String, skipUi: Boolean): Boolean {
        return try {
            val intent = Intent(AlarmClock.ACTION_SET_ALARM).apply {
                putExtra(AlarmClock.EXTRA_HOUR, hour)
                putExtra(AlarmClock.EXTRA_MINUTES, minutes)
                putExtra(AlarmClock.EXTRA_MESSAGE, message)
                putExtra(AlarmClock.EXTRA_SKIP_UI, skipUi)
                flags = Intent.FLAG_ACTIVITY_NEW_TASK
            }
            if (intent.resolveActivity(packageManager) != null) {
                startActivity(intent)
                true
            } else {
                // If direct alarm intent fails, open clock app
                launchDeviceApp("clock")
            }
        } catch (e: Exception) {
            e.printStackTrace()
            launchDeviceApp("clock")
        }
    }

    private fun openDeviceSettings(type: String): Boolean {
        return try {
            val action = when (type.lowercase()) {
                "wifi" -> Settings.ACTION_WIFI_SETTINGS
                "bluetooth" -> Settings.ACTION_BLUETOOTH_SETTINGS
                "sound", "volume" -> Settings.ACTION_SOUND_SETTINGS
                "display" -> Settings.ACTION_DISPLAY_SETTINGS
                "battery" -> Settings.ACTION_BATTERY_SAVER_SETTINGS
                else -> Settings.ACTION_SETTINGS
            }
            val intent = Intent(action).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK
            }
            startActivity(intent)
            true
        } catch (e: Exception) {
            e.printStackTrace()
            false
        }
    }

    private fun openBrowserUrl(url: String): Boolean {
        return try {
            val uri = if (url.startsWith("http://") || url.startsWith("https://")) Uri.parse(url) else Uri.parse("https://$url")
            val intent = Intent(Intent.ACTION_VIEW, uri).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK
            }
            startActivity(intent)
            true
        } catch (e: Exception) {
            e.printStackTrace()
            false
        }
    }
}
