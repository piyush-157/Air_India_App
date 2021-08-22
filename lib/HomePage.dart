import 'package:barcode_scan_fix/barcode_scan.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  String qrCodeResult="";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/airIndia.jpg"),
            fit: BoxFit.fill,
          ),
        ),
        child: Center(
          child: ElevatedButton(
            onPressed: () async {
              String docId = await BarcodeScanner.scan(); //barcode scanner

              //Navigator.of(context).pushNamed("Passengers");
              //Firebase
              setState(() {
                qrCodeResult = docId;
                print("Result : "+qrCodeResult);
              });
              FirebaseFirestore.instance.collection("passengers").doc(docId).get().then((value) async {
                var data = value.data();
                var id = value.id;
                if(value!=null)
                  {
                    print("name" + data["name"]);
                    SharedPreferences preferences = await SharedPreferences.getInstance();
                    preferences.setBool("isLogin", true);
                    preferences.setString("id", id);
                    preferences.setString("name", data["name"]);
                    Navigator.of(context).pop();
                    Navigator.of(context).pushNamed("Passengers");
                    Fluttertoast.showToast(
                        msg: "Ready to chat",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.blue,
                        textColor: Colors.white,
                        fontSize: 16.0
                    );
                  }
                else
                  {
                    Fluttertoast.showToast(
                        msg: "Invalid QR code",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.blue,
                        textColor: Colors.white,
                        fontSize: 16.0
                    );
                  }
              });
            },
            child: Text("Open Scanner"),
          ),
        ),
      ),
    );
  }
}
