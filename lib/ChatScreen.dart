import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatScreen extends StatefulWidget {

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  var senderId;
  var receiverId;
  String name = "";
  String company = "";
  String designation = "";
  TextEditingController _message = TextEditingController();
  var mainId = "";
  var mainId1 = "";

  getData(id) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    senderId = preferences.getString("id");
    mainId = preferences.getString("mainId");
    mainId1 = preferences.getString("mainId1");
    FirebaseFirestore.instance.collection("passengers").doc(id).get().then((value) {
      setState(() {
        name = value["name"];
        company = value["company"];
        designation = value["designation"];
      });
    });
  }

  showAlert(context)
  {
    AlertDialog dialog = new AlertDialog(
      title: Text("Warning!"),
      content: Text("Are you sure you want to block this user?"),
      actions: [
        RaisedButton(
          onPressed: (){
            FirebaseFirestore.instance.collection("passengers").doc(senderId).collection("requests").doc(mainId).delete();

            FirebaseFirestore.instance.collection("passengers").doc(receiverId).collection("requests").where("userId",isEqualTo: senderId).get().then((va){
              va.docs.forEach((ep) async{
                SharedPreferences preferences = await SharedPreferences.getInstance();
                preferences.setString("mainId1", ep.id);
                FirebaseFirestore.instance.collection("passengers").doc(receiverId).collection("requests").doc(mainId1).update({
                  "status":"approve"
                });
              });
            });
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          },
          color: Colors.green,
          textColor: Colors.white,
          child: Text("Yes"),
        ),
        RaisedButton(
          onPressed: (){
            Navigator.of(context).pop();
          },
          color: Colors.red,
          textColor: Colors.white,
          child: Text("No"),
        )
      ],
    );

    showDialog(
        context: context,
        builder: (BuildContext context){
          return dialog;
        }
    );

  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration.zero, (){
      Map args = ModalRoute.of(context).settings.arguments;
      if(args != null)
        {
          setState(() {
            receiverId = args["id"];
            getData(receiverId);
          });
        }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: AppBar(
          iconTheme: IconThemeData(color: Colors.black),
          elevation: 0,
          backgroundColor: Colors.transparent,
          actions: [
            IconButton(
              icon: Icon(Icons.block),
              color: Colors.red,
              onPressed: () {
                showAlert(context);
              },
            ),
          ],
          title: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FaIcon(
                FontAwesomeIcons.user,
                color: Colors.black,
              ),
              SizedBox(
                width: 9,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: TextStyle(color: Colors.black),),
                  Text(
                    designation,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w300
                    ),
                  ),
                  Text(
                    company,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      fontWeight: FontWeight.w200
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              (receiverId != "" && senderId != "")?Flexible(
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance.collection("passengers").doc(senderId).collection(receiverId).orderBy("timestamp", descending: true).snapshots(),
                  builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
                    if(!snapshot.hasData)
                      {
                        return Center(
                          child: SpinKitFadingCube(
                            color: Colors.blue,
                            size: 70,
                          ),
                        );
                      }
                    if(snapshot.data.docs.length<=0)
                      {
                        return Center(
                          child: Text("No Messages yet..."),
                        );
                      }
                    return ListView.builder(
                      reverse: true,
                      itemCount: snapshot.data.docs.length,
                      itemBuilder: (context, position){
                        var sender = snapshot.data.docs[position]["sender"].toString();
                        if(sender == senderId)
                          {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Card(
                                  elevation: 5,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  color: Colors.blue,
                                  child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        snapshot.data.docs[position]["message"].toString(),
                                        style: TextStyle(
                                          color: Colors.white,
                                        ),
                                      )
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                              ],
                            );
                          }
                        else
                          {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 10,
                                ),
                                Card(
                                  elevation: 5,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  color: Colors.white,
                                  child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        snapshot.data.docs[position]["message"].toString(),
                                        style: TextStyle(
                                          color: Colors.black,
                                        ),
                                      )
                                  ),
                                )
                              ],
                            );
                          }
                      },
                    );
                  },
                ),
              ): Text("Error..."),
              Padding(
                padding: EdgeInsets.all(8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      child: Row(
                        children: [
                          Flexible(
                            child: Container(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: TextField(
                                  onSubmitted: (value){},
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                  ),
                                  controller: _message,
                                  decoration: InputDecoration.collapsed(
                                    hintText: 'Type your message...',
                                    hintStyle: TextStyle(color: Colors.grey),
                                    focusColor: Colors.blue,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.send),
                            onPressed: () {
                              var message = _message.text.toString();
                              var timeStamp = DateTime.now().millisecondsSinceEpoch;

                              FirebaseFirestore.instance.collection("passengers").doc(senderId).collection(receiverId).add({
                                "sender": senderId,
                                "receiver": receiverId,
                                "message": message,
                                "timestamp": timeStamp,
                                "isRead": false,
                              });

                              FirebaseFirestore.instance.collection("passengers").doc(receiverId).collection(senderId).add({
                                "sender": senderId,
                                "receiver": receiverId,
                                "message": message,
                                "timestamp": timeStamp,
                                "isRead": false,
                              });

                              _message.clear();
                            },
                            color: Colors.blue,
                          ),
                        ],
                      ),
                      width: double.infinity,
                      height: 50.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            width: 0.4
                          // top: BorderSide(color: Colors.grey, width: 0.5)
                        ),
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
