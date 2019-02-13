package cymru.techiaith.flutter.macsen.Geolocation;

import android.location.Location;
import android.location.Criteria;
import android.location.LocationManager;

import cymru.techiaith.flutter.macsen.MainActivity;
import io.flutter.plugin.common.MethodChannel;


public class Geolocation  {

    private MainActivity _mainactivity;

    private static LocationManager locationManager;

//    private final LocationListener locationListener = new LocationListener(){
//
//        @Override
//        public void onLocationChanged(Location location){
//            locationManager.removeUpdates(locationListener);
//            location.getLatitude();
//            location.getLongitude();
//        }
//
//    }

    public Geolocation(MainActivity activity){
        _mainactivity=activity;
        locationManager = (LocationManager)_mainactivity.getSystemService(this._mainactivity.getApplicationContext().LOCATION_SERVICE);
    }


    public void returnLastLocationreturnLastLocation(MethodChannel location_channel) {
        Criteria crit = new Criteria();
        crit.setAccuracy(Criteria.ACCURACY_COARSE);

        String bestProvider = locationManager.getBestProvider(crit, false);
        Location lastKnownLocation = locationManager.getLastKnownLocation(bestProvider);

        if (lastKnownLocation!=null) {
            String coordinates =
                    Double.toString(lastKnownLocation.getLongitude())
                            + "|"
                            + Double.toString(lastKnownLocation.getLatitude());

            location_channel.invokeMethod("locationCoordinates", coordinates);
        } else {
            location_channel.invokeMethod("locationCoordinates", "NO_COORDINATES");
        }
    }

}