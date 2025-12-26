import 'package:flutter/material.dart';

void main() => runApp(const SavingsApp());

class SavingsApp extends StatelessWidget {
  const SavingsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '1년 저축 챌린지',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const SavingsDashboard(),
    );
  }
}

class SavingsDashboard extends StatefulWidget {
  const SavingsDashboard({super.key});

  @override
  State<SavingsDashboard> createState() => _SavingsDashboardState();
}

class _SavingsDashboardState extends State<SavingsDashboard> {
  // 목표 금액 설정
  final double goalTotal = 64000000;
  final double goalA = 40000000;
  final double goalB = 24000000;
  
  // 현재 저축액
  double currentA = 0;
  double currentB = 0;

  final TextEditingController _controllerA = TextEditingController();
  final TextEditingController _controllerB = TextEditingController();

  @override
  Widget build(BuildContext context) {
    double totalCurrent = currentA + currentB;
    double totalPercent = (totalCurrent / goalTotal).clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('💰 1년 저축 챌린지', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // 공동 목표 카드
            _buildTotalCard(totalPercent, totalCurrent),
            const SizedBox(height: 25),
            
            // A 섹션
            _buildIndividualCard("파트너 A (목표 4,000만)", currentA, goalA, Colors.blue, _controllerA, (val) {
              setState(() => currentA += val);
              _controllerA.clear();
            }),
            const SizedBox(height: 15),
            
            // B 섹션
            _buildIndividualCard("파트너 B (목표 2,400만)", currentB, goalB, Colors.green, _controllerB, (val) {
              setState(() => currentB += val);
              _controllerB.clear();
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalCard(double percent, double current) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          children: [
            const Text("우리 함께 모은 금액", style: TextStyle(fontSize: 18, color: Colors.grey)),
            const SizedBox(height: 10),
            Text("${(current / 10000).toStringAsFixed(0)}만 / 6,400만", 
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 160, height: 160,
                  child: CircularProgressIndicator(
                    value: percent,
                    strokeWidth: 12,
                    backgroundColor: Colors.grey[200],
                    color: Colors.orangeAccent,
                  ),
                ),
                Text("${(percent * 100).toStringAsFixed(1)}%", 
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIndividualCard(String label, double current, double goal, Color color, TextEditingController controller, Function(double) onAdd) {
    double percent = (current / goal).clamp(0.0, 1.0);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: percent,
              minHeight: 10,
              borderRadius: BorderRadius.circular(5),
              color: color,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: "금액 입력(원)",
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    double? val = double.tryParse(controller.text);
                    if (val != null) onAdd(val);
                  },
                  child: const Text("저축"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
