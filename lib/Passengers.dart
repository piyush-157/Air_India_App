import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PassengersList extends StatefulWidget {

  @override
  _PassengersListState createState() => _PassengersListState();
}

class _PassengersListState extends State<PassengersList> {

  String name = "";
  var senderId = "";
  var id = "";

  getName() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      name = preferences.getString("name");
      senderId = preferences.getString("id");
      getData(name,senderId);
    });
  }

  List<Widget> maindata = new List<Widget>();
  bool isloading=true;

  getData(name,senderId) async
  {
    var status="";
    var mainId="";
    List<Widget> temp = new List<Widget>();
     await FirebaseFirestore.instance.collection("passengers").where("name", isNotEqualTo: name).get().then((value){
      value.docs.forEach((element) async{
        id = element.id;
        await FirebaseFirestore.instance.collection("passengers").doc(senderId).collection("requests").where("userId",isEqualTo: element.id).get().then((v){
          if(v.size>0)
            {
              v.docs.forEach((e) async {
                mainId = e.id;
                status = e["status"];
                // SharedPreferences preferences = await SharedPreferences.getInstance();
                // preferences.setString("mainId", mainId);
                print("if");
              });
            }
          else
            {
              status="";
              print("else");
            }
          temp.add(
              Card(
                child: ListTile(
                  leading: FaIcon(
                    FontAwesomeIcons.user,
                    color: Colors.black,
                  ),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        element["name"].toString(),
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 18
                        ),
                      ),
                      SizedBox(
                        height: 3,
                      ),
                      Text(
                        element["company"].toString(),
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w300
                        ),
                      ),
                    ],
                  ),
                  subtitle: Text(
                    element["designation"].toString(),
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w200
                    ),
                  ),
                  trailing: (status=="approve")?
                    IconButton(
                      icon: FaIcon(FontAwesomeIcons.check),
                      onPressed: () {
                        Navigator.of(context).pushNamed("ChatScreen", arguments: {"id": element.id});
                      },
                      color: Colors.amber,
                    ):(status == "waiting")?
                    IconButton(
                      icon: FaIcon(FontAwesomeIcons.undo),
                      onPressed: () {
                        FirebaseFirestore.instance.collection("passengers").doc(senderId).collection("requests").doc(mainId).delete();

                        FirebaseFirestore.instance.collection("passengers").doc(element.id).collection("requests").where("userId",isEqualTo: senderId).get().then((va){
                          va.docs.forEach((ep) {
                            FirebaseFirestore.instance.collection("passengers").doc(element.id).collection("requests").doc(ep.id).delete();
                          });
                        });
                        getData(name, senderId);
                      },
                      color: Colors.red,
                    )
                      : (status=="pending")?
                    Wrap(
                      children: [
                        IconButton(
                          icon: FaIcon(FontAwesomeIcons.userCheck),
                          onPressed: () async{
                            FirebaseFirestore.instance.collection("passengers").doc(senderId).collection("requests").doc(mainId).update({
                              "status": "approve",
                            });

                            FirebaseFirestore.instance.collection("passengers").doc(element.id).collection("requests").where("userId",isEqualTo: senderId).get().then((va){
                              va.docs.forEach((ep) async{
                                FirebaseFirestore.instance.collection("passengers").doc(element.id).collection("requests").doc(ep.id).update({
                                  "status":"approve"
                                });
                              });
                            });
                            getData(name, senderId);
                          },
                          color: Colors.amber,
                        ),
                        IconButton(
                          icon: FaIcon(FontAwesomeIcons.userMinus),
                          onPressed: () {
                            FirebaseFirestore.instance.collection("passengers").doc(senderId).collection("requests").doc(mainId).delete();

                            FirebaseFirestore.instance.collection("passengers").doc(element.id).collection("requests").where("userId",isEqualTo: senderId).get().then((va){
                              va.docs.forEach((ep) {
                                FirebaseFirestore.instance.collection("passengers").doc(element.id).collection("requests").doc(ep.id).delete();
                              });
                            });
                            getData(name, senderId);
                          },
                          color: Colors.red,
                        ),
                      ],
                    ):(status=="reject")?
                    IconButton(
                      icon: FaIcon(FontAwesomeIcons.userMinus),
                      color: Colors.black,
                      onPressed: () {},
                    ):
                    IconButton(
                      icon: FaIcon(FontAwesomeIcons.plus),
                      color: Colors.black,
                      onPressed: () {
                        FirebaseFirestore.instance.collection("passengers").doc(senderId).collection("requests").add({
                          "userId": element.id,
                          "status": "waiting",
                        });

                        FirebaseFirestore.instance.collection("passengers").doc(element.id).collection("requests").add({
                          "userId": senderId,
                          "status": "pending",
                        });
                        getData(name, senderId);
                      },
                    ),
                ),
              ));
            });
        setState(() {
          maindata = temp;
        });
      });
      setState(() {
        isloading=false;
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getName();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          "Welcome " + name,
          style: TextStyle(
            color: Colors.black
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              getData(name, senderId);
            },
            icon: FaIcon(FontAwesomeIcons.undo),
            iconSize: 20,
            color: Colors.black,
          ),
          IconButton(
            color: Colors.black,
            onPressed: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.setBool("isLogin", false);
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed("HomePage");
              Fluttertoast.showToast(
                  msg: "Logged out successfully",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.blue,
                  textColor: Colors.white,
                  fontSize: 16.0
              );
            },
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      body: (isloading)?Center(child: CircularProgressIndicator()):ListView(
        children: maindata,
      ),
    );
  }
}
