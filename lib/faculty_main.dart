import 'dart:async';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wifi_info_plugin_plus/wifi_info_plugin_plus.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(MaterialApp(
    home: Facultymain(),
  ));
}

class Facultymain extends StatefulWidget {
  Facultymain();

  @override
  State<Facultymain> createState() => _FacultymainState();
}

class _FacultymainState extends State<Facultymain> {
  String deviceIp = '...';
  String routerIp = '...';
  String promptattend = "Start Attendance";
  bool Session_status = false;
  String sessioniddisp = "";
  String added_status = "";
  bool Error_cred=false;
  bool isButtonVisible=true;
  bool downloadstatus=false;
  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(fontSize: 16),
        ),
        backgroundColor: Colors.red,
      ),
    );
  }

  TextEditingController roll_no = TextEditingController();
  @override
  void initState() {
    super.initState();
    updateWifiInfo();
  }

  String getCurrentDateTime() {
    final currentDateTime = DateTime.now();
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(currentDateTime);
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
    print("Router IP:" + routerIp + "     IP:" + deviceIp);
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: EdgeInsetsDirectional.fromSTEB(30, 100, 30, 0),
              decoration: BoxDecoration(
                //color: Color(0xFFf1f5f8),
                gradient: LinearGradient(
                  colors: [Colors.blue.shade100,Colors.blue.shade50],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter
                )
              ),
              width: size.width,
              height: size.height*0.18,
              child: Text(
                "Hello User,",
                style: GoogleFonts.nunito(
                  color: Color(0xff172e75),
                  fontWeight: FontWeight.w700,
                  fontSize: 40,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                // color: Color(0xFFf1f5f8),
                // borderRadius: BorderRadius.only(
                //   topLeft: Radius.circular(15),
                //   topRight: Radius.circular(15),
                gradient: LinearGradient(
                  colors: [Colors.blue.shade50,Colors.lightBlue.shade50],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter
                ),
              ),
              height: size.height*0.82,
              margin: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
              padding: EdgeInsetsDirectional.all(20),
              child: Column(
                children: [
                  Center(
                    child: Container(
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Image.asset('asset/fianl.png', height: 65, width: 65,),
                              if (Session_status)
                                Image.asset('asset/icon1.png', height: 15, width: 15,)
                            ],
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                          ),
                          TextButton(
                            onPressed: () async {
                              if (Session_status == false) {
                                var facid_retriver = await SharedPreferences.getInstance();
                                var faculty_id = facid_retriver.getString('faculty_id');
                                String dateime = getCurrentDateTime();
                                print(faculty_id);
                                print(dateime);
                                final response = await http.post(
                                    Uri.parse("http://devworld159.pythonanywhere.com/start_session"),
                                    body: json.encode({
                                      'ip_address': routerIp,
                                      'faculty_id': faculty_id,
                                      'date_time': dateime
                                    })
                                );
                                if (response.statusCode == 200) {
                                  print("Session started successfully");
                                  final decoded = json.decode(response.body) as Map<String, dynamic>;
                                  print(decoded['session']);
                                  var sharprefs = await SharedPreferences.getInstance();
                                  sharprefs.setString('ssid', decoded['session']);
                                  setState(() {
                                    promptattend = "Stop Attendance";
                                    sessioniddisp = "   Session ID:" + decoded['session'];
                                    Session_status = true;
                                  });
                                }
                              } else {
                                var facid_retriver = await SharedPreferences.getInstance();
                                var faculty_id = facid_retriver.getString('faculty_id');
                                String dateime = getCurrentDateTime();
                                print(faculty_id);
                                print(dateime);
                                var sharedprf = await SharedPreferences.getInstance();
                                var ssidstored = sharedprf.getString('ssid');
                                print('====' + ssidstored!);
                                final response = await http.post(
                                    Uri.parse("http://devworld159.pythonanywhere.com/stop_session"),
                                    body: json.encode({
                                      'ip_address': routerIp,
                                      'session_id': ssidstored,
                                    })
                                );
                                if (response.statusCode == 200) {
                                  print("Session terminated successfully");
                                  final decoded = json.decode(response.body) as Map<String, dynamic>;
                                  print(decoded['session']);
                                  if (decoded['session'] == 'Stop') {
                                    setState(() async {
                                      promptattend = "Start Attendance";
                                      sessioniddisp = "";
                                      Session_status = false;
                                    });
                                  }
                                }
                              }
                            },
                            child: Text(promptattend,
                              style: GoogleFonts.nunito(
                                fontSize: 27,
                                color:Color(0xFF2c323a)// Color(0xFF183A7f),
                              ),
                            ),
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.resolveWith<Color>(
                                    (Set<MaterialState> states) {
                                  if (states.contains(MaterialState.pressed)) {
                                    return Colors.transparent;
                                  }
                                  return Colors.white;
                                },
                              ),
                            ),
                          ),
                          Text(sessioniddisp,
                            style: GoogleFonts.nunito(
                              fontSize: 16,
                              color: Color(0xFF2c323a),
                            ),
                          )
                        ],
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                      ),
                      alignment: Alignment.bottomLeft,
                      padding: EdgeInsetsDirectional.all(23),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade300,
                            blurRadius: 10,
                            blurStyle: BlurStyle.outer,
                          )
                        ],
                      ),
                      width: size.width * 0.88,
                      height: size.height * 0.23,
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade300,
                          blurRadius: 10,
                          blurStyle: BlurStyle.outer,
                        )
                      ],
                    ),
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Edit Student Attendance",
                          style: GoogleFonts.nunito(
                            fontSize: 20,
                            color: Color(0xFF2c323a)//0xFF183A7f),
                          ),
                        ),
                        TextField(
                          controller: roll_no,
                          decoration: InputDecoration(
                            hintText: "Enter Student ID",
                          ),
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            TextButton(
                              onPressed: () async {
                                var sharedprefs=await SharedPreferences.getInstance();
                                var sessionddetails=sharedprefs.getString('ssid');
                                if (roll_no.text.isNotEmpty && sessionddetails!="") {
                                  final response = await http.post(
                                      Uri.parse("http://devworld159.pythonanywhere.com/add_attendance"),
                                      body: json.encode({
                                        'roll_number': roll_no.text,
                                        'session_id': sessionddetails
                                      })
                                  );
                                  if (response.statusCode == 200) {
                                    final decoded = json.decode(response.body) as Map<String, dynamic>;
                                    if (decoded['status'] == 'attendance marked') {
                                      setState(() {
                                        added_status = "Student Attendance marked Successfully";
                                        roll_no.text="";
                                        Timer(Duration(seconds: 3), () {
                                          setState(() {
                                            added_status = "";
                                          });
                                        });
                                      });
                                    }
                                  }
                                }else {
                                  if(roll_no.text.isEmpty){
                                    setState(() {
                                      added_status = "Please Enter Student Registration number";
                                      Timer(Duration(seconds: 3), () {
                                        setState(() {
                                          added_status = "";
                                        });
                                      });
                                    });
                                  }
                                  else{
                                    setState(() {
                                      added_status = "Please Initiate a session";
                                      Timer(Duration(seconds: 3), () {
                                        setState(() {
                                          added_status = "";
                                        });
                                      });
                                    });
                                  }

                                }
                              },
                              child: Text("Add",
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                  ),
                              ),
                              style: ButtonStyle(
                                padding: MaterialStatePropertyAll<EdgeInsetsGeometry>(
                                  EdgeInsets.symmetric(horizontal: 40, vertical: 4),
                                ),
                                backgroundColor: MaterialStateProperty.all(Color(0xff1c3570)),
                                shape: MaterialStateProperty.all(RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                )),
                              ),
                            ),
                            TextButton(
                              onPressed: () async {
                                var sharedprefs=await SharedPreferences.getInstance();
                                var sessionddetails=sharedprefs.getString('ssid');
                                if (roll_no.text.isNotEmpty && sessionddetails!="") {
                                  final response = await http.post(
                                      Uri.parse("http://devworld159.pythonanywhere.com/remove_attendance"),
                                      body: json.encode({
                                        'roll_number': roll_no.text,
                                        'session_id': sessionddetails
                                      })
                                  );
                                  print("Resuqset sent");
                                  if (response.statusCode == 200) {
                                    final decoded = json.decode(response.body) as Map<String, dynamic>;
                                    if (decoded['status'] == 'removed') {
                                      setState(() {
                                        added_status = "Student Attendance removed Successfully";
                                        roll_no.text="";
                                        Timer(Duration(seconds: 3), () {
                                          setState(() {
                                            added_status = "";
                                          });
                                        });
                                      });
                                    }
                                    if(decoded['status']=='nf'){
                                      setState(() {
                                        Error_cred=true;
                                        added_status="No such record found";
                                        Timer(Duration(seconds: 3), () {
                                          setState(() {
                                            added_status = "";
                                            Error_cred=false;
                                          });
                                        });
                                      });
                                    }
                                  }
                                }
                                else {
                                  if(roll_no.text.isEmpty){
                                    setState(() {
                                      added_status = "Please Enter Student Registration number";
                                      Timer(Duration(seconds: 3), () {
                                        setState(() {
                                          added_status = "";
                                        });
                                      });
                                    });
                                  }
                                  else{
                                    setState(() {
                                      added_status = "Please Initiate a session";
                                      Timer(Duration(seconds: 3), () {
                                        setState(() {
                                          added_status = "";
                                        });
                                      });
                                    });
                                  }

                                }
                              },
                              child: Text("Remove",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                              style: ButtonStyle(
                                padding: MaterialStatePropertyAll<EdgeInsetsGeometry>(
                                  EdgeInsets.symmetric(horizontal: 40, vertical: 4),
                                ),
                                backgroundColor: MaterialStateProperty.all(Color(0xff1c3570)),
                                shape: MaterialStateProperty.all(RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                )),
                              ),
                            ),
                          ],
                        ),
                        if(Error_cred)
                          Center(
                            child: Text(added_status,
                              style: GoogleFonts.nunito(
                                fontSize: 15,
                                color: Colors.red,
                              ),
                            ),
                          )
                        else
                        Center(
                          child: Text(added_status,
                            style: GoogleFonts.nunito(
                              fontSize: 15,
                              color: Color(0xFF405090),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: 20,),
                  Center(
                    child: Container(
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Image.asset('asset/excellogo.png', height: 65, width: 65,),
                            ],
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                          ),
                          TextButton(
                            onPressed: () async {
                              var sharedprefs = await SharedPreferences.getInstance();
                              var sessionddetails = sharedprefs.getString('ssid');

                              if (sessionddetails != null && sessionddetails.isNotEmpty) {
                                setState(() {
                                  isButtonVisible = false; // Hide the button while downloading
                                });

                                try {
                                  final response = await http.post(
                                    Uri.parse("http://devworld159.pythonanywhere.com/download"),
                                    body: json.encode({'sessionid': sessionddetails}),
                                  );

                                  if (response != null) {
                                    if (response.statusCode == 200) {
                                      final header = response.headers['content-disposition'];
                                      final fileName = header != null
                                          ? RegExp('filename[^;=\n]*=((["\']).*?\\2|[^;\n]*)')
                                          .firstMatch(header!)
                                          ?.group(0)
                                          ?.replaceAll('filename=', '')
                                          ?.replaceAll('"', '')
                                          ?.trim() ??
                                          'file.csv'
                                          : 'file.csv';
                                      print(fileName);
                                      final String filePath =
                                          "/storage/emulated/0/Download/$fileName";
                                      final file = File(filePath);
                                      await file.writeAsBytes(response.bodyBytes);

                                      print("File downloaded successfully");
                                      downloadstatus = true;
                                      await Future.delayed(Duration(seconds: 1));
                                      setState(() async {
                                        isButtonVisible = true;
                                        if (downloadstatus) {
                                          print(fileName);
                                          final sendreq = await http.post(
                                            Uri.parse("http://devworld159.pythonanywhere.com/delete"),
                                            body: json.encode({'file': fileName}),
                                          );
                                          if (sendreq.statusCode == 200) {
                                            print("Deleted");
                                            downloadstatus = false;
                                          }
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Center(
                                                child: Text(
                                                  "Downloaded Successfully",
                                                  style: GoogleFonts.nunito(
                                                    color: Color(0xFF2c323a),
                                                  ),
                                                ),
                                              ),
                                              backgroundColor: Colors.green[800],
                                            ),
                                          );
                                        }
                                      });
                                    } else {
                                      // Handle HTTP error
                                      print('HTTP Error: ${response.statusCode}');
                                      if(!downloadstatus){
                                        showSnackBar("Unable to download. Please try again.");
                                      }

                                      setState(() {
                                        isButtonVisible=true;
                                      });
                                    }
                                  } else {
                                    // Handle no response from the server
                                    showSnackBar("No response from the server. Please try again.");
                                    setState(() {
                                      isButtonVisible=true;
                                    });
                                  }
                                } catch (e) {
                                  // Handle any other error that may occur during the download
                                  print("Error: $e");
                                  if(!downloadstatus){
                                    showSnackBar("An error occurred. Please try again.");
                                  }

                                  setState(() {
                                    isButtonVisible=true;
                                  });
                                }
                              } else {
                                // Handle session details not available
                                print("Session details not available");
                                showSnackBar("Session Details not Available");
                                setState(() {
                                  isButtonVisible=true;
                                });
                              }
                            },
                            child: isButtonVisible
                                ? Text(
                              "Export to Excel",
                              style: GoogleFonts.nunito(
                                fontSize: 27,
                                color: Color(0xFF2c323a),
                              ),
                            )
                                : Row(
                              children: [
                                SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.0,
                                  ),
                                ),
                                Text(
                                  "    Downloading",
                                  style: GoogleFonts.nunito(
                                    fontSize: 27,
                                    color: Color(0xFF2c323a),
                                  ),
                                )
                              ],
                            ), // Show a loading indicator while downloading
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.resolveWith<Color>(
                                    (Set<MaterialState> states) {
                                  if (states.contains(MaterialState.pressed)) {
                                    return Colors.transparent;
                                  }
                                  return Colors.white;
                                },
                              ),
                            ),
                          ),



                        ],
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                      ),
                      alignment: Alignment.bottomLeft,
                      padding: EdgeInsetsDirectional.all(23),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade300,
                            blurRadius: 10,
                            blurStyle: BlurStyle.outer,
                          )
                        ],
                      ),
                      width: size.width * 0.88,
                      height: size.height * 0.23,
                    ),
                  ),
                ],
              ),
            ),

          ],
        ),
      ),
    );
  }
}
