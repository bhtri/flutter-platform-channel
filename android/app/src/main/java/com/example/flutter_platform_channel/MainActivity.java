package com.example.flutter_platform_channel;

import android.annotation.TargetApi;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import org.json.JSONException;
import org.json.JSONObject;

import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.util.List;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.BasicMessageChannel;
import io.flutter.plugin.common.BinaryCodec;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.JSONMessageCodec;
import io.flutter.plugin.common.JSONMethodCodec;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.StandardMessageCodec;
import io.flutter.plugin.common.StringCodec;
import io.flutter.plugins.GeneratedPluginRegistrant;


public class MainActivity extends FlutterActivity {
    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        GeneratedPluginRegistrant.registerWith(new FlutterEngine(this));

        // method channel -> invoke
        demoMethodChannel1();
        demoMethodChannel2();

        // have message sent to native code from flutter
        // basic message -> send -> reply (send back to dart)
        demoBasicMessageChannel1();
        demoBasicMessageChannel2();
        demoBasicMessageChannel3();
        demoBasicMessageChannel4();

        // event channel
        demoEventChannel();
    }

    // region MethodChannel
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
    // endregion

    //region BasicMessageChannel
    public static final String StringCodecChannel = "StringCodec";
    public static final String JSONMessageCodecChannel = "JSONMessageCodec";
    public static final String BinaryCodecChannel = "BinaryCodec";
    public static final String StandardMessageCodecChannel = "StandardMessageCodec";

    private void demoBasicMessageChannel1() {
        BasicMessageChannel<String> messageChannel = new BasicMessageChannel<>(getFlutterEngine().getDartExecutor().getBinaryMessenger()
                , StringCodecChannel, StringCodec.INSTANCE);

        messageChannel.setMessageHandler(new BasicMessageChannel.MessageHandler<String>() {
            @Override
            public void onMessage(@Nullable String message, @NonNull BasicMessageChannel.Reply<String> reply) {
                messageChannel.send("Hello " + message + " from native code");
                reply.reply(null);
            }
        });
    }

    private void demoBasicMessageChannel2() {
        BasicMessageChannel<Object> messageChannel = new BasicMessageChannel<Object>(getFlutterEngine().getDartExecutor().getBinaryMessenger()
                , JSONMessageCodecChannel, JSONMessageCodec.INSTANCE);

        messageChannel.setMessageHandler(new BasicMessageChannel.MessageHandler<Object>() {
            @Override
            public void onMessage(@Nullable Object message, @NonNull BasicMessageChannel.Reply<Object> reply) {
                JSONObject jsonObject = new JSONObject();
                try {
                    jsonObject.put("phone", "0123456789");
                    jsonObject.put("email", "abc@.co.jp");
                    jsonObject.put("message from fluter", message);
                } catch (Exception exp){}
                messageChannel.send(jsonObject);
                reply.reply(null);
            }
        });
    }

    private void demoBasicMessageChannel3() {
        BasicMessageChannel<ByteBuffer> messageChannel = new BasicMessageChannel<ByteBuffer>(getFlutterEngine().getDartExecutor().getBinaryMessenger()
                , BinaryCodecChannel, BinaryCodec.INSTANCE);

        messageChannel.setMessageHandler(new BasicMessageChannel.MessageHandler<ByteBuffer>() {
            @Override
            public void onMessage(@Nullable ByteBuffer message, @NonNull BasicMessageChannel.Reply<ByteBuffer> reply) {
                message.order(ByteOrder.nativeOrder());

                Log.i("From Dart", String.valueOf(message.getDouble()));

                ByteBuffer echo = ByteBuffer.allocateDirect(16);
                echo.putDouble(123.456);

                reply.reply(echo);
            }
        });
    }

    private void demoBasicMessageChannel4(){
        BasicMessageChannel<Object> messageChannel = new BasicMessageChannel<>(getFlutterEngine().getDartExecutor().getBinaryMessenger()
                , StandardMessageCodecChannel, StandardMessageCodec.INSTANCE);

        messageChannel.setMessageHandler(new BasicMessageChannel.MessageHandler<Object>() {
            @Override
            public void onMessage(@Nullable Object message, @NonNull BasicMessageChannel.Reply<Object> reply) {
                List<Integer> list = (List<Integer>)message;
                for (int i=0; i<list.size();i++){
                    list.set(i, list.get(i) *10);
                }
                reply.reply(list);
            }
        });
    }
    //endregion

    //region EventChannel
    public static final String StreamChannel = "stream";
    Handler handler = new Handler(Looper.getMainLooper());

    private void demoEventChannel() {
        new EventChannel(getFlutterEngine().getDartExecutor().getBinaryMessenger(), StreamChannel)
                .setStreamHandler(new EventChannel.StreamHandler() {
                    @Override
                    public void onListen(Object arguments, EventChannel.EventSink events) {
                        handler.postDelayed(buildCallBack(events), 500);
                    }

                    @Override
                    public void onCancel(Object arguments) {

                    }
                });
    }

    int i = 0;
    Runnable callback;

    private Runnable buildCallBack(EventChannel.EventSink events) {
        if (callback == null) {
            callback = new Runnable() {
                @Override
                public void run() {
                    events.success(String.valueOf(i++));
                    handler.postDelayed(callback, 500);
                }
            };
        }
        return callback;
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        if(callback != null) {
            handler.removeCallbacks(callback);
        }
        Log.i("Native Code", "onDestroy");
    }

    //endregion
}
