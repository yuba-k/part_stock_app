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

class ApiConfig {
  static const String baseUrl = "http://localhost:8000/test_site/";
}

class MyApp extends StatefulWidget{
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyApp();
}

class _MyApp extends State<MyApp>{
  List<Part> part_list = [];
  TextEditingController part_name = TextEditingController();
  TextEditingController part_quantity = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchParts();
  }

  Future<void> fetchParts() async{
    var response = await http.get(Uri.parse(ApiConfig.baseUrl+"get_parts.php"));
    var data = jsonDecode(response.body);
    part_list.clear();
    for(int i = 0; i<data.length;i++){
      part_list.add(Part.fromJson(data[i]));
    }
    setState(() {
    });
  }

  Future<void> updateQuantity(int id, int quantity) async {
    var response = await http.post(
        Uri.parse(ApiConfig.baseUrl+"update_quantity.php"),
        headers: {
          "Content-Type":"application/json",
        },
        body: jsonEncode({"id":id, "delta":quantity})
      );
  }

  Future<void> addPart(String name, int quantity) async {
    var response = await http.post(
      Uri.parse(ApiConfig.baseUrl+"add_part.php"),
      headers: {
        "Content-Type":"application/json",
      },
      body: jsonEncode({"name":name, "quantity":quantity})
    );
  }

  Future<void> deletePart(int id) async {
    var response = await http.post(
      Uri.parse(ApiConfig.baseUrl+"delete_part.php"),
      headers: {
        "Content-Type":"application/json",
      },
      body: jsonEncode({"id":id})
    );
  }

  @override
  Widget build(BuildContext innerContext){
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home:Builder(
        builder: (BuildContext innerContext) {
          return Scaffold(
            appBar: AppBar(
              title: const Text("Part Stock App",),
              actions: [
                IconButton(
                    onPressed: (){
                      showDialog(
                          context: innerContext,
                          builder: (BuildContext innerContext){
                            return AlertDialog(
                              title: const Text("部品を追加"),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextField(decoration: InputDecoration(labelText: "部品名"), controller: part_name,),
                                  TextField(decoration: InputDecoration(labelText: "初期数量"), controller: part_quantity,),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(innerContext);
                                  },
                                  child: const Text("キャンセル")
                                ),
                                TextButton(
                                  onPressed: () async {
                                    await addPart(part_name.text, int.parse(part_quantity.text));
                                    await fetchParts();
                                    part_name.clear();
                                    part_quantity.clear();
                                    Navigator.pop(innerContext);
                                  }, child: const Text("追加")
                                ),
                              ],
                            );
                          }
                        );
                    },
                    icon: Icon(Icons.add)
                  )
                ],
            ),
            body: ListView.builder(
              itemCount: part_list.length,
              itemBuilder: (BuildContext innerContext, int index){
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
                        icon: Icon(Icons.exposure_minus_1)
                      ),
                      IconButton(
                        onPressed: () {
                          showDialog(
                            context: innerContext,
                            builder: (BuildContext innerContext){
                              return AlertDialog(
                                title: const Text("部品を削除"),
                                actions: [
                                  TextButton(
                                    onPressed: () async {
                                      await deletePart(part_list[index].id);
                                      await fetchParts();
                                      Navigator.pop(innerContext);
                                    },
                                    child: const Text("はい")
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(innerContext);
                                    },
                                    child: const Text("いいえ"),
                                  )
                                ],
                              );
                            }
                          );
                        },
                        icon: Icon(Icons.delete)
                      )
                    ],
                  )
                );
              }
            ),
          );
        }
      )
    );
  }
}