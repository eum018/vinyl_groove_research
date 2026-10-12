package com.example.vinyl_groove

import android.widget.Toast
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.google.zxing.BinaryBitmap
import com.google.zxing.MultiFormatReader
import com.google.zxing.PlanarYUVLuminanceSource
import com.google.zxing.common.HybridBinarizer

class MainActivity : FlutterActivity() {


    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)



        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger, "com.example.vinyl_groove_m"
        ).setMethodCallHandler { call, result ->

            when (call.method) {


                "t" -> {
                    Toast.makeText(this, call.argument<String>("m"), Toast.LENGTH_SHORT).show()
                    result.success(null)
                }

                "scan" -> {

                    val bytes = call.argument<ByteArray>("bytes")
                    val width = call.argument<Int>("width") ?: 0
                    val height = call.argument<Int>("height") ?: 0


                    try {


                        PlanarYUVLuminanceSource(
                            bytes, width, height, 0, 0, width, height, false
                        ).let { src ->
                            BinaryBitmap(HybridBinarizer(src)).let { img ->
                                result.success(MultiFormatReader().decode(img).text)
                            }
                        }
                    } catch (e: Exception) {
                        result.success(null)
                    }


                }

            }

        }
    }
}
