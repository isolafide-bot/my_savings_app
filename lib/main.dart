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
  double goalAmount = 64000000; // 기본 목표 금액
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _goalController = TextEditingController();
  String selectedPartner = 'A';
  List<Map<String, dynamic>> records = [];

  // 저축 추가 및 수정 기능
  void _saveRecord({int? index}) {
    if (_amountController.text.isEmpty) return;
    int amount = int.parse(_amountController.text.replaceAll(',', ''));

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

  // 삭제 기능
  void _deleteRecord(int index) {
    setState(() => records.removeAt(index));
  }

  // 초기화 기능 (RESET)
  void _resetAll() {
    setState(() {
      records.clear();
      goalAmount = 64000000;
    });
  }

  // 금액 입력 팝업 (추가/수정 공용)
  void _showInputDialog({int? index}) {
    if (index != null) {
      _amountController.text = records[index]['amount'].toString();
      selectedPartner = records[index]['partner'];
    } else {
      _amountController.clear();
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(index == null ? '새 저축 기록' : '기록 수정'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButton<String>(
              value: selectedPartner,
              isExpanded: true,
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

  // 설정 팝업 (목표 수정 및 리셋)
  void _showSettings() {
    _goalController.text = goalAmount.toInt().toString();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('설정'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _goalController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: '목표 금액 설정(원)'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red[50]),
              onPressed: () {
                _resetAll();
                Navigator.pop(context);
              },
              child: const Text('전체 데이터 초기화', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
          ElevatedButton(
            onPressed: () {
              setState(() => goalAmount = double.parse(_goalController.text));
              Navigator.pop(context);
            },
            child: const Text('목표 변경'),
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
    double progress = (totalSum / goalAmount).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FBFB),
      appBar: AppBar(
        title: const Text('💰 1년 저축 챌린지'),
        centerTitle: true,
        actions: [IconButton(icon: const Icon(Icons.settings), onPressed: _showSettings)],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 대시보드 카드
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text('우리 함께 모은 금액', style: TextStyle(color: Colors.grey[600])),
                    Text('${NumberFormat('#,###').format(totalSum)} / ${NumberFormat('#,###').format(goalAmount)}',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(width: 140, height: 140, child: CircularProgressIndicator(value: progress, strokeWidth: 10, color: Colors.teal)),
                        Column(
                          children: [
                            Text('A: ${NumberFormat('#,###').format(totalA)}', style: const TextStyle(fontSize: 10)),
                            Text('${(progress * 100).toStringAsFixed(1)}%', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
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
            // 기록 리스트
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('일자별 저축 기록', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ElevatedButton.icon(onPressed: () => _showInputDialog(), icon: const Icon(Icons.add), label: const Text('기록 추가')),
              ],
            ),
            const SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: records.length,
              itemBuilder: (context, index) {
                final r = records[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(child: Text(r['partner'])),
                    title: Text('${NumberFormat('#,###').format(r['amount'])}원'),
                    subtitle: Text(r['date']),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(icon: const Icon(Icons.edit, size: 20), onPressed: () => _showInputDialog(index: index)),
                        IconButton(icon: const Icon(Icons.delete, size: 20, color: Colors.redAccent), onPressed: () => _deleteRecord(index)),
                      ],
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
