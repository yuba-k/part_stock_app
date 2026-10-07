import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';

void main(){
  runApp(const MyApp());
}

class Part{
  final int id;
  final String name;
  int quantity;

  Part(this.id, this.name, this.quantity);

  factory Part.fromJson(Map<String, dynamic> json) {
    return Part(
      int.parse(json["id"].toString()),
      json["name"] as String,
      int.parse(json["quantity"].toString()),
    );
  }
}

class UsageLog{
  final int id;
  final int part_id;
  final String part_name;
  final int delta;
  final DateTime changed_at;

  UsageLog(this.id, this.part_id, this.part_name, this.delta, this.changed_at);

  factory UsageLog.fromJson(Map<String, dynamic> json){
    return UsageLog(
        int.parse(json["id"].toString()),
        int.parse(json["part_id"].toString()),
        json["part_name"] as String,
        int.parse(json["delta"].toString()),
        DateTime.parse(json["changed_at"].toString())
      );
  }
}

class ApiConfig {
  static const String baseUrl = "your-server-address";
}

class MyApp extends StatefulWidget{
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyApp();
}

class _MyApp extends State<MyApp>{
  List<Part> part_list = [];
  List<UsageLog> usage_log = [];
  TextEditingController part_name = TextEditingController();
  TextEditingController part_quantity = TextEditingController();
  String apiKey = "";

  @override
  void initState() {
    super.initState();
    loadApiKey().then((savedKey){
      setState((){
        apiKey = savedKey ?? "";
      });
      fetchParts();
    });
  }

  Future<void> fetchParts() async{
    var response = await http.get(
        Uri.parse(ApiConfig.baseUrl+"get_parts.php"),
        headers: {
          "X-Api-Key": apiKey
        },
      );
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
          "X-Api-Key":apiKey,
        },
        body: jsonEncode({"id":id, "delta":quantity})
      );
  }

  Future<void> addPart(String name, int quantity) async {
    var response = await http.post(
      Uri.parse(ApiConfig.baseUrl+"add_part.php"),
      headers: {
        "Content-Type":"application/json",
        "X-Api-Key":apiKey,
      },
      body: jsonEncode({"name":name, "quantity":quantity})
    );
  }

  Future<void> deletePart(int id) async {
    var response = await http.post(
      Uri.parse(ApiConfig.baseUrl+"delete_part.php"),
      headers: {
        "Content-Type":"application/json",
        "X-Api-Key":apiKey,
      },
      body: jsonEncode({"id":id})
    );
  }

  Future<void> fetchUsageLog() async{
    var response = await http.get(
        Uri.parse(ApiConfig.baseUrl+"get_usage_log.php"),
        headers: {
          "X-Api-Key": apiKey
        },
      );
    var data = jsonDecode(response.body);
    usage_log.clear();
    for(int i = 0; i<data.length;i++){
      usage_log.add(UsageLog.fromJson(data[i]));
    }
    setState(() {
    });
  }

  Future<String?> loadApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('api_key');
  }

  Future<void> saveApiKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('api_key', key);
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
                  ),
                  IconButton(
                    onPressed: () {
                      final controller = TextEditingController(text: apiKey);
                      showDialog(
                        context: innerContext,
                        builder: (dialogContext) => AlertDialog(
                          title: const Text("APIキー設定"),
                          content: TextField(
                            controller: controller,
                            obscureText: true,
                            decoration: const InputDecoration(labelText: "APIキー"),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(dialogContext),
                              child: const Text("キャンセル"),
                            ),
                            TextButton(
                              onPressed: () async {
                                await saveApiKey(controller.text);
                                setState(() {
                                  apiKey = controller.text;
                                });
                                Navigator.pop(dialogContext);
                                fetchParts();
                              },
                              child: const Text("保存"),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: const Icon(Icons.settings),
                  ),
                ],
            ),
            body: ListView.builder(
              itemCount: part_list.length,
              itemBuilder: (BuildContext innerContext, int index){
                return ListTile(
                  title:Text(part_list[index].name),
                  subtitle: GestureDetector(
                    onTap: () {
                      final controller = TextEditingController(
                        text: part_list[index].quantity.toString(),
                      );
                      showDialog(
                        context: innerContext,
                        builder: (dialogContext) => AlertDialog(
                          title: const Text("数量を編集"),
                          content: TextField(
                            controller: controller,
                            keyboardType: TextInputType.number,
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(dialogContext),
                              child: const Text("キャンセル"),
                            ),
                            TextButton(
                              onPressed: () async {
                                int newValue = int.parse(controller.text);
                                int delta = newValue - part_list[index].quantity;
                                await updateQuantity(part_list[index].id, delta);
                                await fetchParts();
                                Navigator.pop(dialogContext);
                              },
                              child: const Text("保存"),
                            ),
                          ],
                        ),
                      );
                    },
                    child: Text(part_list[index].quantity.toString()),
                  ),
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

class UsageLogPage extends StatelessWidget {
  final List<UsageLog> usage_log;
  
  UsageLogPage({super.key, required this.usage_log});

  List<UsageLog> getSortedLogsForPart(int partId){
    List<UsageLog> tmp = usage_log.where((t) => t.part_id == partId).toList();
    tmp.sort((a,b) => a.changed_at.compareTo(b.changed_at));
    return tmp;
  }

  List<MapEntry<DateTime, int>> buildCumulativeSeries(int partId) {
    List<MapEntry<DateTime, int>> result = [];
    int runningTotal = 0;
    for(UsageLog t in getSortedLogsForPart(partId)){
      runningTotal += t.delta;
      result.add(MapEntry(t.changed_at, runningTotal));
    }
    return result;
  }

  List<FlSpot> buildSpots(int partId) {
    List<MapEntry<DateTime, int>> series = buildCumulativeSeries(partId);
    List<FlSpot> spots = [];
    for (int i = 0; i < series.length; i++) {
      spots.add(
        FlSpot(i.toDouble(), series[i].value.toDouble())
      );
    }
    return spots;
  }

  @override
  Widget build(BuildContext context){
    return Scaffold();
  }
}