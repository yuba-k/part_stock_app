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
    part_list.clear();
    for(int i = 0; i<data.length;i++){
      part_list.add(Part.fromJson(data[i]));
    }
    setState(() {
    });
  }

  Future<void> updateQuantity(int id, int quantity) async{
    var response = await http.post(
        Uri.parse("http://localhost:8000/test_site/update_quantity.php"),
        headers: {
          "Content-Type":"application/json",
        },
        body: jsonEncode({"id":id, "delta":quantity})
      );
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
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () async{
                        await updateQuantity(part_list[index].id, 1);
                        await fetchParts();
                    },
                    icon: Icon(Icons.exposure_plus_1)
                  ),
                  IconButton(
                    onPressed: () async{
                      if(part_list[index].quantity == 0){
                        
                      }else{
                        await updateQuantity(part_list[index].id, -1);
                        await fetchParts();
                      }
                    },
                    icon: Icon(Icons.exposure_minus_1)),
                ],
              )
            );
          }
        ),
      )
    );
  }
}