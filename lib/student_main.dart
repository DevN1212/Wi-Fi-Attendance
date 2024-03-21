import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wifi_info_plugin_plus/wifi_info_plugin_plus.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(MaterialApp(
    home: Studentmain(),
  ));
}
class Studentmain extends StatefulWidget {
  Studentmain();

  @override
  State<Studentmain> createState() => _StudentmainState();
}

class _StudentmainState extends State<Studentmain> {
  String deviceIp = '...';
  String routerIp = '...';

  @override
  void initState() {
    super.initState();
    updateWifiInfo();
  }

  Future<void> updateWifiInfo() async {
    try {
      final wifiInfo = await WifiInfoPlugin.wifiDetails;
      setState(() {
        deviceIp = wifiInfo?.ipAddress ?? '...';
        routerIp = wifiInfo?.routerIp ?? '...';
      });
    } catch (e) {
      print("Error fetching WiFi info: $e");
    }

    // Schedule the next update
    Timer(Duration(seconds: 5), updateWifiInfo);
    print("Router IP:"+routerIp+"     IP:"+deviceIp);
  }
  final user=TextEditingController();
  String markstatus="";
  bool errorstat=false;
  @override
  Widget build(BuildContext context) {
    final Size size=MediaQuery.of(context).size;
    return Scaffold(
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Container(
              padding: EdgeInsetsDirectional.fromSTEB(30, 100, 30, 0),
              decoration: BoxDecoration(
                  color:Colors.blue.shade50
              ),
              height: size.height*0.3,
              width: size.width,
              child: Text(
                "Hello User,",
                style: GoogleFonts.nunito(
                    color: Color(0xFF253295),
                    fontWeight: FontWeight.bold,
                    fontSize: 40
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                //color: Color(0xFFf1f5f8),
                gradient: LinearGradient(
                  stops: [0.2,0.4,0.7,0.9],
                    colors: [Colors.blue.shade50,Colors.lightBlue.shade100,Colors.white24,Colors.blue.shade50],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomCenter
                ),
                borderRadius: BorderRadius.only(topLeft: Radius.circular(15),topRight: Radius.circular(15)),
              ),
              margin: EdgeInsetsDirectional.fromSTEB(0, size.height*0.18, 0, 0),
              padding: EdgeInsetsDirectional.fromSTEB(20, 0, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset('asset/attendance.png',scale: 2.5,),
                  SizedBox(height: 10,),
                  TextFormField(
                      controller: user,
                      decoration: InputDecoration(
                        hintText: "Enter session Id",
                        hintStyle: GoogleFonts.ubuntu(color: Colors.grey),
                        contentPadding: EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                        border: OutlineInputBorder(  // Use OutlineInputBorder for a border
                          borderRadius: BorderRadius.all(Radius.circular(10.0)), // Customize the border radius
                          borderSide: BorderSide(color: Colors.grey),  // Specify the border color
                        ),
                      )
                  ),
                  SizedBox(height: 10,),
                  TextButton(
                    onPressed: () async {
                      if (user.text.isNotEmpty) {
                        var sharpref = await SharedPreferences.getInstance();
                        String? stdid = sharpref.getString('student_id');
                        final response = await http.post(Uri.parse(''),
                          body: json.encode({
                            'ip': routerIp,
                            'ses': user.text,
                            'r': stdid,
                          }),
                        );
                        if (response.statusCode == 200) {
                          final decoded = json.decode(response.body) as Map<String, dynamic>;
                          if (decoded['status'] == 'attendance marked') {
                            setState(() {
                              markstatus = "Attendance marked";
                              Timer(Duration(seconds: 3), () {
                                setState(() {
                                  markstatus = "";
                                });
                              });
                            });
                          } else if (decoded['status'] == 'database does not exist') {
                            setState(() {
                              errorstat = true;
                              markstatus = "Enter Valid Session ID";
                              Timer(Duration(seconds: 3), () {
                                setState(() {
                                  markstatus = "";
                                });
                              });
                            });
                          } else if (decoded['status'] == 'iperror') {
                            setState(() {
                              errorstat = true;
                              markstatus = "Connect to the same WIFI network";
                              Timer(Duration(seconds: 3), () {
                                setState(() {
                                  markstatus = "";
                                });
                              });
                            });
                          }
                        }
                      } else {
                        setState(() {
                          errorstat = true;
                          markstatus = "Please enter Session ID";
                          Timer(Duration(seconds: 3), () {
                            setState(() {
                              markstatus = "";
                            });
                          });
                        });
                      }
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Color(0xff1c359f),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 7,horizontal: 60),
                      child: Text(
                        "Mark Attendance",
                        style: GoogleFonts.nunito(
                          fontSize: 17,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 10,),
                  if(errorstat)
                    Text(markstatus,
                    style:GoogleFonts.nunito(
                      fontSize: 20,
                      color: Colors.red,
                    ),),
                  if(!errorstat)
                    Text(markstatus,
                      style: GoogleFonts.nunito(
                        fontSize: 20,
                        color: Colors.green,
                      ),
                    ),
                ],
              ),
              height: size.height*0.82,
              width: size.width,
            )
          ],
        ),
      ),
    );
  }
}

