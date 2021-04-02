package com.example.flutter_platform_channel;

import android.annotation.TargetApi;
import android.os.Build;
import android.os.Bundle;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import org.json.JSONException;
import org.json.JSONObject;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.JSONMethodCodec;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;


public class MainActivity extends FlutterActivity {
    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        GeneratedPluginRegistrant.registerWith(new FlutterEngine(this));

        // method channel
        demoMethodChannel1();
        demoMethodChannel2();
    }

    private void demoMethodChannel1() {
        new MethodChannel(getFlutterEngine().getDartExecutor().getBinaryMessenger(), "com.flutter/method1")
                .setMethodCallHandler(new MethodChannel.MethodCallHandler() {
                    @TargetApi(Build.VERSION_CODES.GINGERBREAD)

                    @Override
                    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
                        if (call.method.equals("getDeviceInfoString")) {
                            String type  = call.argument("type");
                            if (type == null || (type != null && type.isEmpty())) {
                                result.error("ERROR", "type can not null", null);
                                return;
                            }
                            result.success(getDeviceInfoString(type));
                            return;
                        }
                        result.notImplemented();
                    }
                });
    }

    private void demoMethodChannel2() {
        new MethodChannel(getFlutterEngine().getDartExecutor().getBinaryMessenger(), "com.flutter/method2", JSONMethodCodec.INSTANCE)
                .setMethodCallHandler(
                    (call, result) -> {
                        if (call.method.equals("getDeviceInfo")) {
                            String type  = call.argument("type");
                            if (type == null || (type != null && type.isEmpty())) {
                                result.error("ERROR", "type can not null", null);
                                return;
                            }
                            result.success(getDeviceInfo(type));
                            return;
                        }
                        result.notImplemented();
                    }
                );
    }

    String getDeviceInfoString(String type) {
        if (type.equals("MODEL")) {
            return Build.MODEL;
        }
        return null;
    }

    JSONObject getDeviceInfo(String type) {
        JSONObject json = new JSONObject();
        if (type.equals("MODEL")) {
            try {
                json.put("model", Build.MODEL);
                json.put("device", Build.DEVICE);
                json.put("manufacturer", Build.MANUFACTURER);
                json.put("time", Build.TIME);
            } catch (JSONException e) {
                e.printStackTrace();
            }
            return json;
        }
        return  null;
    }
}
