import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:server_app/faculty_main.dart';
import 'package:server_app/firstscreen_selectuser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:server_app/student_main.dart';

class HomePage extends StatefulWidget {
  bool isFaculty=false;

  HomePage(bool Facultyornot){
    isFaculty=Facultyornot;
  }

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool saveLogin=false;

  var userid=TextEditingController();

  var pass=TextEditingController();

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                ClipPath(
                  clipper: DrawClip2(),
                  child: Container(
                    width: size.width,
                    height: size.height * 0.5,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xff3c7fde), Color(0xffFAFAFC)],
                        begin: Alignment.bottomCenter,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                ),
                ClipPath(
                  clipper: DrawClip(),
                  child: Container(
                    width: size.width,
                    height: size.height * 0.48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xff3c7fde), Color(0xffE9EAED)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(15, 30, 0, 0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(onPressed:(){ Backtofirst(context);},
                        icon: Icon(Icons.arrow_back_sharp),
                    iconSize: 25,
                    ),
                  ),
                )
              ],
            ),
            Align(
              alignment: Alignment.topLeft, // Align to the left
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "      Login",
                    style: GoogleFonts.ubuntu(
                      color: Color(0xFF1f6fcf),
                      fontSize: 35,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 15,),
                  Center(
                    child: Container(
                      width: 350,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadiusDirectional.all(Radius.circular(10)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey,
                            blurStyle: BlurStyle.outer,
                            blurRadius: 4,
                            offset: Offset(0,1.5),
                          )
                        ]
                      ),
                      // decoration: BoxDecoration(
                      //   borderRadius: BorderRadiusDirectional.circular(10),
                      //   border:Border.all(color:Color(0xff6a74ce),
                      //   )
                      // ),
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(topLeft: Radius.circular(10),topRight: Radius.circular(10)),
                              color: Colors.white,
                            ),
                            child: TextFormField(
                              controller: userid,
                                decoration: InputDecoration(
                                  hintText: "Username",
                                  hintStyle: GoogleFonts.ubuntu(color: Colors.grey),
                                  contentPadding: EdgeInsets.only(top: 15, bottom: 15),
                                  prefixIcon: Icon(Icons.person_outline, color: Colors.grey),
                                  border: UnderlineInputBorder(borderSide: BorderSide.none),
                                  )
                              ),
                            ),
                          Container(
                            height: 0.5,
                            decoration: BoxDecoration(
                              color: Colors.deepPurple[100],
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10),bottomRight: Radius.circular(10)),
                              color: Colors.white,
                            ),
                            child: TextFormField(
                              controller: pass,
                              obscureText: true,
                              decoration: InputDecoration(
                                  hintText: "Password",
                                  hintStyle: GoogleFonts.ubuntu(color: Colors.grey),
                                  contentPadding: EdgeInsets.only(top: 15, bottom: 15),
                                  prefixIcon: Icon(Icons.lock_outline, color: Colors.grey),
                                  border: UnderlineInputBorder(borderSide: BorderSide.none),
                                  )
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(width: 20,),
                        Checkbox(
                          value: saveLogin,
                          checkColor: Colors.white, // Color of the checkmark
                          fillColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
                            // Background color of the checkbox based on its state
                            if (states.contains(MaterialState.selected)) {
                              return Colors.blue; // Selected (checked) state
                            }
                            return Colors.transparent; // Unselected state
                          }),
                          splashRadius: 20,
                          onChanged: (savelogin) {
                            setState(() {
                              saveLogin = !(saveLogin);
                              print(savelogin);
                            });
                          },
                        ),

                        Text("Remember Me",
                          style: GoogleFonts.ubuntu(
                            color: Color(0xFF0e77cb),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      ],
                    ),
                  ),
                  Center(
                    child: TextButton(
                      onPressed: () async {
                        if (userid.text.isNotEmpty && pass.text.isNotEmpty) {
                          if (widget.isFaculty == true) {
                            print("Awaiting req sent");
                            final response = await http.post(
                              Uri.parse("http://devworld159.pythonanywhere.com/loginasfaculty"),
                              body: json.encode({'user': userid.text, 'pass': pass.text}),
                            );
                            print("Req sent");
                            if (response.statusCode == 200) {
                              final decoded = json.decode(response.body) as Map<String, dynamic>;
                              if (decoded['status'] == 'success') {
                                if (saveLogin) {
                                  var sharedprefs = await SharedPreferences.getInstance();
                                  sharedprefs.setBool('facultylogin_status', true);
                                  sharedprefs.setString('faculty_id', userid.text.toString());
                                }
                                Navigatetomainfaculty(context);
                              } else {
                                // Show an error message
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Center(child: Text('Login failed. Please check your credentials.')),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          } else {
                            final response = await http.post(
                              Uri.parse("http://devworld159.pythonanywhere.com/loginasstudent"),
                              body: json.encode({'user': userid.text, 'pass': pass.text}),
                            );
                            if (response.statusCode == 200) {
                              print("Inside student status 200");
                              final decoded = json.decode(response.body) as Map<String, dynamic>;
                              print("+++++++ " + decoded['status']);
                              if (decoded['status'] == 'success') {
                                print("Status:" + decoded['status']);
                                if (saveLogin) {
                                  var sharedprefs = await SharedPreferences.getInstance();
                                  sharedprefs.setBool('studentlogin_status', true);
                                  sharedprefs.setString('student_id', userid.text.toString());
                                }
                                Navigatetomainstudent(context);
                              } else {
                                // Show an error message
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Center(child: Text('Login failed. Please check your credentials.')),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          }
                        }
                      },
                      style: ButtonStyle(
                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                        ),
                        backgroundColor: MaterialStateProperty.resolveWith<Color>(
                              (Set<MaterialState> states) {
                            // Button color based on its state
                            if (states.contains(MaterialState.pressed)) {
                              return Color(0xff3c7fde).withOpacity(0.8); // Pressed state
                            }
                            return Color(0xff3c7fde); // Default state
                          },
                        ),
                      ),
                      child: Container(
                        height: 23,
                        width: 225,
                        child: Center(
                          child: Text(
                            "Login",
                            style: GoogleFonts.ubuntu(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      "Forgot your password?",
                      style: GoogleFonts.ubuntu(
                        color: Color(0xFF0e77cb),
                        fontWeight: FontWeight.bold,
                      ),
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

void Navigatetomainfaculty(context){
  Navigator.of(context).pushReplacement(
    MaterialPageRoute(builder: (context) => Facultymain())
  );
}

void Navigatetomainstudent(context){
  Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => Studentmain())
  );
}
void Backtofirst(context){
  Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => firstscreen())
  );
}
class DrawClip extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height * 0.50);
    path.cubicTo(size.width / 4, size.height, 3 * size.width / 4,
        size.height / 3, size.width, size.height * 0.8);
    path.lineTo(size.width, 0);
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}

class DrawClip2 extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height * 0.8);
    path.cubicTo(size.width / 4, size.height, 3 * size.width / 4,
        size.height / 2, size.width, size.height * 0.9);
    path.lineTo(size.width, 0);
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}