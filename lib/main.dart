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

  @override
  void initState() {
    super.initState();
    part_list.add(Part(1, "サーボモーター", 3));
    part_list.add(Part(2, "ネジ(M3x10)", 50));
    part_list.add(Part(3, "PLAフィラメント", 2));
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