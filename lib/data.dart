import 'package:intl/intl.dart';
import 'auth/settings.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Weather {
  final int? max;
  final int? min;
  final int? current;
  final String? desciption;
  final String? day;
  final int? wind;
  final int? humidity;
  final int? chanceRain;
  final String? image;
  final String? time;
  final String? location;

  Weather(
      {this.max,
      this.min,
      this.desciption,
      this.day,
      this.wind,
      this.humidity,
      this.chanceRain,
      this.image,
      this.current,
      this.time,
      this.location});
}

Future<List> fetchData(String lat, String lon, String city) async {
  var url =
      'https://api.openweathermap.org/data/2.5/onecall?lat=$lat&lon=$lon&lang=fr&units=metric&appid=$apiKey';

  final response = await http.get(Uri.parse(url));
  DateTime date = DateTime.now();
  if (response.statusCode == 200) {
    var res = jsonDecode(response.body);

    // currentTemp
    var current = res['current'];
    Weather currentTemp = Weather(
        current: current['temp']?.round() ?? 0,
        image: findIcon(current["weather"][0]["main"].toString(), true),
        desciption: current['weather'][0]['main'].toString(),
        day: DateFormat('EEEE dd MMMM').format(date),
        wind: current['wind_speed']?.round() ?? 0,
        humidity: current['humidity']?.round() ?? 0,
        chanceRain: current['uvi']?.round() ?? 0,
        location: city);

    // TodayWeather
    List<Weather> todayWeather = [];
    int hour = int.parse(DateFormat('hh').format(date));
    for (var i = 0; i < 4; i++) {
      var temp = res['hourly'];
      var hourly = Weather(
          current: temp[i]['temp']?.round() ?? 0,
          image: findIcon(temp[i]["weather"][0]["main"].toString(), false),
          time: Duration(hours: hour + i + 1).toString().split(":")[0] + ':00');
      todayWeather.add(hourly);
    }

    // TomorrowWeather
    var daily = res['daily'][0];
    Weather tomorrowTemp = Weather(
      max: daily['temp']['max'].round() ?? 0,
      min: daily['temp']['min'].round() ?? 0,
      image: findIcon(daily["weather"][0]["main"].toString(), true),
      desciption: daily['weather'][0]['description'],
      wind: daily['wind_speed'].round() ?? 0,
      humidity: daily['humidity'].round() ?? 0,
      chanceRain: daily['uvi']?.round() ?? 0,
    );

    // 7 days weather
    List<Weather> sevenDays = [];
    for (var i = 1; i < 8; i++) {
      String day = DateFormat('EEEE')
          .format(DateTime(date.year, date.month, date.day + i + 1))
          .substring(0, 3);
      var temp = res['daily'][i];
      var hourly = Weather(
        day: day,
        max: temp['temp']['max'].round() ?? 0,
        min: temp['temp']['min'].round() ?? 0,
        image: findIcon(temp["weather"][0]["main"].toString(), false),
        desciption: temp['weather'][0]['description'].toString(),
      );
      sevenDays.add(hourly);
    }

    return [currentTemp, todayWeather, tomorrowTemp, sevenDays];
  }
  return [null, null, null, null];
}

Weather currentTemp = Weather(
    current: null,
    image: "assets/thunder.png",
    desciption: "Thunderstorm",
    day: "Monday, 17 May",
    wind: 13,
    humidity: 24,
    chanceRain: 87,
    location: null);

List<Weather> todayWeather = [
  Weather(current: 23, image: "assets/rainy_2d.png", time: "10:00"),
  Weather(current: 21, image: "assets/thunder_2d.png", time: "11:00"),
  Weather(current: 22, image: "assets/rainy_2d.png", time: "12:00"),
  Weather(current: 19, image: "assets/snow_2d.png", time: "01:00")
];

Weather tomorrowTemp = Weather(
  max: null,
  min: null,
  image: null,
  desciption: null,
  wind: null,
  humidity: null,
  chanceRain: null,
);

List<Weather> sevenDays = [
  Weather(max: null, min: null, image: null, day: "", desciption: ""),
  Weather(max: null, min: null, image: "", day: "", desciption: ""),
  Weather(max: null, min: null, image: "", day: "", desciption: ""),
  Weather(max: null, min: null, image: "", day: "", desciption: ""),
  Weather(max: null, min: null, image: "", day: "", desciption: ""),
  Weather(max: null, min: null, image: "", day: "", desciption: "")
];

//findIcon
String findIcon(String name, bool type) {
  if (type) {
    switch (name) {
      case "Clouds":
        return "assets/sunny.png";
      case "Rain":
        return "assets/rainy.png";

      case "Drizzle":
        return "assets/rainy.png";

      case "Thunderstorm":
        return "assets/thunder.png";

      case "Snow":
        return "assets/snow.png";

      default:
        return "assets/sunny.png";
    }
  } else {
    switch (name) {
      case "Clouds":
        return "assets/sunny_2d.png";

      case "Rain":
        return "assets/rainy_2d.png";

      case "Drizzle":
        return "assets/rainy_2d.png";

      case "Thunderstorm":
        return "assets/thunder_2d.png";

      case "Snow":
        return "assets/snow_2d.png";

      default:
        return "assets/sunny_2d.png";
    }
  }
}

class CityModel {
  final String? name;
  final String? lat;
  final String? lon;
  CityModel({this.name, this.lat, this.lon});
}

// ignore: prefer_typing_uninitialized_variables
var cityData;
Future<CityModel?> fetchCityByName(String cityName) async {
  if (cityName.isNotEmpty) {
    String url =
        "https://api.openweathermap.org/data/2.5/weather?q=$cityName&appid=$apiKey";
    var response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      cityData = json.decode(response.body);
      for (var i = 0; i < cityData.length; i++) {
        return CityModel(
            name: cityName.toString(),
            lat: cityData["coord"]["lat"].toString(),
            lon: cityData["coord"]["lon"].toString());
      }
    } else {
      return null;
    }
  }
  return null;
}
