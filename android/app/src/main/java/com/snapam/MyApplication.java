package com.snapam;


import android.content.SharedPreferences;
import android.media.Ringtone;
import android.net.Uri;
import android.widget.Toast;

import androidx.annotation.Nullable;
import androidx.fragment.app.FragmentManager;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Collections;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import io.flutter.app.FlutterApplication;

/**
 * Created by Maugost Okore on 29/7/2020.
 */
public class MyApplication extends FlutterApplication {

    @Override
    public void onCreate() {
        super.onCreate();
        //super.configureFlutterEngine(this);
    }

}