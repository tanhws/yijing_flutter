import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FourPillarCalculatorFragment extends StatefulWidget {
  const FourPillarCalculatorFragment({super.key});

  @override
  State<FourPillarCalculatorFragment> createState() => _FourPillarCalculatorFragmentState();
}

class _FourPillarCalculatorFragmentState extends State<FourPillarCalculatorFragment> {
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  
  // 四柱结果
  String _yearGanZhi = '';
  String _monthGanZhi = '';
  String _dayGanZhi = '';
  String _hourGanZhi = '';
  
  String _shengXiao = '';
  List<String> _wuXing = [];
  
  @override
  void initState() {
    super.initState();
    _calculate();
  }
  
  void _calculate() {
    final lunar = _getLunarDate(_selectedDate);
    final ganZhi = _calculateGanZhi(_selectedDate, _selectedTime);
    
    setState(() {
      _yearGanZhi = ganZhi['year'] ?? '';
      _monthGanZhi = ganZhi['month'] ?? '';
      _dayGanZhi = ganZhi['day'] ?? '';
      _hourGanZhi = ganZhi['hour'] ?? '';
      _shengXiao = _getShengXiao(_selectedDate.year);
      _wuXing = _getWuXing(_dayGanZhi);
    });
  }
  
  Map<String, String> _calculateGanZhi(DateTime date, TimeOfDay time) {
    // 简化版天干地支计算
    const tianGan = ['甲', '乙', '丙', '丁', '戊', '己', '庚', '辛', '壬', '癸'];
    const diZhi = ['子', '丑', '寅', '卯', '辰', '巳', '午', '未', '申', '酉', '戌', '亥'];
    
    // 年柱
    final yearCycle = (date.year - 1984) % 60;
    final yearGan = tianGan[(date.year - 4) % 10];
    final yearZhi = diZhi[(date.year - 4) % 12];
    
    // 月柱
    final monthGan = tianGan[((date.year % 5) * 2 + (date.month - 1)) % 10];
    final monthZhi = diZhi[(date.month - 1) % 12];
    
    // 日柱（简化）
    final dayOfYear = int.parse(DateFormat('D').format(date));
    final dayGan = tianGan[(dayOfYear + 6) % 10];
    final dayZhi = diZhi[(dayOfYear + 4) % 12];
    
    // 时柱
    final hourIndex = (time.hour + 1) ~/ 2 % 12;
    final hourGan = tianGan[((dayOfYear % 5) * 2 + hourIndex) % 10];
    final hourZhi = diZhi[hourIndex];
    
    return {
      'year': '$yearGan$yearZhi',
      'month': '$monthGan$monthZhi',
      'day': '$dayGan$dayZhi',
      'hour': '$hourGan$hourZhi',
    };
  }
  
  String _getShengXiao(int year) {
    const shengXiao = ['鼠', '牛', '虎', '兔', '龙', '蛇', '马', '羊', '猴', '鸡', '狗', '猪'];
    return shengXiao[(year - 1900) % 12];
  }
  
  List<String> _getWuXing(String dayGanZhi) {
    // 根据日干判断五行
    final gan = dayGanZhi.isNotEmpty ? dayGanZhi[0] : '甲';
    const wuxing = {
      '甲': ['木', '阳木'], '乙': ['木', '阴木'],
      '丙': ['火', '阳火'], '丁': ['火', '阴火'],
      '戊': ['土', '阳土'], '己': ['土', '阴土'],
      '庚': ['金', '阳金'], '辛': ['金', '阴金'],
      '壬': ['水', '阳水'], '癸': ['水', '阴水'],
    };
    return wuxing[gan] ?? ['木', '阳木'];
  }
  
  Map<String, dynamic> _getLunarDate(DateTime date) {
    // 简化版，需要配合农历库
    return {
      'year': date.year,
      'month': date.month,
      'day': date.day,
    };
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
      _calculate();
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
      _calculate();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('四柱八字'),
        backgroundColor: Colors.amber[700],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.amber[50]!, Colors.white],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 日期时间选择
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.calendar_today, color: Colors.amber),
                        title: const Text('出生日期'),
                        subtitle: Text(DateFormat('yyyy-MM-dd').format(_selectedDate)),
                        onTap: _selectDate,
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.access_time, color: Colors.amber),
                        title: const Text('出生时辰'),
                        subtitle: Text('${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}'),
                        onTap: _selectTime,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // 四柱结果
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '四柱命盘',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildPillarRow('年柱', _yearGanZhi, '流年'),
                      _buildPillarRow('月柱', _monthGanZhi, '事业'),
                      _buildPillarRow('日柱', _dayGanZhi, '本人'),
                      _buildPillarRow('时柱', _hourGanZhi, '财运'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // 其他信息
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '基本信息',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow('生肖', _shengXiao),
                      _buildInfoRow('日主五行', _wuXing.isNotEmpty ? _wuXing[0] : ''),
                      _buildInfoRow('日主属性', _wuXing.length > 1 ? _wuXing[1] : ''),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPillarRow(String label, String value, String meaning) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.amber,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.amber[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              meaning,
              style: TextStyle(
                color: Colors.amber[700],
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
