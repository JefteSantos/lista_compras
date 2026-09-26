package com.naoesquece.culpadoturing

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.enableEdgeToEdge
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        (this as ComponentActivity).enableEdgeToEdge()
        super.onCreate(savedInstanceState)
    }
}
