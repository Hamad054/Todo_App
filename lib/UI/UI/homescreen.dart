import 'package:flutter/material.dart';
import 'package:todo/UI/UI/todoScreen.dart';



class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Todo_App',
          style: TextStyle(
            fontWeight: FontWeight.bold,

          ),
        ),

      ),
      body: Todoscreen(),

    );
  }
}

