import 'package:flutter/material.dart';

class DaySelectorWidget extends StatefulWidget {
  const DaySelectorWidget({super.key});

  @override
  State<DaySelectorWidget> createState() => _DaySelectorWidgetState();
}

class _DaySelectorWidgetState extends State<DaySelectorWidget> {
  // Mặc định chọn từ Thứ 2 đến Thứ 6 (true), T7 và CN không chọn (false)
  final List<bool> _selectedDays = [true, true, true, true, true, false, false];
  final List<String> _days = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: List.generate(_days.length, (index) {
        return FilterChip(
          label: Text(_days[index]),
          selected: _selectedDays[index],
          selectedColor: Colors.redAccent.withValues(alpha: 0.15), // Chuẩn Flutter 3.19+
          checkmarkColor: Colors.redAccent,
          labelStyle: TextStyle(
            color: _selectedDays[index] ? Colors.redAccent : Colors.black87,
            fontWeight: _selectedDays[index] ? FontWeight.bold : FontWeight.normal,
          ),
          onSelected: (bool selected) {
            setState(() {
              _selectedDays[index] = selected;
            });
          },
        );
      }),
    );
  }
}