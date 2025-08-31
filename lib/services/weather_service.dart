import 'package:dio/dio.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather_app/models/weather_model.dart';

class WeatherService {
  Future<String> _getLocation() async{
    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      return Future.error('Konum Servisi etkin değil.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Konum izni vermelisiniz.');
      }
    }

    final Position position = await Geolocator.getCurrentPosition(
        locationSettings: AndroidSettings(
          accuracy: LocationAccuracy.high,
          forceLocationManager: true,
          intervalDuration: const Duration(seconds: 5),
          distanceFilter: 0,
        )
    );

    final List<Placemark> placemark = await 
      placemarkFromCoordinates(position.latitude, position.longitude);

    return placemark[0].administrativeArea ?? "Konum bulunamadı";
  }

  Future<List<WeatherModel>> getWeatherData() async{

    final String city = await _getLocation();

    final String url = 'https://api.collectapi.com/weather/getWeather?lang=tr&city=$city';

    const Map<String,dynamic> headers = {
      "authorization": "apikey 4421Q8KhVKvST8HozU6b8m:49BSFY7oKFGdziB9PzVZ2S",
      "content-type": "application/json"
    };

    final dio = Dio();

    final response = await dio.get(url, options: Options(headers: headers));

    if(response.statusCode != 200){
      return Future.error('Hava durumu verisi alınamadı');
    }
    
    final List list = response.data['result'];

    final List<WeatherModel> weatherList = list.map((e) => WeatherModel.fromJson(e)).toList();
  
    return weatherList;
  }
}

