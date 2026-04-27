import 'package:flutter/material.dart';
import '../../data/models/liu_shisigua_data.dart';

class ProfileFragment extends StatefulWidget {
  const ProfileFragment({super.key});

  @override
  State<ProfileFragment> createState() => _ProfileFragmentState();
}

class _ProfileFragmentState extends State<ProfileFragment> {
  List<Map<String, String>> _hexagramList = [];
  String? _selectedHexagram;

  @override
  void initState() {
    super.initState();
    _loadHexagrams();
  }

  void _loadHexagrams() {
    _hexagramList = LiuShiSiGuaData.getAllHexagrams();
    if (_hexagramList.isNotEmpty) {
      setState(() {
        _selectedHexagram = _hexagramList[0]['guaxiang'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('示卦'),
        backgroundColor: const Color(0xFF8B4513),
      ),
      body: Container(
        color: const Color(0xFFFFF8DC),
        child: SafeArea(
          child: Column(
            children: [
              // 显示选中的卦象
              if (_selectedHexagram != null) _buildSelectedHexagram(),
              
              // 卦象列表
              Expanded(
                child: _buildHexagramList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedHexagram() {
    final hexagram = _hexagramList.firstWhere(
      (h) => h['guaxiang'] == _selectedHexagram,
      orElse: () => {},
    );
    
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF8B4513)),
      ),
      child: Column(
        children: [
          Text(
            hexagram['guaxiang'] ?? '',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF8B4513),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildInfoChip('宫', hexagram['gong'] ?? ''),
              const SizedBox(width: 8),
              _buildInfoChip('五行', hexagram['wuxin'] ?? ''),
              const SizedBox(width: 8),
              _buildInfoChip('世', hexagram['shiyao'] ?? ''),
              const SizedBox(width: 8),
              _buildInfoChip('应', hexagram['yingyao'] ?? ''),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFDEB887).withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$label: $value',
        style: const TextStyle(fontSize: 12),
      ),
    );
  }

  Widget _buildHexagramList() {
    return ListView.builder(
      itemCount: _hexagramList.length,
      itemBuilder: (context, index) {
        final hexagram = _hexagramList[index];
        final isSelected = hexagram['guaxiang'] == _selectedHexagram;
        
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          color: isSelected ? const Color(0xFFDEB887) : Colors.white,
          child: ListTile(
            leading: Text(
              _getBaGuaSymbol(hexagram['guaxiang'] ?? ''),
              style: const TextStyle(fontSize: 24),
            ),
            title: Text(
              hexagram['guaxiang'] ?? '',
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            subtitle: Text(
              '${hexagram['gong']}  ${hexagram['wuxin']}',
              style: const TextStyle(fontSize: 12),
            ),
            onTap: () {
              setState(() {
                _selectedHexagram = hexagram['guaxiang'];
              });
            },
          ),
        );
      },
    );
  }

  String _getBaGuaSymbol(String name) {
    if (name.contains('乾')) return '☰';
    if (name.contains('坤')) return '☷';
    if (name.contains('震')) return '☳';
    if (name.contains('巽')) return '☴';
    if (name.contains('坎')) return '☵';
    if (name.contains('离')) return '☲';
    if (name.contains('艮')) return '☶';
    if (name.contains('兑')) return '☱';
    return '☯';
  }
}
