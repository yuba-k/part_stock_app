import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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

  @override
  void initState() {
    super.initState();
    fetchParts();
  }

  Future<void> fetchParts() async{
    var response = await http.get(Uri.parse("http://localhost:8000/test_site/get_parts.php"));
    var data = jsonDecode(response.body);
    for(int i = 0; i<data.length;i++){
      part_list.add(Part.fromJson(data[i]));
    }
    setState(() {
    });
  }

  void rewrite(int id, int quantity){
    Part part = part_list.firstWhere((t) => t.id == id, orElse: () => throw Exception("$id is unknown-id"));
    part.quantity = quantity;
  }

  @override
  Widget build(BuildContext context){
    return MaterialApp(
      home:Scaffold(
        appBar: AppBar(title: const Text("Part Stock App",)),
        body: ListView.builder(
          itemCount: part_list.length,
          itemBuilder: (BuildContext context, int index){
            return ListTile(
              title:Text(part_list[index].name),
              subtitle: Text(part_list[index].quantity.toString()),
            );
          }
        ),
      )
    );
  }
}