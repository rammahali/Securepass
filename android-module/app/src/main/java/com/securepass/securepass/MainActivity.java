package com.securepass.securepass;

import android.content.Intent;
import android.os.Bundle;

import androidx.annotation.NonNull;

import java.util.List;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;


public class MainActivity extends FlutterActivity {
    String passportNumber = "";
    String dateOfBirth = "";
    String dateOFExpiry ="";
    private  final  String CHANNEL_METHOD_AUTHENTICATION = "com.securepass.auth";


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

    }
    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine){
        super.configureFlutterEngine(flutterEngine);
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(),CHANNEL_METHOD_AUTHENTICATION).setMethodCallHandler(
                (call, result) -> {
                    if(call.method.equals("getAuthData")) {

                        List<String > authData = call.argument("authData");
                        System.out.println(authData);
                        this.passportNumber = authData.get(0);
                        this.dateOfBirth = authData.get(1);
                        this.dateOFExpiry = authData.get(2);

                        Intent nfcSession = new Intent(this, AuthActivity.class);
                        nfcSession.putExtra("passportNumber",passportNumber);
                        nfcSession.putExtra("dateofbirth",dateOfBirth);
                        nfcSession.putExtra("dateofexpiry",dateOFExpiry);
                      //  finish();
                        startActivity(nfcSession);

                    }


                    else {
                        result.notImplemented();
                    }

                }
        );





    }
}
