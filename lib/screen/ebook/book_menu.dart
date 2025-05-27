import 'package:flutter/material.dart';

class ReaderSettingsBottomSheet extends StatefulWidget {
  final double fontSize;
  final double lineHeight;
  final TextAlign textAlign;
  final bool isDarkMode;
  final void Function(double) onFontSizeChanged;
  final void Function(double) onLineHeightChanged;
  final void Function(TextAlign) onTextAlignChanged;
  final void Function(bool) onThemeModeChanged;

  const ReaderSettingsBottomSheet({
    Key? key,
    required this.fontSize,
    required this.lineHeight,
    required this.textAlign,
    required this.onFontSizeChanged,
    required this.onLineHeightChanged,
    required this.onTextAlignChanged,
    required this.isDarkMode,
    required this.onThemeModeChanged,
  }) : super(key: key);

  @override
  State<ReaderSettingsBottomSheet> createState() => _ReaderSettingsBottomSheetState();
}

class _ReaderSettingsBottomSheetState extends State<ReaderSettingsBottomSheet> {
  late double _fontSize;
  late double _lineHeight;
  late TextAlign _selectedAlign;
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _fontSize = widget.fontSize;
    _lineHeight = widget.lineHeight;
    _selectedAlign = widget.textAlign;
    _isDarkMode = widget.isDarkMode;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          _buildValueRow(
            title: '글자 크기',
            value: _fontSize,
            onChanged: (newSize) {
              setState(() => _fontSize = newSize);
              widget.onFontSizeChanged(newSize);
            },
            min: 11,
            max: 30,
            step: 1,
          ),
          const Divider(color: Color(0xffE4E4E4)),
          _buildValueRow(
            title: '줄 간격',
            value: _lineHeight,
            onChanged: (newValue) {
              setState(() => _lineHeight = newValue);
              widget.onLineHeightChanged(newValue);
            },
            min: 1.0,
            max: 3.0,
            step: 0.1,
            isDecimal: true,
          ),
          const Divider(color: Color(0xffE4E4E4)),
          _buildSettingRow(
            title: '문단 정렬',
            child: Row(
              children: [
                _buildAlignChip(Icons.format_align_left, TextAlign.left),
                const SizedBox(width: 8),
                _buildAlignChip(Icons.format_align_center, TextAlign.center),
                const SizedBox(width: 8),
                _buildAlignChip(Icons.format_align_right, TextAlign.right),
              ],
            ),
          ),
          const Divider(color: Color(0xffE4E4E4)),
          _buildSettingRow(
            title: '화면 테마',
            child: Row(
              children: [
                _buildThemeChip('화이트', false),
                const SizedBox(width: 8),
                _buildThemeChip('다크', true),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSettingRow({required String title, required Widget child}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 16)),
          child,
        ],
      ),
    );
  }

  Widget _buildValueRow({
    required String title,
    required double value,
    required double min,
    required double max,
    required double step,
    required ValueChanged<double> onChanged,
    bool isDecimal = false,
  }) {
    return _buildSettingRow(
      title: title,
      child: Row(
        children: [
          _buildIconButton(Icons.remove, () {
            final newValue = (value - step).clamp(min, max);
            onChanged(double.parse(newValue.toStringAsFixed(1)));
          }),
          const SizedBox(width: 8),
          SizedBox(
            width: 30,
            child: Text(
              isDecimal ? value.toStringAsFixed(1) : value.toInt().toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          const SizedBox(width: 8),
          _buildIconButton(Icons.add, () {
            final newValue = (value + step).clamp(min, max);
            onChanged(double.parse(newValue.toStringAsFixed(1)));
          }),
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onPressed) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(icon, color: const Color(0xff333333), size: 20),
        onPressed: onPressed,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      ),
    );
  }

  Widget _buildAlignChip(IconData icon, TextAlign align) {
    final isSelected = _selectedAlign == align;
    return ChoiceChip(
      label: Container(
        width: 30,
        alignment: Alignment.center,
        child: Icon(
          icon,
          color: isSelected ? const Color(0xff0077FF) : const Color(0xff777777),
          size: 20,
        ),
      ),
      selected: isSelected,
      selectedColor: const Color(0xffCCE4FF),
      backgroundColor: const Color(0xffE4E4E4),
      onSelected: (_) {
        setState(() {
          _selectedAlign = align;
        });
        widget.onTextAlignChanged(align);
      },
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: Colors.transparent),
      ),
      showCheckmark: false,
    );
  }

  Widget _buildThemeChip(String label, bool isDark) {
    final isSelected = _isDarkMode == isDark;
    return ChoiceChip(
      label: Container(
        width: 40,
        height: 20,
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: isSelected ? const Color(0xff0077FF) : const Color(0xff777777),
          ),
        ),
      ),
      selected: isSelected,
      selectedColor: const Color(0xffCCE4FF),
      backgroundColor: const Color(0xffE4E4E4),
      onSelected: (_) {
        setState(() {
          _isDarkMode = isDark;
        });
        widget.onThemeModeChanged(isDark);
      },
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: Colors.transparent),
      ),
      showCheckmark: false,
    );
  }
}
