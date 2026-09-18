import 'package:flutter/material.dart';
import 'package:staff_app/core/theme/app_colors.dart';

class InstitutePhoneManagerCard extends StatefulWidget {
  const InstitutePhoneManagerCard({
    super.key,
    required this.phones,
    required this.onChanged,
  });

  final List<String> phones;
  final ValueChanged<List<String>> onChanged;

  @override
  State<InstitutePhoneManagerCard> createState() => _InstitutePhoneManagerCardState();
}

class _InstitutePhoneManagerCardState extends State<InstitutePhoneManagerCard> {
  late TextEditingController _newPhoneCtrl;

  @override
  void initState() {
    super.initState();
    _newPhoneCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _newPhoneCtrl.dispose();
    super.dispose();
  }

  void _addPhone() {
    final text = _newPhoneCtrl.text.trim();
    if (text.isNotEmpty && !widget.phones.contains(text)) {
      final updated = List<String>.from(widget.phones)..add(text);
      widget.onChanged(updated);
      _newPhoneCtrl.clear();
    }
  }

  void _removePhone(int index) {
    final updated = List<String>.from(widget.phones)..removeAt(index);
    widget.onChanged(updated);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.phone_in_talk_rounded, size: 16, color: AppColors.emeraldPrimary),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                'Official Helplines & Phone Numbers *',
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : AppColors.charcoalDark,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? Colors.black.withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
                ),
                child: TextField(
                  controller: _newPhoneCtrl,
                  keyboardType: TextInputType.phone,
                  style: TextStyle(fontSize: 12, color: isDark ? Colors.white : AppColors.charcoalDark),
                  decoration: InputDecoration(
                    hintText: 'e.g. +91 9876543210',
                    hintStyle: TextStyle(fontSize: 11, color: isDark ? Colors.white30 : Colors.black26),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    isDense: true,
                    border: InputBorder.none,
                  ),
                  onSubmitted: (_) => _addPhone(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: _addPhone,
              icon: const Icon(Icons.add_rounded, size: 16),
              label: const Text('Add', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.emeraldPrimary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: widget.phones.asMap().entries.map((entry) {
            final idx = entry.key;
            final phone = entry.value;
            return Chip(
              label: Text(phone, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
              avatar: const Icon(Icons.phone, size: 14, color: AppColors.emeraldPrimary),
              deleteIcon: const Icon(Icons.close, size: 14),
              onDeleted: () => _removePhone(idx),
              backgroundColor: isDark ? AppColors.emeraldPrimary.withValues(alpha: 0.15) : AppColors.emeraldPrimary.withValues(alpha: 0.1),
              side: BorderSide(color: AppColors.emeraldPrimary.withValues(alpha: 0.3)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            );
          }).toList(),
        ),
      ],
    );
  }
}
