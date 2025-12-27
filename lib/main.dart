import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() => runApp(const MySavingsApp());

class MySavingsApp extends StatelessWidget {
  const MySavingsApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal, primary: Colors.teal),
        useMaterial3: true,
      ),
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
  final TextEditingController _amtEdit = TextEditingController();
  final TextEditingController _goalEdit = TextEditingController();
  String selectedPartner = 'A';

  @override
  void initState() {
    super.initState();
    _loadData(); // 앱 시작 시 저장된 데이터 불러오기
  }

  // 데이터 저장 및 불러오기 기능
  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      goalAmount = prefs.getDouble('goal') ?? 64000000;
      String? savedRecords = prefs.getString('records');
      if (savedRecords != null) {
        records = List<Map<String, dynamic>>.from(json.decode(savedRecords));
      }
    });
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('goal', goalAmount);
    await prefs.setString('records', json.encode(records));
  }

  void _showInput({int? index}) {
    if (index != null) {
      _amtEdit.text = records[index]['amount'].toString();
      selectedPartner = records[index]['partner'];
    } else {
      _amtEdit.clear();
      selectedPartner = 'A';
    }
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(index == null ? '💸 새로운 저축' : '✏️ 기록 수정'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          SegmentedButton<String>(
            segments: const [ButtonSegment(value: 'A', label: Text('파트너 A')), ButtonSegment(value: 'B', label: Text('파트너 B'))],
            selected: {selectedPartner},
            onSelectionChanged: (val) => setState(() => selectedPartner = val.first),
          ),
          const SizedBox(height: 15),
          TextField(controller: _amtEdit, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: '금액(원)', border: OutlineInputBorder())),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('취소')),
          ElevatedButton(onPressed: () {
            if (_amtEdit.text.isEmpty) return;
            setState(() {
              if (index != null) {
                records[index] = {'date': records[index]['date'], 'partner': selectedPartner, 'amount': int.parse(_amtEdit.text)};
              } else {
                records.insert(0, {'date': DateFormat('yyyy-MM-dd').format(DateTime.now()), 'partner': selectedPartner, 'amount': int.parse(_amtEdit.text)});
              }
            });
            _saveData();
            Navigator.pop(ctx);
          }, child: const Text('저장')),
        ],
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
      backgroundColor: const Color(0xFFF5F7F8),
      appBar: AppBar(
        title: const Text('✨ 6,400만 원 챌린지', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.settings), onPressed: () {
            _goalEdit.text = goalAmount.toInt().toString();
            showDialog(context: context, builder: (ctx) => AlertDialog(
              title: const Text('설정'),
              content: Column(mainAxisSize: MainAxisSize.min, children: [
                TextField(controller: _goalEdit, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: '목표 금액')),
                const SizedBox(height: 20),
                ElevatedButton(onPressed: () { setState(() { records.clear(); goalAmount = 64000000; }); _saveData(); Navigator.pop(ctx); },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red[50]), child: const Text('전체 초기화', style: TextStyle(color: Colors.red))),
              ]),
              actions: [ElevatedButton(onPressed: () { setState(() => goalAmount = double.parse(_goalEdit.text)); _saveData(); Navigator.pop(ctx); }, child: const Text('목표 수정'))],
            ));
          })
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          // 디자인이 강화된 대시보드
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]),
            child: Column(children: [
              const Text('우리 함께 모은 금액', style: TextStyle(color: Colors.grey, fontSize: 14)),
              const SizedBox(height: 5),
              Text('${NumberFormat('#,###').format(totalSum)}원', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.teal)),
              const SizedBox(height: 20),
              LinearProgressIndicator(value: progress, minHeight: 12, borderRadius: BorderRadius.circular(10), color: Colors.orangeAccent),
              const SizedBox(height: 10),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('A: ${NumberFormat('#,###').format(totalA)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
                Text('${(progress * 100).toStringAsFixed(1)}%', style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('B: ${NumberFormat('#,###').format(totalB)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
              ])
            ]),
          ),
          const SizedBox(height: 25),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('📋 저축 히스토리', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            FloatingActionButton.extended(onPressed: () => _showInput(), label: const Text('기록하기'), icon: const Icon(Icons.add), size: const Size(120, 45)),
          ]),
          const SizedBox(height: 15),
          // 내역 리스트
          ...records.asMap().entries.map((e) => Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: ListTile(
              leading: CircleAvatar(backgroundColor: e.value['partner'] == 'A' ? Colors.teal[50] : Colors.blueGrey[50], child: Text(e.value['partner'])),
              title: Text('${NumberFormat('#,###').format(e.value['amount'])}원', style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(e.value['date']),
              trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                IconButton(icon: const Icon(Icons.edit_outlined, size: 20), onPressed: () => _showInput(index: e.key)),
                IconButton(icon: const Icon(Icons.delete_outline, size: 20, color: Colors.redAccent), onPressed: () {
                  setState(() => records.removeAt(e.key)); _saveData();
                }),
              ]),
            ),
          )).toList(),
        ]),
      ),
    );
  }
}
