package com.example.afeandroid

import android.app.Application
import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.os.PersistableBundle
import androidx.appcompat.app.AppCompatActivity
import io.flutter.embedding.android.FlutterActivity

class FlutterViewActivity : Application() {
    companion object{
        fun startActivity(context: Context) {
            val intent = Intent(context, FlutterViewActivity::class.java)
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            context.startActivity(FlutterActivity
                .withCachedEngine("my_engine_id")
                .build(context))
        }
    }

//    override fun onCreate() {
//        super.onCreate()
//        startActivity(
//
//        )
//    }
}