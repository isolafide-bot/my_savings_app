import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() => runApp(const MySavingsApp());

class MySavingsApp extends StatelessWidget {
  const MySavingsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
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
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _goalController = TextEditingController();
  String selectedPartner = 'A';
  List<Map<String, dynamic>> records = [];

  void _saveRecord({int? index}) {
    if (_amountController.text.isEmpty) return;
    int? amount = int.tryParse(_amountController.text.replaceAll(',', ''));
    if (amount == null) return;

    setState(() {
      if (index != null) {
        records[index]['amount'] = amount;
        records[index]['partner'] = selectedPartner;
      } else {
        records.insert(0, {
          'date': DateFormat('yyyy-MM-dd').format(DateTime.now()),
          'partner': selectedPartner,
          'amount': amount,
        });
      }
      _amountController.clear();
    });
    Navigator.pop(context);
  }

  void _deleteRecord(int index) {
    setState(() => records.removeAt(index));
  }

  void _resetAll() {
    setState(() {
      records.clear();
      goalAmount = 64000000;
    });
  }

  void _showInputDialog({int? index}) {
    if (index != null) {
      _amountController.text = records[index]['amount'].toString();
      selectedPartner = records[index]['partner'];
    } else {
      _amountController.clear();
      selectedPartner = 'A';
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(index == null ? '새 저축 기록' : '기록 수정'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: selectedPartner,
              decoration: const InputDecoration(labelText: '파트너 선택'),
              items: ['A', 'B'].map((p) => DropdownMenuItem(value: p, child: Text('파트너 $p'))).toList(),
              onChanged: (val) => setState(() => selectedPartner = val!),
            ),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: '금액(원)'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
          ElevatedButton(onPressed: () => _saveRecord(index: index), child: const Text('저장')),
        ],
      ),
    );
  }

  void _showSettings() {
    _goalController.text = goalAmount.toInt().toString();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('목표 및 초기화 설정'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _goalController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: '목표 금액 설정(원)'),
            ),
            const SizedBox(height: 25),
            const Divider(),
            const SizedBox(height: 10),
            TextButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _showResetConfirm();
              },
              icon: const Icon(Icons.refresh, color: Colors.red),
              label: const Text('전체 데이터 초기화', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
          ElevatedButton(
            onPressed: () {
              if (_goalController.text.isNotEmpty) {
                setState(() => goalAmount = double.parse(_goalController.text));
              }
              Navigator.pop(context);
            },
            child: const Text('설정 저장'),
          ),
        ],
      ),
    );
  }

  void _showResetConfirm() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('데이터 초기화'),
        content: const Text('모든 저축 기록이 삭제됩니다. 정말 초기화할까요?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              _resetAll();
              Navigator.pop(context);
            },
            child: const Text('초기화 실행', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int totalA = records.where((r) => r['partner'] == 'A').fold(0, (sum, item) => sum + (item['amount'] as int));
    int totalB = records.where((r) => r['partner'] == 'B').fold(0, (sum, item) => sum + (item['amount'] as int));
    int totalSum = totalA + totalB;
    double progress = (goalAmount > 0) ? (totalSum / goalAmount).clamp(0.0, 1.0) : 0.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F4),
      appBar: AppBar(
        title: const Text('💰 저축 챌린지', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [IconButton(icon: const Icon(Icons.settings), onPressed: _showSettings)],
      ),
      body: ListView( // SingleChildScrollView 대신 ListView로 짤림 방지 강화
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text('우리 함께 모은 누적 금액', style: TextStyle(fontSize: 14, color: Colors.grey)),
                  const SizedBox(height: 5),
                  Text('${NumberFormat('#,###').format(totalSum)}원',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.teal)),
                  Text('목표: ${NumberFormat('#,###').format(goalAmount)}원', style: const TextStyle(fontSize: 12)),
                  const SizedBox(height: 20),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(width: 130, height: 130, child: CircularProgressIndicator(value: progress, strokeWidth: 10, color: Colors.orange)),
                      Column(
                        children: [
                          Text('A: ${NumberFormat('#,###').format(totalA)}', style: const TextStyle(fontSize: 10)),
                          Text('${(progress * 100).toStringAsFixed(1)}%', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                          Text('B: ${NumberFormat('#,###').format(totalB)}', style: const TextStyle(fontSize: 10)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('일자별 저축 내역', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ElevatedButton.icon(
                onPressed: () => _showInputDialog(),
                icon: const Icon(Icons.add),
                label: const Text('기록하기'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // 기록 목록 표 형태 구성
          if (records.isEmpty)
            const Padding(
              padding: EdgeInsets.all(40.0),
              child: Center(child: Text('아직 기록이 없습니다.\n우측 상단 버튼으로 추가해보세요!', textAlign: TextAlign.center)),
            )
          else
            ...records.asMap().entries.map((entry) {
              int idx = entry.key;
              var r = entry.value;
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: r['partner'] == 'A' ? Colors.teal[100] : Colors.orange[100],
                    child: Text(r['partner'], style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  title: Text('${NumberFormat('#,###').format(r['amount'])}원', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${records.length - idx}번 | ${r['date']}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(Icons.edit, size: 20), onPressed: () => _showInputDialog(index: idx)),
                      IconButton(icon: const Icon(Icons.delete, size: 20, color: Colors.redAccent), onPressed: () => _deleteRecord(idx)),
                    ],
                  ),
                ),
              );
            }).toList(),
          const SizedBox(height: 50), // 하단 여백 확보
        ],
      ),
    );
  }
}
