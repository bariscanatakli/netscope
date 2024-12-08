package com.example.netscope

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import android.util.Log
import io.flutter.plugin.common.MethodChannel
import java.io.BufferedReader
import java.io.InputStreamReader

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.traceroute/traceroute"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getTraceroute") {
                val ip = call.argument<String>("ip")
                Log.d("Traceroute", "Received IP: $ip") // Log input IP

                if (ip.isNullOrEmpty()) {
                    result.error("INVALID_IP", "IP address is null or empty", null)
                    return@setMethodCallHandler
                }

                try {
                    val tracerouteResult = getTraceroute(ip)
                    Log.d("Traceroute", "Traceroute result: $tracerouteResult") // Log traceroute result
                    result.success(tracerouteResult)
                } catch (e: Exception) {
                    Log.e("Traceroute", "Error occurred: ${e.message}") // Log error
                    result.error("UNAVAILABLE", "Traceroute not available", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    private fun getTraceroute(ip: String): String {
        val output = StringBuilder()
        try {
            // Use ping as a fallback if traceroute or mtr is unavailable
            val process = Runtime.getRuntime().exec("ping -c 4 $ip")
            val reader = BufferedReader(InputStreamReader(process.inputStream))
            var line: String?

            while (reader.readLine().also { line = it } != null) {
                output.append(line).append("\n")
            }

            reader.close()
            process.waitFor()

            if (process.exitValue() != 0) {
                Log.e("Traceroute", "Ping command failed with exit code: ${process.exitValue()}")
            }
        } catch (e: Exception) {
            Log.e("Traceroute", "Error in ping command: ${e.message}")
        }

        return output.toString()
    }
}
