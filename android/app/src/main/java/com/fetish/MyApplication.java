package com.fetish;

import android.content.SharedPreferences;
import android.media.Ringtone;
import android.net.Uri;
import android.widget.Toast;

import androidx.annotation.Nullable;
import androidx.fragment.app.FragmentManager;

// import com.google.android.exoplayer2.ExoPlaybackException;
// import com.google.android.exoplayer2.ExoPlayerFactory;
// import com.google.android.exoplayer2.PlaybackParameters;
// import com.google.android.exoplayer2.Player;
// import com.google.android.exoplayer2.SimpleExoPlayer;
// import com.google.android.exoplayer2.Timeline;
// import com.google.android.exoplayer2.audio.AudioAttributes;
// import com.google.android.exoplayer2.source.TrackGroupArray;
// import com.google.android.exoplayer2.source.hls.HlsMediaSource;
// import com.google.android.exoplayer2.trackselection.DefaultTrackSelector;
// import com.google.android.exoplayer2.trackselection.TrackSelectionArray;
// import com.google.android.exoplayer2.upstream.DefaultDataSourceFactory;
// import com.google.android.exoplayer2.util.Util;

import java.util.ArrayList;
import java.util.Calendar;
import java.util.Collections;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import io.flutter.app.FlutterApplication;

/**
 * Created by John Ebere on 6/6/2018.
 */
public class MyApplication extends FlutterApplication
//  implements Player.EventListener
{
    public static final String EXTRA_ALARM = "james.alarmio.AlarmActivity.EXTRA_ALARM";
    public static final String EXTRA_ALARM_ID = "james.alarmio.AlarmActivity.EXTRA_ALARM_ID";
    public static final String SETTINGS_PREF = "setPref";
    public static final String ALARM_IDS = "alarmIds";
    public static final String PACKAGE_NAME = "packageName";
    public static final String MAX_TIME = "maxTime";
    public static final String TIME_SHARED = "timeShared";
    public static final String TIMETABLE_MUTED = "timetableMuted";
    public static final String TIMETABLE_SPLIT = ":::";
    public static final String NORMAL_SPLIT = "---";
    public static final int POSITION_NAME = 0;
    public static final int POSITION_MESSAGE = 1;
    public static final int POSITION_TIMETEXT = 2;


    @Override
    public void onCreate() {
        super.onCreate();

    }

}