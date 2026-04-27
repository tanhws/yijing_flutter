import 'dart:math';
import 'package:flutter/material.dart';
import '../../data/models/liu_shisigua_data.dart';
import '../../data/models/liuyao_model.dart';
import '../../data/services/liuyao_service.dart';

class HomeFragment extends StatefulWidget {
  const HomeFragment({super.key});

  @override
  State<HomeFragment> createState() => _HomeFragmentState();
}

class _HomeFragmentState extends State<HomeFragment> with SingleTickerProviderStateMixin {
  final LiuYaoService _service = LiuYaoService();
  
  // 硬币状态
  List<int> _coinResults = [0, 0, 0]; // 0=背, 1=正
  bool _isAnimating = false;
  int _throwCount = 0; // 已摇次数
  
  // 结果
  LiuYaoResult? _result;
  Map<String, Map<String, String>?>? _hexagrams;
  List<int> _changingPositions = [];
  
  // 动画控制器
  late AnimationController _animController;
  late Animation<double> _flipAnimation;
  
  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
    _animController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _isAnimating = false);
      }
    });
    
    _loadSavedResult();
  }

  Future<void> _loadSavedResult() async {
    final saved = await _service.loadResult();
    if (saved != null && saved.flag >= 6) {
      setState(() {
        _result = saved;
        _hexagrams = _service.getBothHexagrams(saved);
        _changingPositions = _service.getChangingYaoPositions(saved.dongyao);
        _throwCount = 6;
      });
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _throwCoins() async {
    if (_isAnimating || _throwCount >= 6) return;
    
    setState(() => _isAnimating = true);
    
    // 随机生成硬币结果
    final random = Random();
    setState(() {
      _coinResults = List.generate(3, (_) => random.nextInt(2));
    });
    
    // 播放动画
    await _animController.forward(from: 0);
    
    // 执行起卦
    final result = _service.divine();
    final hexagrams = _service.getBothHexagrams(result);
    final changing = _service.getChangingYaoPositions(result.dongyao);
    
    setState(() {
      _result = result;
      _hexagrams = hexagrams;
      _changingPositions = changing;
      _throwCount++;
    });
    
    // 保存结果
    await _service.saveResult(result);
    
    // 如果完成了6次，显示卦象信息
    if (_throwCount == 6) {
      _showHexagramDialog();
    }
  }

  void _reset() {
    setState(() {
      _throwCount = 0;
      _result = null;
      _hexagrams = null;
      _changingPositions = [];
      _coinResults = [0, 0, 0];
    });
    _service.clearResult();
  }

  void _showHexagramDialog() {
    if (_hexagrams == null || _hexagrams!['zhugua'] == null) return;
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('卦象结果'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHexagramInfo('主卦', _hexagrams!['zhugua']!),
            const SizedBox(height: 16),
            _buildHexagramInfo('变卦', _hexagrams!['biangua']!),
            const SizedBox(height: 16),
            if (_changingPositions.isNotEmpty)
              Text('动爻位置: ${_changingPositions.map((i) => i + 1).join(', ')}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  Widget _buildHexagramInfo(String title, Map<String, String> info) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$title：${info['guaxiang']}',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text('宫位：${info['gong']}'),
        Text('五行：${info['wuxin']}'),
        Text('世爻：${info['shiyao']} 应爻：${info['yingyao']}'),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('六爻起卦'),
        backgroundColor: Colors.amber[700],
        actions: [
          if (_throwCount > 0)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _reset,
              tooltip: '重新起卦',
            ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.amber[50]!, Colors.white],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),
              // 时间显示
              if (_result != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    '${_result!.dataTime}  ${_result!.dayInGanZhi}',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ),
              
              // 硬币区域
              Expanded(
                flex: 2,
                child: _buildCoinArea(),
              ),
              
              // 提示文字
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  _throwCount < 6 
                      ? '请摇第 ${_throwCount + 1} 次' 
                      : '起卦完成，点击卦名查看详情',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              
              // 六爻显示区
              Expanded(
                flex: 3,
                child: _buildHexagramArea(),
              ),
              
              // 按钮
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: _throwCount < 6 && !_isAnimating ? _throwCoins : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber[700],
                    padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                  ),
                  child: Text(
                    _throwCount >= 6 ? '重新起卦' : '摇硬币',
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCoinArea() {
    return AnimatedBuilder(
      animation: _flipAnimation,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            final isFlipped = _flipAnimation.value > (index * 0.3) && _flipAnimation.value < (index * 0.3 + 0.5);
            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateX(isFlipped ? 3.14159 : 0),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.amber[100],
                  border: Border.all(color: Colors.amber[700]!, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(2, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    _coinResults[index] == 1 ? '正' : '背',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber[800],
                    ),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildHexagramArea() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 主卦/变卦标签
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildLabel('主卦', Colors.blue),
                _buildLabel('动爻', Colors.red),
                _buildLabel('变卦', Colors.green),
              ],
            ),
            const SizedBox(height: 8),
            // 爻行显示
            Expanded(
              child: _result == null
                  ? const Center(child: Text('点击"摇硬币"开始起卦'))
                  : _buildYaoLines(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildYaoLines() {
    return Column(
      children: List.generate(6, (index) {
        final reversedIndex = 5 - index; // 从上爻开始显示
        final zhuguaYao = _result!.zhugua[reversedIndex];
        final bianguaYao = _result!.biangua[reversedIndex];
        final dongyaoMark = _result!.dongyao[reversedIndex];
        final isChanging = dongyaoMark == '2' || dongyaoMark == '3';
        
        return Container(
          height: 40,
          margin: const EdgeInsets.symmetric(vertical: 2),
          decoration: BoxDecoration(
            color: isChanging ? Colors.red[50] : Colors.grey[50],
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              // 主卦爻
              Expanded(
                child: Center(
                  child: Text(
                    zhuguaYao == '1' ? '━━━' : '━ ━',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.blue[700],
                    ),
                  ),
                ),
              ),
              // 动爻标记
              Container(
                width: 40,
                child: Center(
                  child: Text(
                    isChanging ? '⚡' : '',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              // 变卦爻
              Expanded(
                child: Center(
                  child: Text(
                    bianguaYao == '1' ? '━━━' : '━ ━',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.green[700],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
