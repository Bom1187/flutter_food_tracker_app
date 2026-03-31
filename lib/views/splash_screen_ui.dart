import 'package:flutter/material.dart';
import 'package:flutter_food_tracker_app/views/show_all_food_ui.dart';

class SplashScreenUi extends StatefulWidget {
  const SplashScreenUi({super.key});

  @override
  State<SplashScreenUi> createState() => _SplashScreenUiState();
}

class _SplashScreenUiState extends State<SplashScreenUi> {
  @override
  void initState() {
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ShowAllFoodUi()),
      );
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepOrange,
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/logo1.png',
                  width: 200,
                  height: 200,
                ),
                SizedBox(height: 20),
                Text(
                  'Food Tracker',
                  style: TextStyle(
                    color: Colors.yellow,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '🍕🍔🍟🌭🍿🥓',
                  style: TextStyle(
                    fontSize: 30,
                  ),
                ),
                SizedBox(height: 20),
                CircularProgressIndicator(color: Colors.yellow),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
