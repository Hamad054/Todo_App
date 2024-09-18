import 'package:flutter/material.dart';
import 'UI/UI/homescreen.dart';

void main() {
  runApp(const Todo(

  ));
}
class Todo extends StatelessWidget {
  const Todo({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title:'ToDo',
      home: Home(),
    );
  }
}

