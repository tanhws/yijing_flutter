import 'package:flutter/material.dart';
import '../../data/models/hexagram.dart';

/// 卦象展示组件
class HexagramWidget extends StatelessWidget {
  final Hexagram hexagram;
  final bool showLines;
  final double fontSize;

  const HexagramWidget({
    super.key,
    required this.hexagram,
    this.showLines = false,
    this.fontSize = 48,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 上卦
        Text(
          hexagram.upperBaGua,
          style: TextStyle(
            fontSize: fontSize * 1.5,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        // 上卦三爻
        if (showLines) _buildTrigram(hexagram.lines.sublist(0, 3)),
        const SizedBox(height: 4),
        // 下卦
        Text(
          hexagram.lowerBaGua,
          style: TextStyle(
            fontSize: fontSize * 1.5,
            fontWeight: FontWeight.bold,
          ),
        ),
        // 下卦三爻
        if (showLines) _buildTrigram(hexagram.lines.sublist(3, 6)),
      ],
    );
  }

  Widget _buildTrigram(List<int> lines) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: lines.map((line) {
        return Container(
          width: 40,
          height: 8,
          margin: const EdgeInsets.symmetric(vertical: 2),
          decoration: BoxDecoration(
            color: line == 1 ? Colors.black : Colors.white,
            border: Border.all(color: Colors.black, width: 2),
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }).toList(),
    );
  }
}

/// 爻线展示组件（完整六爻）
class HexagramLinesWidget extends StatelessWidget {
  final List<int> lines;
  final List<int> changingLines;
  final double width;

  const HexagramLinesWidget({
    super.key,
    required this.lines,
    this.changingLines = const [],
    this.width = 120,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Column(
        children: List.generate(6, (index) {
          final line = lines[index];
          final isChanging = changingLines.contains(index);
          
          return Container(
            height: 20,
            margin: const EdgeInsets.symmetric(vertical: 2),
            decoration: BoxDecoration(
              color: line == 1 ? Colors.black87 : Colors.white,
              border: Border.all(
                color: isChanging ? Colors.red : Colors.black87,
                width: isChanging ? 3 : 2,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
          );
        }),
      ),
    );
  }
}

/// 八卦列表组件
class BaGuaGrid extends StatelessWidget {
  final Function(BaGua)? onTap;

  const BaGuaGrid({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 1,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: BaGua.all.length,
      itemBuilder: (context, index) {
        final baGua = BaGua.all[index];
        return GestureDetector(
          onTap: () => onTap?.call(baGua),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.amber[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber[300]!),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  baGua.emoji,
                  style: const TextStyle(fontSize: 36),
                ),
                const SizedBox(height: 4),
                Text(
                  baGua.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  baGua.nature,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}