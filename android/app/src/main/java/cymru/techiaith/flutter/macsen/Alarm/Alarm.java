package cymru.techiaith.flutter.macsen.Alarm;

import android.app.PendingIntent;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.app.AlarmManager;
import android.content.Intent;
import android.content.BroadcastReceiver;

import java.util.Calendar;

import cymru.techiaith.flutter.macsen.MainActivity;
import io.flutter.plugin.common.MethodChannel;

// https://www.javacodegeeks.com/2012/09/android-alarmmanager-tutorial.html

public class Alarm extends BroadcastReceiver {

    private MainActivity _mainactivity;
    private MethodChannel _alarm_channel;
    private AlarmManager _alarm_manager;

    public static final int ALARM_REQUEST_CODE=101;

    public Alarm(MainActivity activity,
                 MethodChannel alarm_channel){
        _mainactivity=activity;
        _alarm_channel=alarm_channel;
        _alarm_manager=(AlarmManager)_mainactivity
                .getApplicationContext()
                .getSystemService(Context.ALARM_SERVICE);
    }

    public boolean setAlarm(int hour, int minutes){

        Intent intent = new Intent(
                _mainactivity.getApplicationContext(),
                Alarm.class);

        PendingIntent pendingIntent=PendingIntent.getBroadcast(
                _mainactivity.getApplicationContext(),
                ALARM_REQUEST_CODE,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT
                );

        //
        Calendar alarmTime = Calendar.getInstance();
        alarmTime.setTimeInMillis(System.currentTimeMillis());
        alarmTime.set(Calendar.HOUR_OF_DAY, hour);
        alarmTime.set(Calendar.MINUTE, minutes);

        //
        _alarm_manager.set(AlarmManager.RTC_WAKEUP,
                alarmTime.getTimeInMillis(),
                pendingIntent
                );

        return true;
    }

    @Override
    public void onReceive(Context context, Intent intent) {
        System.out.println("ALARM!!!");
        _alarm_channel.invokeMethod("alarmTrigger", "");
    }
}
