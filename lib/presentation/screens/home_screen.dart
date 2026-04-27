import 'package:flutter/material.dart';
import '../../data/services/iching_service.dart';
import '../../data/models/hexagram.dart';
import '../widgets/hexagram_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final IChingService _ichingService = IChingService();
  DivinationResult? _result;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('易经起卦'),
        centerTitle: true,
        backgroundColor: Colors.amber[800],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.amber[100]!, Colors.amber[50]!],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const SizedBox(height: 40),
                // 八卦展示
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: BaGua.all.map((b) => _buildBaGuaItem(b)).toList(),
                ),
                const SizedBox(height: 60),
                // 起卦按钮
                _buildDivinationButton(),
                const SizedBox(height: 40),
                // 结果展示
                if (_result != null) _buildResultCard(_result!),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBaGuaItem(BaGua baGua) {
    return Column(
      children: [
        Text(
          baGua.emoji,
          style: const TextStyle(fontSize: 32),
        ),
        const SizedBox(height: 4),
        Text(
          baGua.name,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildDivinationButton() {
    return GestureDetector(
      onTap: _performDivination,
      child: Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [Colors.amber[600]!, Colors.amber[900]!],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.amber.withOpacity(0.5),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '☰☷',
              style: TextStyle(fontSize: 48),
            ),
            SizedBox(height: 8),
            Text(
              '点击起卦',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _performDivination() {
    final result = _ichingService.divineByCoins();
    setState(() {
      _result = result;
    });
  }

  Widget _buildResultCard(DivinationResult result) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text(
              '卦象结果',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            HexagramWidget(
              hexagram: result.mainHexagram,
              showLines: true,
            ),
            const SizedBox(height: 16),
            Text(
              result.mainHexagram.name,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.amber,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${result.mainHexagram.fiveElements} | ${result.mainHexagram.palace}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            // 六爻列表
            const Text(
              '六爻',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: result.yaoList.reversed.map((yao) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: yao.isChanging ? Colors.red[100] : Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: yao.isChanging ? Colors.red : Colors.grey,
                    ),
                  ),
                  child: Text(
                    yao.name,
                    style: TextStyle(
                      color: yao.isChanging ? Colors.red[700] : Colors.black87,
                    ),
                  ),
                );
              }).toList(),
            ),
            if (result.changingHexagram != null) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              const Text(
                '变卦',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              HexagramWidget(
                hexagram: result.changingHexagram!,
                showLines: true,
              ),
              Text(
                result.changingHexagram!.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}