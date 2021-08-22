import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoadingScreen extends StatefulWidget {

  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {

  checkPrefs() async
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(prefs.containsKey("isLogin"))
    {
      Future.delayed(Duration(seconds: 1), () {
        if(prefs.getBool("isLogin")==true)
        {
          Navigator.of(context).pop();
          Navigator.of(context).pushNamed("Passengers");
        }
        else
        {
          Navigator.of(context).pop();
          Navigator.of(context).pushNamed("HomePage");
        }
      });
    }
    else
    {
      Future.delayed(Duration(seconds: 2), () {
        Navigator.of(context).pop();
        Navigator.of(context).pushNamed("HomePage");
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkPrefs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SpinKitFadingCube(
          color: Colors.blue,
          size: 70,
        ),
      ),
    );
  }
}
