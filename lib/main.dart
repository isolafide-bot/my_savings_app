import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() => runApp(const MySavingsApp());

class MySavingsApp extends StatelessWidget {
  const MySavingsApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.teal, useMaterial3: true),
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
  final TextEditingController _amtEdit = TextEditingController();
  final TextEditingController _goalEdit = TextEditingController();
  String selectedPartner = 'A';
  List<Map<String, dynamic>> records = [];

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
        title: Text(index == null ? '저축 기록 추가' : '기록 수정'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          DropdownButtonFormField<String>(
            value: selectedPartner,
            items: ['A', 'B'].map((p) => DropdownMenuItem(value: p, child: Text('파트너 $p'))).toList(),
            onChanged: (v) => setState(() => selectedPartner = v!),
            decoration: const InputDecoration(labelText: '누가 저축하나요?'),
          ),
          TextField(controller: _amtEdit, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: '금액(원)')),
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
      appBar: AppBar(title: const Text('💰 1년 저축 챌린지'), actions: [
        IconButton(icon: const Icon(Icons.settings), onPressed: () {
          _goalEdit.text = goalAmount.toInt().toString();
          showDialog(context: context, builder: (ctx) => AlertDialog(
            title: const Text('설정'),
            content: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(controller: _goalEdit, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: '목표 금액(원)')),
              const Divider(height: 30),
              ElevatedButton(onPressed: () { setState(() { records.clear(); goalAmount = 64000000; }); Navigator.pop(ctx); },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red[50]), child: const Text('전체 초기화(RESET)', style: TextStyle(color: Colors.red))),
            ]),
            actions: [ElevatedButton(onPressed: () { setState(() => goalAmount = double.parse(_goalEdit.text)); Navigator.pop(ctx); }, child: const Text('목표 수정'))],
          ));
        })
      ]),
      body: SingleChildScrollView( // 세로 짤림 방지
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Card(child: Padding(padding: const EdgeInsets.all(20), child: Column(children: [
            const Text('우리 함께 모은 금액'),
            Text('${NumberFormat('#,###').format(totalSum)} / ${NumberFormat('#,###').format(goalAmount)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Stack(alignment: Alignment.center, children: [
              SizedBox(width: 120, height: 120, child: CircularProgressIndicator(value: progress, strokeWidth: 10, color: Colors.teal)),
              Column(children: [
                Text('A:${NumberFormat('#,###').format(totalA)}', style: const TextStyle(fontSize: 9)),
                Text('${(progress * 100).toStringAsFixed(1)}%', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Text('B:${NumberFormat('#,###').format(totalB)}', style: const TextStyle(fontSize: 9)),
              ])
            ])
          ]))),
          const SizedBox(height: 20),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('일자별 저축 기록', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ElevatedButton(onPressed: () => _showInput(), child: const Text('기록 추가'))
          ]),
          const SizedBox(height: 10),
          ...records.asMap().entries.map((e) => Card(child: ListTile(
            leading: CircleAvatar(child: Text(e.value['partner'])),
            title: Text('${NumberFormat('#,###').format(e.value['amount'])}원'),
            subtitle: Text('${records.length - e.key}번 | ${e.value['date']}'),
            trailing: Row(mainAxisSize: MainAxisSize.min, children: [
              IconButton(icon: const Icon(Icons.edit, size: 20), onPressed: () => _showInput(index: e.key)),
              IconButton(icon: const Icon(Icons.delete, size: 20, color: Colors.red), onPressed: () => setState(() => records.removeAt(e.key))),
            ]),
          ))).toList(),
        ]),
      ),
    );
  }
}
