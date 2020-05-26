package com.fetish;

import android.Manifest;
import android.app.AlarmManager;
import android.content.ContentResolver;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.util.Log;
import android.widget.Toast;

import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;
import androidx.core.content.FileProvider;
import androidx.core.content.PermissionChecker;

//import com.flutterwave.raveandroid.RaveConstants;
//import com.flutterwave.raveandroid.RavePayActivity;
//import com.flutterwave.raveandroid.RavePayManager;

import java.io.File;
import java.io.IOException;
import java.sql.Date;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Calendar;
import java.util.List;
import java.util.Locale;

import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

import static android.view.WindowManager.LayoutParams.FLAG_SECURE;
import static com.fetish.MyApplication.MAX_TIME;
import static com.fetish.MyApplication.NORMAL_SPLIT;
import static com.fetish.MyApplication.PACKAGE_NAME;
import static com.fetish.MyApplication.SETTINGS_PREF;
import static com.fetish.MyApplication.TIMETABLE_MUTED;
import static com.fetish.MyApplication.TIMETABLE_SPLIT;
import static com.fetish.MyApplication.TIME_SHARED;


public class MainActivity extends FlutterActivity {

    private static final String CHANNEL = "channel.john";
    private MethodChannel.Result pendingResult;


    private static String resourceToUriString(Context context, int resId) {
        return
                ContentResolver.SCHEME_ANDROID_RESOURCE
                        + "://"
                        + context.getResources().getResourcePackageName(resId)
                        + "/"
                        + context.getResources().getResourceTypeName(resId)
                        + "/"
                        + context.getResources().getResourceEntryName(resId);
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);


        GeneratedPluginRegistrant.registerWith(this);
        MyApplication myApplication = (MyApplication) getApplicationContext();

        new MethodChannel(getFlutterView(), CHANNEL).setMethodCallHandler(
                (call, result) -> {
                    if ("drawableToUri".equals(call.method)) {
                        int resourceId = MainActivity.this.getResources().getIdentifier((String) call.arguments, "drawable", MainActivity.this.getPackageName());
                        String uriString = resourceToUriString(MainActivity.this.getApplicationContext(), resourceId);
                        result.success(uriString);
                    }
                    if(call.method.equals("shareApp")){
                        String msg = call.argument("message");
                        SharedPreferences shed = getSharedPreferences(SETTINGS_PREF,0);
                        String packageName = shed.getString(PACKAGE_NAME,"com.fetish");
                        Intent share = new Intent(Intent.ACTION_SEND);
                        share.setType("text/plain");
                        String message = msg!=null?msg:String.format("Hurry! Install Strokes. It is the perfect place to find your life partner. \n\nClick on this link to install \nhttp://play.google.com/store/apps/details?id=%s",packageName);
                        String title = "Install Strokes App";
                        share.putExtra(Intent.EXTRA_SUBJECT,title);
                        share.putExtra(Intent.EXTRA_TEXT,message);
                        startActivity(Intent.createChooser(share,"Share Via"));
                    }
                    if(call.method.equals("toast")){
                        String arg = call.argument("message");
                        Toast.makeText(this, arg, Toast.LENGTH_SHORT).show();
                    }
                    if(call.method.equals("openFile")){
                        String filePath = call.argument("path");
                        String fileType = getFileType(filePath);

                        if (pathRequiresPermission(filePath)){
                            if (hasPermission(Manifest.permission.READ_EXTERNAL_STORAGE)) {
                                startFileActivity(filePath,fileType);
                            } else {
                                ActivityCompat.requestPermissions(this, new String[]{Manifest.permission.READ_EXTERNAL_STORAGE}, 291);
                            }
                        } else {
                            startFileActivity(filePath,fileType);
                        }
                    }

                    if(call.method.equals("updatePackage")){
                        String packageName = call.argument("packageName");
                        SharedPreferences shed = getSharedPreferences(SETTINGS_PREF,0);
                        SharedPreferences.Editor se = shed.edit();
                        se.putString(PACKAGE_NAME,packageName);
                        se.apply();
                    }

                    if(call.method.equals("updateTime")){
                        long maxTime = call.argument("maxTime");
                        SharedPreferences shed = getSharedPreferences(SETTINGS_PREF,0);
                        SharedPreferences.Editor se = shed.edit();
                        se.putLong(MAX_TIME,maxTime);
                        se.apply();
                    }



                    if(call.method.equals("pay")){
                        pendingResult=result;
//                  creditsAmount = priceModel.getInt(CREDITS);
//                  int usd = priceModel.getInt(IN_USD);
//                  int ngn = priceModel.getInt(IN_NAIRA);
//
//                  amountPaid = inUsd?usd:ngn;
//                  String nara = String.format("Your payment of %s%s has been received",inUsd?"$":"N",formatNumber(amountPaid));

                        int amount = call.argument("amount");
                        String narration = call.argument("nara");
                        String countryCode = call.argument("countryCode");
                        String currency = call.argument("currency");
                        String amountText = call.argument("amountText");
                        String email = call.argument("email");
                        String name = call.argument("name");
                        String paymentId = call.argument("paymentId");
                        String raveKey = call.argument("raveKey");

                        String key = raveKey.split("and")[0].trim();
                        String secret = raveKey.split("and")[1].trim();

//                        new RavePayManager(this).setAmount(Double.parseDouble(String.valueOf(amount)))
//                                .setCountry(countryCode)
//                                .setCurrency(currency)
//                                .setAmountText(amountText)
//                                .setEmail(email)
//                                .setfName(name)
//                                .setlName("")
//                                .setNarration(narration)
//                                .setPublicKey(key)
//                                .setSecretKey(secret)
//                                .setTxRef(paymentId)
//                                .acceptMpesaPayments(false)
//                                .acceptAccountPayments(true)
//                                .acceptCardPayments(true)
//                                .acceptGHMobileMoneyPayments(false)
//                                .onStagingEnv(false)
//                                .initialize();
                    }

                });
    }

    private boolean hasPermission(String permission) {
        return ContextCompat.checkSelfPermission(this, permission) == PermissionChecker.PERMISSION_GRANTED;
    }

    private String alarmName(String name,String message,String timeText){
        return String.format("%s%s%s%s%s",name,NORMAL_SPLIT,message,NORMAL_SPLIT,timeText);
    }

    private boolean[] getDays(int day){
        boolean[] days = new boolean[7];
        for(int i=0;i<7;i++){
            days[i]= i==day;
        }
        return days;
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
//        try{
//            if (requestCode == RaveConstants.RAVE_REQUEST_CODE && data != null) {
//                String message = data.getStringExtra("response");
//
//                if (message != null) {
//                    Log.d("rave response", message);
//                }
//                if (resultCode == RavePayActivity.RESULT_SUCCESS) {
//                    pendingResult.success("ok");
//                    pendingResult=null;
//                }
//                else if (resultCode == RavePayActivity.RESULT_ERROR) {
//                    pendingResult.success("failed");
//                    pendingResult=null;
//                }else{
//                    pendingResult.success("failed");
//                    pendingResult=null;
//                }
//
//            }}catch (Exception e){};
    }

    private boolean pathRequiresPermission(String filePath) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) {
            return false;
        }

        try {
            String appDirCanonicalPath = new File(getApplicationInfo().dataDir).getCanonicalPath();
            String fileCanonicalPath = new File(filePath).getCanonicalPath();
            return !fileCanonicalPath.startsWith(appDirCanonicalPath);
        } catch (IOException e) {
            e.printStackTrace();
            return true;
        }
    }

    private void startFileActivity(String filePath,String typeString) {
        File file = new File(filePath);
        if (!file.exists()) {
            return;
        }

        Intent intent = new Intent(Intent.ACTION_VIEW);
        intent.setFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP);
        intent.addCategory("android.intent.category.DEFAULT");
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
            String packageName = getPackageName();
            Uri uri = FileProvider.getUriForFile(this, packageName + ".fileProvider", new File(filePath));
            intent.setDataAndType(uri, typeString);
        } else {
            intent.setDataAndType(Uri.fromFile(file), typeString);
        }
        try {
            startActivity(intent);
        } catch (Exception e) {
            //result("No APP found to open this file。");
            return;
        }
    }

    private String getFileType(String filePath) {
        String[] fileStrs = filePath.split("\\.");
        String fileTypeStr = fileStrs[fileStrs.length - 1];
        switch (fileTypeStr) {
            case "3gp":
                return "video/3gpp";
            case "apk":
                return "apk";
            case "asf":
                return "video/x-ms-asf";
            case "avi":
                return "video/x-msvideo";
            case "bin":
                return "application/octet-stream";
            case "bmp":
                return "image/bmp";
            case "c":
                return "text/plain";
            case "class":
                return "application/octet-stream";
            case "conf":
                return "text/plain";
            case "cpp":
                return "text/plain";
            case "doc":
                return "application/msword";
            case "docx":
                return "application/vnd.openxmlformats-officedocument.wordprocessingml.document";
            case "xls":
                return "application/vnd.ms-excel";
            case "xlsx":
                return "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet";
            case "exe":
                return "application/octet-stream";
            case "gif":
                return "image/gif";
            case "gtar":
                return "application/x-gtar";
            case "gz":
                return "application/x-gzip";
            case "h":
                return "text/plain";
            case "htm":
                return "text/html";
            case "html":
                return "text/html";
            case "jar":
                return "application/java-archive";
            case "java":
                return "text/plain";
            case "jpeg":
                return "image/jpeg";
            case "jpg":
                return "image/jpeg";
            case "js":
                return "application/x-javaScript";
            case "log":
                return "text/plain";
            case "m3u":
                return "audio/x-mpegurl";
            case "m4a":
                return "audio/mp4a-latm";
            case "m4b":
                return "audio/mp4a-latm";
            case "m4p":
                return "audio/mp4a-latm";
            case "m4u":
                return "video/vnd.mpegurl";
            case "m4v":
                return "video/x-m4v";
            case "mov":
                return "video/quicktime";
            case "mp2":
                return "audio/x-mpeg";
            case "mp3":
                return "audio/x-mpeg";
            case "mp4":
                return "video/mp4";
            case "mpc":
                return "application/vnd.mpohun.certificate";
            case "mpe":
                return "video/mpeg";
            case "mpeg":
                return "video/mpeg";
            case "mpg":
                return "video/mpeg";
            case "mpg4":
                return "video/mp4";
            case "mpga":
                return "audio/mpeg";
            case "msg":
                return "application/vnd.ms-outlook";
            case "ogg":
                return "audio/ogg";
            case "pdf":
                return "application/pdf";
            case "png":
                return "image/png";
            case "pps":
                return "application/vnd.ms-powerpoint";
            case "ppt":
                return "application/vnd.ms-powerpoint";
            case "pptx":
                return "application/vnd.openxmlformats-officedocument.presentationml.presentation";
            case "prop":
                return "text/plain";
            case "rc":
                return "text/plain";
            case "rmvb":
                return "audio/x-pn-realaudio";
            case "rtf":
                return "application/rtf";
            case "sh":
                return "text/plain";
            case "tar":
                return "application/x-tar";
            case "tgz":
                return "application/x-compressed";
            case "txt":
                return "text/plain";
            case "wav":
                return "audio/x-wav";
            case "wma":
                return "audio/x-ms-wma";
            case "wmv":
                return "audio/x-ms-wmv";
            case "wps":
                return "application/vnd.ms-works";
            case "xml":
                return "text/plain";
            case "z":
                return "application/x-compress";
            case "zip":
                return "application/x-zip-compressed";
            default:
                return "*/*";
        }
    }
}
