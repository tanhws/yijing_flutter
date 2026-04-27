import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

class FourPillarCalculatorFragment extends StatefulWidget {
  const FourPillarCalculatorFragment({super.key});

  @override
  State<FourPillarCalculatorFragment> createState() => _FourPillarCalculatorFragmentState();
}

class _FourPillarCalculatorFragmentState extends State<FourPillarCalculatorFragment> {
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  
  String _fourPillarResult = '';
  String _ganZhiResult = '';
  
  @override
  void initState() {
    super.initState();
    _calculate();
  }
  
  void _calculate() {
    final result = _calculateFourPillars(_selectedDate, _selectedTime);
    setState(() {
      _fourPillarResult = result['fourPillar'] ?? '';
      _ganZhiResult = result['ganZhi'] ?? '';
    });
  }
  
  Map<String, String> _calculateFourPillars(DateTime date, TimeOfDay time) {
    const tianGan = ['甲', '乙', '丙', '丁', '戊', '己', '庚', '辛', '壬', '癸'];
    const diZhi = ['子', '丑', '寅', '卯', '辰', '巳', '午', '未', '申', '酉', '戌', '亥'];
    
    // 年柱
    final yearGan = tianGan[(date.year - 4) % 10];
    final yearZhi = diZhi[(date.year - 4) % 12];
    
    // 月柱
    final monthGan = tianGan[((date.year % 5) * 2 + (date.month - 1)) % 10];
    final monthZhi = diZhi[(date.month - 1) % 12];
    
    // 日柱（简化计算）
    final dayOfYear = int.parse(DateFormat('D').format(date));
    final dayGan = tianGan[(dayOfYear + 6) % 10];
    final dayZhi = diZhi[(dayOfYear + 4) % 12];
    
    // 时柱
    final hourIndex = (time.hour + 1) ~/ 2 % 12;
    final hourGan = tianGan[((dayOfYear % 5) * 2 + hourIndex) % 10];
    final hourZhi = diZhi[hourIndex];
    
    return {
      'fourPillar': '$yearGan$yearZhi  $monthGan$monthZhi  $dayGan$dayZhi  $hourGan$hourZhi',
      'ganZhi': '年柱: $yearGan$yearZhi\n月柱: $monthGan$monthZhi\n日柱: $dayGan$dayZhi\n时柱: $hourGan$hourZhi',
    };
  }

  Future<void> _selectDateTime() async {
    // 显示日期时间选择器
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Container(
        height: 300,
        color: Colors.white,
        child: Column(
          children: [
            // 日期选择
            SizedBox(
              height: 200,
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.dateAndTime,
                initialDateTime: DateTime(
                  _selectedDate.year,
                  _selectedDate.month,
                  _selectedDate.day,
                  _selectedTime.hour,
                  _selectedTime.minute,
                ),
                onDateTimeChanged: (dateTime) {
                  setState(() {
                    _selectedDate = dateTime;
                    _selectedTime = TimeOfDay.fromDateTime(dateTime);
                  });
                },
              ),
            ),
            // 确认按钮
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  _calculate();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B4513),
                ),
                child: const Text('确认', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('排八字'),
        backgroundColor: const Color(0xFF8B4513),
      ),
      body: Container(
        color: const Color(0xFFFFF8DC),
        child: SafeArea(
          child: Column(
            children: [
              // 时间显示（点击可修改）
              GestureDetector(
                onTap: _selectDateTime,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  color: const Color(0xFFDEB887),
                  child: Column(
                    children: [
                      Text(
                        '${_selectedDate.year}年${_selectedDate.month}月${_selectedDate.day}日',
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 8),
                      const Text('点击选择时间', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
              ),
              
              // 结果显示
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 四柱一行显示
                      Text(
                        _fourPillarResult,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF8B4513),
                          letterSpacing: 8,
                        ),
                      ),
                      const SizedBox(height: 32),
                      // 四柱分行显示
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _ganZhiResult,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 18, height: 1.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // 确认按钮
              Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: _selectDateTime,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B4513),
                    padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 12),
                  ),
                  child: const Text('重新选择时间', style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
