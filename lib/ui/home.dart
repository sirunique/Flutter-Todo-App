import "package:flutter/material.dart";
import './todo_screen.dart';
class Home extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text("ToDo"),
        backgroundColor: Colors.black54,
      ),
      body: ToDoScreen(),
    );
  }
}
