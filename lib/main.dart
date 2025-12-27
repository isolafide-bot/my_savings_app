import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // 앱 종료 기능용
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io'; // 플랫폼 확인용

void main() => runApp(const MySavingsApp());

class MySavingsApp extends StatelessWidget {
  const MySavingsApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal), useMaterial3: true),
      home: const SavingsPage(),
    );
  }
}

class SavingsPage extends StatefulWidget {
  const SavingsPage({super.key});
  @override
  State<SavingsPage> createState() => _SavingsPageState();
}

class _SavingsPageState extends State<SavingsPage> {
  double goalAmount = 64000000;
  List<Map<String, dynamic>> records = [];
  final TextEditingController _amtController = TextEditingController();
  final TextEditingController _goalController = TextEditingController();
  String selectedPartner = 'A'; // 선택된 파트너 상태값

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      goalAmount = prefs.getDouble('goal_amt') ?? 64000000;
      String? saved = prefs.getString('savings_records');
      if (saved != null) records = List<Map<String, dynamic>>.from(json.decode(saved));
    });
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('goal_amt', goalAmount);
    await prefs.setString('savings_records', json.encode(records));
  }

  // 앱 종료 함수
  void _exitApp() {
    if (Platform.isAndroid) {
      SystemNavigator.pop();
    } else {
      exit(0);
    }
  }

  void _showInput({int? index}) {
    if (index != null) {
      _amtController.text = records[index]['amount'].toString();
      selectedPartner = records[index]['partner'];
    } else {
      _amtController.clear();
      selectedPartner = 'A';
    }

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder( // 다이얼로그 내 상태 변화를 위해 추가
        builder: (context, setDialogState) => AlertDialog(
          title: Text(index == null ? '💰 저축 기록' : '✏️ 기록 수정', style: const TextStyle(fontSize: 18)),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            ToggleButtons(
              isSelected: [selectedPartner == 'A', selectedPartner == 'B'],
              onPressed: (int i) {
                setDialogState(() => selectedPartner = (i == 0 ? 'A' : 'B'));
                setState(() {}); // 외부 상태도 동기화
              },
              borderRadius: BorderRadius.circular(8),
              constraints: const BoxConstraints(minWidth: 100, minHeight: 40),
              children: const [Text('파트너 A'), Text('파트너 B')],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _amtController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: '금액(원)', border: OutlineInputBorder()),
            ),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('취 x')),
            ElevatedButton(onPressed: () {
              if (_amtController.text.isEmpty) return;
              setState(() {
                int amt = int.parse(_amtController.text);
                if (index != null) {
                  records[index] = {'date': DateFormat('MM-dd').format(DateTime.now()), 'partner': selectedPartner, 'amount': amt};
                } else {
                  records.insert(0, {'date': DateFormat('MM-dd').format(DateTime.now()), 'partner': selectedPartner, 'amount': amt});
                }
              });
              _saveData();
              Navigator.pop(ctx);
            }, child: const Text('저장')),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int totalA = records.where((r) => r['partner'] == 'A').fold(0, (s, i) => s + (i['amount'] as int));
    int totalB = records.where((r) => r['partner'] == 'B').fold(0, (s, i) => s + (i['amount'] as int));
    int totalSum = totalA + totalB;
    double progress = (totalSum / goalAmount).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F5),
      appBar: AppBar(
        title: const Text('🏆 6,400만 챌린지', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.power_settings_new, color: Colors.red), onPressed: _exitApp), // 종료 버튼
          IconButton(icon: const Icon(Icons.settings), onPressed: () {
            _goalController.text = goalAmount.toInt().toString();
            showDialog(context: context, builder: (ctx) => AlertDialog(
              title: const Text('설정'),
              content: Column(mainAxisSize: MainAxisSize.min, children: [
                TextField(controller: _goalController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: '목표 금액')),
                const SizedBox(height: 20),
                TextButton(onPressed: () { setState(() { records.clear(); goalAmount = 64000000; }); _saveData(); Navigator.pop(ctx); },
                  child: const Text('전체 초기화', style: TextStyle(color: Colors.red))),
              ]),
              actions: [ElevatedButton(onPressed: () { setState(() => goalAmount = double.parse(_goalController.text)); _saveData(); Navigator.pop(ctx); }, child: const Text('수정'))],
            ));
          })
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(children: [
          // 대시보드
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: [const BoxShadow(color: Colors.black12, blurRadius: 5)]),
            child: Column(children: [
              Text('${NumberFormat('#,###').format(totalSum)} / ${NumberFormat('#,###').format(goalAmount)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal)),
              const SizedBox(height: 10),
              ClipRRect(borderRadius: BorderRadius.circular(5), child: LinearProgressIndicator(value: progress, minHeight: 8, color: Colors.orangeAccent)),
              const SizedBox(height: 8),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('A: ${NumberFormat('#,###').format(totalA)}', style: const TextStyle(fontSize: 11)),
                Text('${(progress * 100).toStringAsFixed(1)}%', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                Text('B: ${NumberFormat('#,###').format(totalB)}', style: const TextStyle(fontSize: 11)),
              ])
            ]),
          ),
          const SizedBox(height: 15),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('📋 저축 내역', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ElevatedButton.icon(onPressed: () => _showInput(), icon: const Icon(Icons.add, size: 16), label: const Text('기록', style: TextStyle(fontSize: 13)))
          ]),
          const SizedBox(height: 8),
          // 한 줄 요약 리스트 (Table 형식)
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: records.length,
              itemBuilder: (context, index) {
                final r = records[index];
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey[200]!))),
                  child: Row(
                    children: [
                      Text('${records.length - index}.', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                      const SizedBox(width: 8),
                      Text(r['date'], style: const TextStyle(fontSize: 11)),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: r['partner'] == 'A' ? Colors.teal[50] : Colors.orange[50], borderRadius: BorderRadius.circular(4)),
                        child: Text(r['partner'], style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: r['partner'] == 'A' ? Colors.teal : Colors.orange)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Text('${NumberFormat('#,###').format(r['amount'])}원', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold))),
                      IconButton(icon: const Icon(Icons.edit, size: 16), onPressed: () => _showInput(index: index), constraints: const BoxConstraints()),
                      IconButton(icon: const Icon(Icons.delete_outline, size: 16, color: Colors.redAccent), onPressed: () { setState(() => records.removeAt(index)); _saveData(); }, constraints: const BoxConstraints()),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 40),
        ]),
      ),
    );
  }
}
