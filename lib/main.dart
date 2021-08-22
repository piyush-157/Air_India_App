import 'package:air_india_app/ChatScreen.dart';
import 'package:air_india_app/HomePage.dart';
import 'package:air_india_app/Passengers.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'LoadingScreen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoadingScreen(),
      debugShowCheckedModeBanner: false,
      routes: {
        "HomePage": (BuildContext context) => HomePage(),
        "Passengers": (BuildContext context) => PassengersList(),
        "ChatScreen": (BuildContext context) => ChatScreen(),
      },
    );
  }
}