import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_glow/flutter_glow.dart';
import 'package:flutter_weather_app/data.dart';
import 'package:flutter_weather_app/pages/detail_page.dart';
import 'package:flutter_weather_app/widget/extra_weather.dart';

String lat = "53.9006";
String lon = "27.5590";
String city = "Minsk";

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  getData() async {
    fetchData(lat, lon, city).then((value) {
      currentTemp = value[0];
      todayWeather = value[1];
      tomorrowTemp = value[2];
      sevenDays = value[3];
      setState(() {});
    });
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff030317),
      body: currentTemp.current == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [CurrentWeather(getData), const TodayWeather()],
            ),
    );
  }
}

class CurrentWeather extends StatefulWidget {
  final Function() updateData;
  const CurrentWeather(this.updateData);
  @override
  _CurrentWeatherState createState() => _CurrentWeatherState();
}

class _CurrentWeatherState extends State<CurrentWeather> {
  bool searchBar = false;
  bool updating = false;
  var focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (searchBar) {
          setState(() {
            searchBar = false;
          });
        }
      },
      child: GlowContainer(
        height: MediaQuery.of(context).size.height - 230,
        margin: const EdgeInsets.only(top: 0, left: 2, right: 2),
        padding: const EdgeInsets.only(top: 20, left: 30, right: 30),
        glowColor: const Color(0xff00A1FF).withOpacity(0.5),
        borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(60), bottomRight: Radius.circular(60)),
        color: const Color(0xff00A1FF),
        spreadRadius: 5,
        child: Column(
          children: [
            Container(
              child: searchBar
                  ? TextField(
                      focusNode: focusNode,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                          fillColor: const Color.fromARGB(151, 0, 162, 255),
                          filled: true,
                          hintText: "Rechercher une ville"),
                      textInputAction: TextInputAction.search,
                      onSubmitted: (value) async {
                        CityModel? temp = await fetchCityByName(value);
                        if (temp == null) {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  backgroundColor: const Color(0xff030317),
                                  title: const Text(
                                      "Impossible de trouver votre ville"),
                                  content: const Text(
                                      "Merci de vérifier le nom de la ville et réssayer"),
                                  actions: [
                                    TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text("Ok"))
                                  ],
                                );
                              });
                          searchBar = false;
                          return;
                        }
                        city = temp.name!;
                        lat = temp.lat!;
                        lon = temp.lon!;
                        updating = true;
                        setState(() {});
                        widget.updateData();
                        searchBar = false;
                        updating = false;
                        setState(() {});
                      },
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            searchBar = true;
                            setState(() {});
                            focusNode.requestFocus();
                          },
                          child: const Icon(
                            CupertinoIcons.search,
                            color: Colors.white,
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(CupertinoIcons.map_fill,
                                color: Colors.white),
                            Text(
                              " " + city,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 30),
                            ),
                          ],
                        ),
                        const Icon(Icons.more_vert, color: Colors.white)
                      ],
                    ),
            ),
            // Container(
            //   margin: const EdgeInsets.only(top: 10),
            //   padding: const EdgeInsets.all(10),
            //   decoration: BoxDecoration(
            //       border: Border.all(width: 0.2, color: Colors.white),
            //       borderRadius: BorderRadius.circular(30)),
            //   child: Text(
            //     updating ? "Updating" : "Updated",
            //     style: const TextStyle(fontWeight: FontWeight.bold),
            //   ),
            // ),
            SizedBox(
              height: 230,
              child: Stack(
                children: [
                  Image(
                    image: AssetImage(currentTemp.image.toString()),
                    fit: BoxFit.fill,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    left: 0,
                    child: Center(
                        child: Column(
                      children: [
                        GlowText(
                          currentTemp.current.toString(),
                          style: const TextStyle(
                              height: 0.1,
                              fontSize: 150,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(currentTemp.desciption.toString(),
                            style: const TextStyle(
                              fontSize: 25,
                            )),
                        Text(currentTemp.day.toString(),
                            style: const TextStyle(
                              fontSize: 18,
                            ))
                      ],
                    )),
                  )
                ],
              ),
            ),
            const Divider(
              color: Colors.white,
            ),
            const SizedBox(
              height: 5,
            ),
            ExtraWeather(currentTemp)
          ],
        ),
      ),
    );
  }
}

class TodayWeather extends StatelessWidget {
  const TodayWeather({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 30, right: 30, top: 9),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Aujourd'hui",
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (BuildContext context) {
                    return DetailPage(tomorrowTemp, sevenDays);
                  }));
                },
                child: Row(
                  children: const [
                    Text(
                      "7 jours ",
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_outlined,
                      color: Colors.grey,
                      size: 15,
                    )
                  ],
                ),
              )
            ],
          ),
          const SizedBox(
            height: 15,
          ),
          Container(
            margin: const EdgeInsets.only(
              bottom: 30,
            ),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  WeatherWidget(todayWeather[0]),
                  WeatherWidget(todayWeather[1]),
                  WeatherWidget(todayWeather[2]),
                  WeatherWidget(todayWeather[3])
                ]),
          )
        ],
      ),
    );
  }
}

class WeatherWidget extends StatelessWidget {
  final Weather weather;
  const WeatherWidget(this.weather);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
          border: Border.all(width: 0.2, color: Colors.white),
          borderRadius: BorderRadius.circular(35)),
      child: Column(
        children: [
          Text(
            weather.current.toString() + "\u00B0",
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(
            height: 5,
          ),
          Image(
            image: AssetImage(weather.image.toString()),
            width: 50,
            height: 50,
          ),
          const SizedBox(
            height: 5,
          ),
          Text(
            weather.time.toString(),
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          )
        ],
      ),
    );
  }
}
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_glow/flutter_glow.dart';
// import 'package:flutter_weather_app/data.dart';
// import 'package:flutter_weather_app/widget/extra_weather.dart';
// import 'package:flutter_weather_app/pages/detail_page.dart';

// String lat = "53.9006";
// String lon = "27.5590";
// String city = "Minsk";

// class Home extends StatefulWidget {
//   const Home({Key? key}) : super(key: key);

//   @override
//   State<Home> createState() => _HomeState();
// }

// class _HomeState extends State<Home> {
//   getData() async {
//     fetchData(lat, lon, city).then((value) {
//       currentTemp = value[0];
//       todayWeather = value[1];
//       tomorrowTemp = value[2];
//       sevenDays = value[3];
//     });
//   }

//   @override
//   void initState() {
//     super.initState();
//     getData();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xff030317),
//       body: Column(
//         children: const [CurrentWeather(), TodayWeather()],
//       ),
//     );
//   }
// }

// class CurrentWeather extends StatelessWidget {
//   const CurrentWeather({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return GlowContainer(
//       height: MediaQuery.of(context).size.height - 230,
//       margin: const EdgeInsets.all(2),
//       padding: const EdgeInsets.only(top: 20, left: 30, right: 30),
//       glowColor: const Color(0xff00A1FF).withOpacity(0.5),
//       borderRadius: const BorderRadius.only(
//           bottomLeft: Radius.circular(60), bottomRight: Radius.circular(60)),
//       color: const Color(0xff00A1FF),
//       spreadRadius: 5,
//       child: Column(
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               const Icon(
//                 CupertinoIcons.square_grid_2x2,
//                 color: Colors.white,
//               ),
//               Row(
//                 children: [
//                   const Icon(CupertinoIcons.map_fill, color: Colors.white),
//                   Text(
//                     " " + currentTemp.location.toString(),
//                     style: const TextStyle(
//                         fontWeight: FontWeight.bold, fontSize: 30),
//                   ),
//                 ],
//               ),
//               const Icon(Icons.more_vert, color: Colors.white)
//             ],
//           ),
//           Container(
//             margin: const EdgeInsets.only(top: 10),
//             padding: const EdgeInsets.all(5),
//             decoration: BoxDecoration(
//                 border: Border.all(width: 0.2, color: Colors.white),
//                 borderRadius: BorderRadius.circular(30)),
//             child: const Text(
//               "Actualiser",
//               style: TextStyle(fontWeight: FontWeight.bold),
//             ),
//           ),
//           SizedBox(
//             height: 30,
//             child: Stack(
//               children: [
//                 // Image(
//                 //   height: 200,
//                 //   image: AssetImage(currentTemp.image.toString()),
//                 //   fit: BoxFit.fill,
//                 // ),
//                 Positioned(
//                   bottom: 50,
//                   right: 0,
//                   left: 0,
//                   child: Center(
//                       child: Column(
//                     children: [
//                       GlowText(
//                         currentTemp.current.toString(),
//                         style: const TextStyle(
//                             height: 0.1,
//                             fontSize: 100,
//                             fontWeight: FontWeight.bold),
//                       ),
//                       Text(currentTemp.name.toString(),
//                           style: const TextStyle(
//                             fontSize: 25,
//                           )),
//                       Text(currentTemp.day.toString(),
//                           style: const TextStyle(
//                             fontSize: 18,
//                           ))
//                     ],
//                   )),
//                 )
//               ],
//             ),
//           ),
//           const Divider(
//             color: Colors.white,
//           ),
//           const SizedBox(
//             height: 2,
//           ),
//           ExtraWeather(currentTemp)
//         ],
//       ),
//     );
//   }
// }

// class TodayWeather extends StatelessWidget {
//   const TodayWeather({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(left: 30, right: 30, top: 2),
//       child: Column(
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               const Text(
//                 "Aujourd'hui",
//                 style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
//               ),
//               GestureDetector(
//                 onTap: () {
//                   Navigator.push(context,
//                       MaterialPageRoute(builder: (BuildContext context) {
//                     return const DetailPage();
//                   }));
//                 },
//                 child: Row(
//                   children: const [
//                     Text(
//                       "7 jours ",
//                       style: TextStyle(fontSize: 18, color: Colors.grey),
//                     ),
//                     Icon(
//                       Icons.arrow_forward_ios_outlined,
//                       color: Colors.grey,
//                       size: 15,
//                     )
//                   ],
//                 ),
//               )
//             ],
//           ),
//           const SizedBox(
//             height: 15,
//           ),
//           Container(
//             margin: const EdgeInsets.only(
//               bottom: 10,
//             ),
//             child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   WeatherWidget(todayWeather[0]),
//                   WeatherWidget(todayWeather[1]),
//                   WeatherWidget(todayWeather[2]),
//                   WeatherWidget(todayWeather[3])
//                 ]),
//           )
//         ],
//       ),
//     );
//   }
// }

// class WeatherWidget extends StatelessWidget {
//   final Weather weather;
//   const WeatherWidget(this.weather, {Key? key}) : super(key: key);
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(15),
//       decoration: BoxDecoration(
//           border: Border.all(width: 0.2, color: Colors.white),
//           borderRadius: BorderRadius.circular(35)),
//       child: Column(
//         children: [
//           Text(
//             weather.current.toString() + "\u00B0",
//             style: const TextStyle(fontSize: 20),
//           ),
//           const SizedBox(
//             height: 5,
//           ),
//           // Image(
//           //   image: AssetImage(weather.image.toString()),
//           //   width: 50,
//           //   height: 50,
//           // ),
//           const SizedBox(
//             height: 5,
//           ),
//           Text(
//             weather.time.toString(),
//             style: const TextStyle(fontSize: 16, color: Colors.grey),
//           )
//         ],
//       ),
//     );
//   }
// }

// // import 'package:flutter/cupertino.dart';
// // import 'package:flutter/material.dart';
// // import 'package:flutter_glow/flutter_glow.dart';
// // import 'package:flutter_weather_app/data.dart';
// // import 'package:flutter_weather_app/pages/detail_page.dart';
// // import 'package:flutter_weather_app/widget/extra_weather.dart';

// // // Weather currentTemp = currentTemp;
// // // Weather tomorrowTemp = tomorrowTemp;
// // // List<Weather> todayWeather = todayWeather;
// // // List<Weather> sevenDays = sevenDays;

// // String lat = '48.85661';
// // String lon = '2.3522219';
// // String city = 'Paris';

// // class Home extends StatefulWidget {
// //   const Home({Key? key}) : super(key: key);

// //   @override
// //   _HomeState createState() => _HomeState();
// // }

// // class _HomeState extends State<Home> {
// //   // getData() async {
// //   //   fetchData(lat, lon, city).then((value) {
// //   //     currentTemp = value[0];
// //   //     todayWeather = value[1];
// //   //     tomorrowTemp = value[2];
// //   //     sevenDays = value[3];
// //   //     setState(() {});
// //   //   });
// //   // }

// //   @override
// //   void initState() {
// //     super.initState();
// //     //getData();
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: const Color(0xff030317),
// //       body: SizedBox(
// //         child: Column(
// //           children: const [
// //             CurrentWeather(),
// //             TodayWeather(),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }

// // class CurrentWeather extends StatefulWidget {
// //   const CurrentWeather({Key? key}) : super(key: key);

// //   @override
// //   _CurrentWeatherState createState() => _CurrentWeatherState();
// // }

// // class _CurrentWeatherState extends State<CurrentWeather> {
// //   @override
// //   Widget build(BuildContext context) {
// //     return GlowContainer(
// //       height: MediaQuery.of(context).size.height - 180,
// //       margin: const EdgeInsets.all(2),
// //       padding: const EdgeInsets.only(top: 20, left: 30, right: 30),
// //       glowColor: const Color(0xff00A1FF).withOpacity(0.5),
// //       borderRadius: const BorderRadius.only(
// //         bottomLeft: Radius.circular(60),
// //         bottomRight: Radius.circular(60),
// //       ),
// //       color: const Color(0xff00A1FF),
// //       spreadRadius: 4,
// //       child: Column(
// //         children: [
// //           Row(
// //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //             children: [
// //               const Icon(
// //                 CupertinoIcons.square_grid_2x2,
// //                 color: Colors.white,
// //               ),
// //               Row(
// //                 children: [
// //                   const Icon(
// //                     Icons.pin_drop_outlined,
// //                     color: Colors.white,
// //                   ),
// //                   Text(
// //                     " " + currentTemp.location.toString(),
// //                     style: const TextStyle(
// //                       fontWeight: FontWeight.bold,
// //                       fontSize: 30,
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //               const Icon(
// //                 Icons.more_vert,
// //                 color: Colors.white,
// //               ),
// //             ],
// //           ),
// //           Container(
// //             margin: const EdgeInsets.only(top: 10),
// //             padding: const EdgeInsets.all(5),
// //             decoration: BoxDecoration(
// //               border: Border.all(
// //                 width: 1,
// //                 color: Colors.white,
// //               ),
// //               borderRadius: BorderRadius.circular(30),
// //             ),
// //             child: const Text(
// //               'Actualiser',
// //               style: TextStyle(
// //                 fontWeight: FontWeight.bold,
// //               ),
// //             ),
// //           ),
// //           SizedBox(
// //             height: 300,
// //             child: Stack(
// //               children: [
// //                 Image(
// //                   height: 200,
// //                   image: AssetImage(
// //                     currentTemp.image.toString(),
// //                   ),
// //                   fit: BoxFit.fill,
// //                 ),
// //                 Positioned(
// //                   bottom: 0,
// //                   right: 0,
// //                   left: 0,
// //                   child: Center(
// //                     child: Column(
// //                       children: [
// //                         GlowText(
// //                           currentTemp.current.toString() + '\u00B0',
// //                           style: const TextStyle(
// //                             height: 0.1,
// //                             fontSize: 100,
// //                             fontWeight: FontWeight.bold,
// //                           ),
// //                         ),
// //                         const SizedBox(
// //                           height: 15,
// //                         ),
// //                         Text(
// //                           currentTemp.name.toString(),
// //                           style: const TextStyle(
// //                             fontSize: 25,
// //                           ),
// //                         ),
// //                         Text(
// //                           currentTemp.day.toString(),
// //                           style: const TextStyle(
// //                             fontSize: 18,
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                   ),
// //                 )
// //               ],
// //             ),
// //           ),
// //           const Divider(
// //             color: Colors.white54,
// //           ),
// //           const SizedBox(
// //             height: 10,
// //           ),
// //           ExtraWeather(currentTemp),
// //         ],
// //       ),
// //     );
// //   }
// // }

// // class TodayWeather extends StatefulWidget {
// //   const TodayWeather({Key? key}) : super(key: key);

// //   @override
// //   _TodayWeatherState createState() => _TodayWeatherState();
// // }

// // class _TodayWeatherState extends State<TodayWeather> {
// //   @override
// //   Widget build(BuildContext context) {
// //     return Padding(
// //       padding: const EdgeInsets.only(left: 30, top: 5, right: 30),
// //       child: Column(children: [
// //         Row(
// //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //           children: [
// //             const Text(
// //               "Aujourd'hui",
// //               style: TextStyle(
// //                 fontSize: 25,
// //                 fontWeight: FontWeight.bold,
// //               ),
// //             ),
// //             GestureDetector(
// //               onTap: () {
// //                 Navigator.push(context,
// //                     MaterialPageRoute(builder: (BuildContext context) {
// //                   return DetailPage(tomorrowTemp, sevenDay);
// //                 }));
// //               },
// //               child: Row(
// //                 children: const [
// //                   Text(
// //                     "7 jours",
// //                     style: TextStyle(fontSize: 18, color: Colors.grey),
// //                   ),
// //                   Icon(
// //                     Icons.arrow_forward_ios_outlined,
// //                     color: Colors.grey,
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           ],
// //         ),
// //         Row(
// //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //           children: [
// //             WeatherWidget(todayWeather[0]),
// //             WeatherWidget(todayWeather[1]),
// //             WeatherWidget(todayWeather[2]),
// //             WeatherWidget(todayWeather[3]),
// //           ],
// //         ),
// //       ]),
// //     );
// //   }
// // }

// // class WeatherWidget extends StatefulWidget {
// //   final Weather weather;
// //   const WeatherWidget(this.weather, {Key? key}) : super(key: key);

// //   @override
// //   State<WeatherWidget> createState() => _WeatherWidgetState();
// // }

// // class _WeatherWidgetState extends State<WeatherWidget> {
// //   @override
// //   Widget build(BuildContext context) {
// //     return Container(
// //       padding: const EdgeInsets.all(15),
// //       decoration: BoxDecoration(
// //           border: Border.all(width: 1, color: Colors.white),
// //           borderRadius: BorderRadius.circular(30)),
// //       child: Column(
// //         children: [
// //           Text(
// //             widget.weather.current.toString() + "\u00B0",
// //             style: const TextStyle(fontSize: 18),
// //           ),
// //           const SizedBox(
// //             height: 5,
// //           ),
// //           Image(
// //             image: AssetImage('assets/sunny.png'),
// //             // image: AssetImage(weather.image.toString()),
// //             width: 40,
// //             height: 40,
// //           ),
// //           Text(
// //             widget.weather.time.toString(),
// //             style: const TextStyle(fontSize: 16, color: Colors.grey),
// //           )
// //         ],
// //       ),
// //     );
// //   }
// // }
