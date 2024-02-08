import 'package:flutter/material.dart';
import 'firstscreen_selectuser.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: SplashScreen(), // Display the SplashScreen initially
  ));
}

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Perform any initialization tasks here if needed

    // Simulate a delay with Future.delayed to display the splash screen for a few seconds
    return FutureBuilder(
      future: Future.delayed(Duration(seconds: 3), () => true), // Adjust the duration as needed
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          // Once the future is complete (after the delay), navigate to the main application
          return firstscreen();
        } else {
          // While waiting, display the splash screen
          return Scaffold(
            body: Center(
              child:Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('asset/applogo.png',scale: 10,),
                  SizedBox(height: 25),
                  CircularProgressIndicator(color: Color(0xFF004894),)
                ],
              ), // You can customize the splash screen UI
            ),
          );
        }
      },
    );
  }
}

class MyAppMain extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Main Application Page"),
      ),
      body: Center(
        child: Text("Welcome to the Main Application!"),
      ),
    );
  }
}
