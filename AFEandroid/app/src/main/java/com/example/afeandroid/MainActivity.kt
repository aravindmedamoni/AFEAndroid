
package com.example.afeandroid

import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.os.Handler
import android.widget.Toast
import androidx.annotation.NonNull
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import kotlinx.android.synthetic.main.activity_main.*
import org.json.JSONObject
import java.util.*
import kotlin.collections.HashMap

class MainActivity : AppCompatActivity() {

    private val CHANNEL : String = "com.aravnd.in/data"
    lateinit var flutterEngine : FlutterEngine
    lateinit var results: String

     fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
                call, result ->
         var value : HashMap<String,String> = call.arguments();
            // Note: this method is invoked on the main thread.
           if(call.method.equals("FromClientToHost")){
               val resultStr = call.arguments.toString()
               val resultJson = JSONObject(resultStr)
               val res = resultJson.getInt("result")
               val operation = resultJson.getString("operation")
               resultText.text = "${when(operation){
                   "Add" -> "Addition"
                   "Multiply" -> "Multiplication"
                   else -> "NA"
               }} of two numbers is : $res"
           }else{
               result.notImplemented()
           }
        }
    }
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        flutterEngine = FlutterEngine(this);

        // Start executing Dart code to pre-warm the FlutterEngine.
        flutterEngine.getDartExecutor().executeDartEntrypoint(
            DartExecutor.DartEntrypoint.createDefault()
        );

        // Cache the FlutterEngine to be used by FlutterActivity.
        FlutterEngineCache
            .getInstance()
            .put("my_engine_id", flutterEngine)


        sendToFlutterModule.setOnClickListener {
//            startActivity(
//                FlutterActivity
//                    .withCachedEngine("my_engine_id")
//                    .build(applicationContext)
//            )
            val pair = isInputValid()
            if (pair != null) {
                sendDataToFlutterModule(pair.first, pair.second)
            }

        }
    }

    private fun sendDataToFlutterModule(first: Int, second: Int) {
        FlutterViewActivity.startActivity(this)
        configureFlutterEngine(flutterEngine)
        //add logic to send these values to the flutter module
        val json = JSONObject()
        json.put("first",first)
        json.put("second",second)
        Handler().postDelayed(
            {
                MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).invokeMethod("fromHostToClient", json.toString())
            },
            500
        )
    }

    private fun isInputValid(): Pair<Int, Int>? {
        //add logic getting the number1 and number2 from the user
        val number1 = edt_number1.text.toString()
        val number2 = edt_number2.text.toString()

        when {
            number1.isBlank() -> showToast("Please enter first number")
            number2.isBlank() -> showToast("Please enter second number")
            else -> return Pair(number1.toInt(), number2.toInt())
        }

        return null
    }

    private fun showToast(msg: String) {
        Toast.makeText(this, msg, Toast.LENGTH_SHORT).show()
    }
}
