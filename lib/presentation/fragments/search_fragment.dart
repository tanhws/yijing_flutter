import 'package:flutter/material.dart';
import '../../data/models/liu_shisigua_data.dart';
import '../../data/services/liuyao_service.dart';

class SearchFragment extends StatefulWidget {
  const SearchFragment({super.key});

  @override
  State<SearchFragment> createState() => _SearchFragmentState();
}

class _SearchFragmentState extends State<SearchFragment> {
  final LiuYaoService _service = LiuYaoService();
  
  String _inputText = '';
  Map<String, String>? _hexagramInfo;
  
  // 爻辞显示
  String _yiYao = '';
  String _erYao = '';
  String _sanYao = '';
  String _siYao = '';
  String _wuYao = '';
  String _liuYao = '';

  void _addYao(String value) {
    if (_inputText.length >= 6) return;
    
    setState(() {
      _inputText += value;
      _hexagramInfo = null;
    });
  }

  void _deleteLast() {
    if (_inputText.isEmpty) return;
    
    setState(() {
      _inputText = _inputText.substring(0, _inputText.length - 1);
      _hexagramInfo = null;
      _yiYao = _erYao = _sanYao = _siYao = _wuYao = _liuYao = '';
    });
  }

  void _confirm() {
    if (_inputText.length != 6) return;
    
    final info = _service.getHexagramInfo(_inputText);
    if (info != null) {
      setState(() {
        _hexagramInfo = info;
        // 获取爻辞
        final yaoCi = LiuShiSiGuaData.getYaoCi(_inputText);
        if (yaoCi != null) {
          _yiYao = yaoCi['one'] ?? '';
          _erYao = yaoCi['two'] ?? '';
          _sanYao = yaoCi['three'] ?? '';
          _siYao = yaoCi['four'] ?? '';
          _wuYao = yaoCi['five'] ?? '';
          _liuYao = yaoCi['six'] ?? '';
        }
      });
    }
  }

  void _reset() {
    setState(() {
      _inputText = '';
      _hexagramInfo = null;
      _yiYao = _erYao = _sanYao = _siYao = _wuYao = _liuYao = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('查卦'),
        backgroundColor: const Color(0xFF8B4513),
      ),
      body: Container(
        color: const Color(0xFFFFF8DC),
        child: SafeArea(
          child: Column(
            children: [
              // 顶部卦名显示
              _buildHeaderArea(),
              
              // 输入区域
              _buildInputArea(),
              
              // 爻象显示
              Expanded(
                child: _buildHexagramDisplay(),
              ),
              
              // 爻辞显示
              if (_hexagramInfo != null) _buildYaoCiArea(),
              
              // 按钮
              _buildBottomButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderArea() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      color: const Color(0xFFDEB887),
      child: Column(
        children: [
          Text(
            _hexagramInfo?['guaxiang'] ?? '请输入卦象',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: _hexagramInfo != null ? const Color(0xFF8B4513) : Colors.grey,
            ),
          ),
          if (_hexagramInfo != null)
            Text(
              '${_hexagramInfo!['gong']}  ${_hexagramInfo!['wuxin']}',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(8),
      color: Colors.white,
      child: Row(
        children: [
          // 输入显示框
          Expanded(
            child: Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF8B4513)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  _inputText.isEmpty ? '请输入卦象' : _inputText,
                  style: TextStyle(
                    fontSize: 20,
                    letterSpacing: 8,
                    color: _inputText.isEmpty ? Colors.grey : Colors.black,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          
          // 阴按钮
          ElevatedButton(
            onPressed: () => _addYao('0'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF8B4513),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            child: const Text('阴', style: TextStyle(fontSize: 16)),
          ),
          const SizedBox(width: 4),
          
          // 阳按钮
          ElevatedButton(
            onPressed: () => _addYao('1'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF8B4513),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            child: const Text('阳', style: TextStyle(fontSize: 16)),
          ),
          const SizedBox(width: 4),
          
          // 删除按钮
          ElevatedButton(
            onPressed: _deleteLast,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[100],
              foregroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
            child: const Text('删除', style: TextStyle(fontSize: 14)),
          ),
        ],
      ),
    );
  }

  Widget _buildHexagramDisplay() {
    return Card(
      margin: const EdgeInsets.all(8),
      color: const Color(0xFFFFF8DC),
      elevation: 0,
      child: Column(
        children: [
          const SizedBox(height: 8),
          // 爻象垂直排列
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(6, (index) {
                  final reversedIndex = 5 - index;
                  final yaoValue = reversedIndex < _inputText.length 
                      ? _inputText[reversedIndex] 
                      : '';
                  return _buildYaoImage(yaoValue == '1');
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYaoImage(bool isYang) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 3),
      child: Container(
        width: 80,
        height: 8,
        decoration: BoxDecoration(
          color: isYang ? Colors.black : Colors.white,
          border: Border.all(color: Colors.black, width: 1.5),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildYaoCiArea() {
    return Container(
      padding: const EdgeInsets.all(8),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('爻辞', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 4),
          _buildYaoCiRow('初六', _yiYao),
          _buildYaoCiRow('六二', _erYao),
          _buildYaoCiRow('六三', _sanYao),
          _buildYaoCiRow('六四', _siYao),
          _buildYaoCiRow('六五', _wuYao),
          _buildYaoCiRow('上六', _liuYao),
        ],
      ),
    );
  }

  Widget _buildYaoCiRow(String label, String content) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 50,
            child: Text(label, style: const TextStyle(fontSize: 13)),
          ),
          Expanded(
            child: Text(content, style: const TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: _reset,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[300],
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: const Text('重置'),
          ),
          const SizedBox(width: 32),
          ElevatedButton(
            onPressed: _inputText.length == 6 ? _confirm : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B4513),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: const Text('确认'),
          ),
        ],
      ),
    );
  }
}
