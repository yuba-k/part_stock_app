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
  static const String baseUrl = "https://ss1.xrea.com/physicsnitk.s323.xrea.com/";
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
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

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
    try{
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
    }catch(e){
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text("通信エラー"))
      );
      return;
    }
  }

  Future<bool> updateQuantity(int id, int quantity) async {
    try{
      var response = await http.post(
        Uri.parse(ApiConfig.baseUrl+"update_quantity.php"),
        headers: {
          "Content-Type":"application/json",
          "X-Api-Key":apiKey,
        },
        body: jsonEncode({"id":id, "delta":quantity})
      );
      if(response.statusCode != 200){
        scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(content: Text("通信エラー"))
        );
        return false;
      }
      return true;
    }catch(e){
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text("通信エラー"))
      );
      return false;
    }
  }

  Future<bool> addPart(String name, int quantity) async {
    try{
      var response = await http.post(
        Uri.parse(ApiConfig.baseUrl+"add_part.php"),
        headers: {
          "Content-Type":"application/json",
          "X-Api-Key":apiKey,
        },
        body: jsonEncode({"name":name, "quantity":quantity})
      );
      if(response.statusCode != 200){
        scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(content: Text("通信エラー"))
        );
        return false;
      }
      return true;
    }catch(e){
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text("通信エラー"))
      );
      return false;
    }
  }

  Future<bool> deletePart(int id) async {
    try{
      var response = await http.post(
        Uri.parse(ApiConfig.baseUrl+"delete_part.php"),
        headers: {
          "Content-Type":"application/json",
          "X-Api-Key":apiKey,
        },
        body: jsonEncode({"id":id})
      );
      if(response.statusCode != 200){
        scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(content: Text("通信エラー"))
        );
        return false;
      }
      return true;
    }catch(e){
      scaffoldMessengerKey.currentState?.showSnackBar(
         SnackBar(content: Text("通信エラー"))
      );
      return false;
    }
  }

  Future<void> fetchUsageLog() async{
    try{
      var response = await http.get(
          Uri.parse(ApiConfig.baseUrl+"get_usage_log.php"),
          headers: {
            "X-Api-Key": apiKey
          },
        );
      if(response.statusCode != 200){
        scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(content: Text("通信エラー"))
        );
        return;
      }
      var data = jsonDecode(response.body);
      usage_log.clear();
      for(int i = 0; i<data.length;i++){
        usage_log.add(UsageLog.fromJson(data[i]));
      }
      setState(() {
      });
    }catch(e){
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text("通信エラー"))
      );
    }
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
      scaffoldMessengerKey: scaffoldMessengerKey,
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
                                    if(await addPart(part_name.text, int.parse(part_quantity.text))){
                                      await fetchParts();
                                    }
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
                  IconButton(
                    onPressed: () async {
                      await fetchUsageLog();
                      Navigator.push(
                        innerContext,
                        MaterialPageRoute(
                          builder:(context) => UsageLogPage(
                            usage_log: usage_log,
                            part_list: part_list
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.history),
                  )
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
                                if(await updateQuantity(part_list[index].id, delta)){
                                  await fetchParts();
                                }
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
                            if(await updateQuantity(part_list[index].id, 1)){
                              await fetchParts();
                            }
                        },
                        icon: Icon(Icons.exposure_plus_1)
                      ),
                      IconButton(
                        onPressed: () async{
                          if(part_list[index].quantity == 0){
                            
                          }else{
                            if(await updateQuantity(part_list[index].id, -1)){
                              await fetchParts();
                            }
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
                                      if(await deletePart(part_list[index].id)){
                                        await fetchParts();
                                      }
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

class UsageLogPage extends StatefulWidget{
  const UsageLogPage({super.key, required this.usage_log, required this.part_list});
  final List<UsageLog> usage_log;
  final List<Part> part_list;

  @override
  State<UsageLogPage> createState() => _UsageLogPage();
}

class _UsageLogPage extends State<UsageLogPage>{
  int? selectedPartId;

  List<UsageLog> getSortedLogsForPart(int partId){
    List<UsageLog> tmp = widget.usage_log.where((t) => t.part_id == partId).toList();
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

  ConsumptionSummary calculateSummary(int partId) {
    int totalConsumption = 0;
    int totalSupply = 0;
    for (UsageLog t in getSortedLogsForPart(partId)) {
      if(t.delta > 0){
        totalSupply += t.delta;
      } else if (t.delta < 0) {
        totalConsumption += -t.delta;
      }
    }
    return ConsumptionSummary(totalConsumption, totalSupply);
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title:const Text("使用履歴")),
      body : Column(
        children:[
          DropdownButton<int>(
            value: selectedPartId,
            hint: const Text("部品を選択"),
            items: widget.part_list.map((part) {
              return DropdownMenuItem<int>(
                value: part.id,
                child: Text(part.name),
              );
            }).toList(),
            onChanged: (newValue) {
              setState(() {
                selectedPartId = newValue;
              });
            },
          ),
          if (selectedPartId != null) Builder(
            builder: (context) {
              final series = calculateSummary(selectedPartId!);
              final cumulativeSeries = buildCumulativeSeries(selectedPartId!);
              final spots = <FlSpot> [
                for(int i = 0; i < cumulativeSeries.length; i++)
                  FlSpot(i.toDouble(), cumulativeSeries[i].value.toDouble())
              ];
              return Column(
                children: [
                  Text("総消費：${series.totalConsumption}/総供給：${series.totalSupply}"),
                  SizedBox(
                    height:300,
                    child:LineChart(
                      LineChartData(
                        lineBarsData: [
                          LineChartBarData(
                            spots: spots,
                            isCurved: true,
                            color: Colors.blue,
                            dotData: FlDotData(show: false),
                          ),
                        ],
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles:SideTitles(
                              showTitles: true,
                              getTitlesWidget:(value, meta){
                                int index = value.toInt();
                                if(index < 0 || index >= cumulativeSeries.length){
                                  return const Text("");
                                }
                                DateTime date = cumulativeSeries[index].key;
                                return Text("${date.month}/${date.day}");
                              }
                            )
                          )
                        )
                      ),
                    ),
                  ),
                ]
              );
            },
          )
        ]
      )      
    );
  }
}

class ConsumptionSummary {
  final int totalConsumption;
  final int totalSupply;

  ConsumptionSummary(this.totalConsumption, this.totalSupply);
}