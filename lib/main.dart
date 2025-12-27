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
  String selectedPartner = 'A';

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
      builder: (ctx) => AlertDialog(
        title: Text(index == null ? '💰 저축 기록' : '✏️ 기록 수정'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          SegmentedButton<String>(
            segments: const [ButtonSegment(value: 'A', label: Text('파트너 A')), ButtonSegment(value: 'B', label: Text('파트너 B'))],
            selected: {selectedPartner},
            onSelectionChanged: (val) => setState(() => selectedPartner = val.first),
          ),
          const SizedBox(height: 15),
          TextField(controller: _amtController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: '금액(원)', border: OutlineInputBorder())),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('취소')),
          ElevatedButton(onPressed: () {
            if (_amtController.text.isEmpty) return;
            setState(() {
              int amt = int.parse(_amtController.text);
              if (index != null) {
                records[index] = {'date': records[index]['date'], 'partner': selectedPartner, 'amount': amt};
              } else {
                records.insert(0, {'date': DateFormat('yyyy-MM-dd').format(DateTime.now()), 'partner': selectedPartner, 'amount': amt});
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
      backgroundColor: const Color(0xFFF2F4F5),
      appBar: AppBar(title: const Text('🏆 6,400만 원 챌린지'), centerTitle: true, actions: [
        IconButton(icon: const Icon(Icons.settings), onPressed: () {
          _goalController.text = goalAmount.toInt().toString();
          showDialog(context: context, builder: (ctx) => AlertDialog(
            title: const Text('목표 및 초기화'),
            content: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(controller: _goalController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: '목표 금액')),
              const SizedBox(height: 20),
              TextButton(onPressed: () { setState(() { records.clear(); goalAmount = 64000000; }); _saveData(); Navigator.pop(ctx); },
                child: const Text('전체 초기화(RESET)', style: TextStyle(color: Colors.red))),
            ]),
            actions: [ElevatedButton(onPressed: () { setState(() => goalAmount = double.parse(_goalController.text)); _saveData(); Navigator.pop(ctx); }, child: const Text('목표 수정'))],
          ));
        })
      ]),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [const BoxShadow(color: Colors.black12, blurRadius: 8)]),
            child: Column(children: [
              const Text('함께 모은 금액', style: TextStyle(color: Colors.grey)),
              Text('${NumberFormat('#,###').format(totalSum)}원', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.teal)),
              const SizedBox(height: 15),
              ClipRRect(borderRadius: BorderRadius.circular(10), child: LinearProgressIndicator(value: progress, minHeight: 12, color: Colors.orangeAccent)),
              const SizedBox(height: 10),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('A: ${NumberFormat('#,###').format(totalA)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                Text('${(progress * 100).toStringAsFixed(1)}%', style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('B: ${NumberFormat('#,###').format(totalB)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ])
            ]),
          ),
          const SizedBox(height: 20),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('📋 저축 히스토리', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ElevatedButton.icon(onPressed: () => _showInput(), icon: const Icon(Icons.add), label: const Text('기록'))
          ]),
          const SizedBox(height: 10),
          ...records.asMap().entries.map((e) => Card(
            child: ListTile(
              leading: CircleAvatar(child: Text(e.value['partner'])),
              title: Text('${NumberFormat('#,###').format(e.value['amount'])}원'),
              subtitle: Text(e.value['date']),
              trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                IconButton(icon: const Icon(Icons.edit, size: 20), onPressed: () => _showInput(index: e.key)),
                IconButton(icon: const Icon(Icons.delete, size: 20, color: Colors.red), onPressed: () { setState(() => records.removeAt(e.key)); _saveData(); }),
              ]),
            ),
          )).toList(),
        ]),
      ),
    );
  }
}
