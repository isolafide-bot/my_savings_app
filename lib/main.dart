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
  final double goalAmount = 64000000;
  final TextEditingController _amountController = TextEditingController();
  String selectedPartner = 'A';

  // 저축 내역 데이터
  List<Map<String, dynamic>> records = [
    {'id': 1, 'date': '2024-07-29', 'partner': 'A', 'amount': 500000},
    {'id': 2, 'date': '2024-07-29', 'partner': 'B', 'amount': 400000},
  ];

  void _addSavings() {
    if (_amountController.text.isEmpty) return;
    setState(() {
      records.insert(0, {
        'id': records.length + 1,
        'date': DateFormat('YYYY-MM-dd').format(DateTime.now()),
        'partner': selectedPartner,
        'amount': int.parse(_amountController.text),
      });
      _amountController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    int totalA = records.where((r) => r['partner'] == 'A').fold(0, (prev, e) => prev + (e['amount'] as int));
    int totalB = records.where((r) => r['partner'] == 'B').fold(0, (prev, e) => prev + (e['amount'] as int));
    int totalSum = totalA + totalB;
    double progress = totalSum / goalAmount;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F7F6),
      appBar: AppBar(
        title: const Text('💰 1년 저축 챌린지', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView( // 세로 짤림 방지를 위해 스크롤 적용
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 상단 대시보드 (누적 금액 및 파트너별 합계)
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const Text('우리 함께 모은 금액', style: TextStyle(fontSize: 16, color: Colors.grey)),
                    const SizedBox(height: 10),
                    Text('${(totalSum / 10000).toStringAsFixed(0)}만 / ${(goalAmount / 10000).toStringAsFixed(0)}만',
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 150, height: 150,
                          child: CircularProgressIndicator(value: progress, strokeWidth: 12, color: Colors.orange, backgroundColor: Colors.grey[200]),
                        ),
                        Column(
                          children: [
                            Text('파트너 A 누적: ${NumberFormat('#,###').format(totalA)}원', style: const TextStyle(fontSize: 12)),
                            Text('${(progress * 100).toStringAsFixed(1)}%', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                            Text('파트너 B 누적: ${NumberFormat('#,###').format(totalB)}원', style: const TextStyle(fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // 입력 섹션
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('파트너 선택', style: TextStyle(fontWeight: FontWeight.bold)),
                        SegmentedButton<String>(
                          segments: const [
                            ButtonSegment(value: 'A', label: Text('파트너 A')),
                            ButtonSegment(value: 'B', label: Text('파트너 B')),
                          ],
                          selected: {selectedPartner},
                          onSelectionChanged: (val) => setState(() => selectedPartner = val.first),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _amountController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(border: OutlineInputBorder(), hintText: '금액 입력(원)'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: _addSavings,
                          style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20)),
                          child: const Text('저축'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // 일자별 저축 기록 표
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('일자별 저축 기록', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Table(
                      border: TableBorder(horizontalInside: BorderSide(color: Colors.grey[300]!)),
                      columnWidths: const {0: FixedColumnWidth(40), 1: FlexColumnWidth(), 2: FlexColumnWidth(), 3: FlexColumnWidth()},
                      children: [
                        const TableRow(
                          children: [
                            Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text('연번', style: TextStyle(fontWeight: FontWeight.bold))),
                            Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text('일자', style: TextStyle(fontWeight: FontWeight.bold))),
                            Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text('파트너', style: TextStyle(fontWeight: FontWeight.bold))),
                            Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text('저축금액', style: TextStyle(fontWeight: FontWeight.bold))),
                          ],
                        ),
                        ...records.map((r) => TableRow(
                          children: [
                            Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text('${r['id']}')),
                            Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text('${r['date']}')),
                            Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text('파트너 ${r['partner']}')),
                            Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text('${NumberFormat('#,###').format(r['amount'])}원')),
                          ],
                        )),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
