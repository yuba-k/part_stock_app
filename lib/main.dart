import 'package:flutter/material.dart';

void main(){
  runApp(const MyApp());
}

class Part{
  final int id;
  final String name;
  int quantity;

  Part(this.id, this.name, this.quantity);

  factory Part.fromJson(Map<String, dynamic>json){
    return Part(json["id"] as int, json["name"] as String, json["quantity"] as int);
  }
}

class MyApp extends StatefulWidget{
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyApp();
}

class _MyApp extends State<MyApp>{
  List<Part> part_list = [];

  void rewrite(int id, int quantity){
    Part part = part_list.firstWhere((t) => t.id == id, orElse: () => throw Exception("$id is unknown-id"));
    part.quantity = quantity;
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(

    );
  }
}