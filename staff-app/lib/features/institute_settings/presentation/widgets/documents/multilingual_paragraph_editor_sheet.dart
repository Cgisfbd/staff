import 'package:flutter/material.dart';
import 'package:staff_app/core/theme/app_colors.dart';
import 'package:staff_app/features/institute_settings/data/models/institute_settings_ui_model.dart';
import 'package:staff_app/features/institute_settings/domain/entities/institute_settings_entity.dart';

class MultilingualParagraphEditorSheet {
  static Future<void> show(
    BuildContext context, {
    required String title,
    required List<MultilingualParagraphEntity> paragraphs,
    required ValueChanged<List<MultilingualParagraphEntity>> onSave,
  }) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final list = paragraphs
        .map((e) => e is MultilingualParagraph ? e : MultilingualParagraph.fromEntity(e))
        .toList();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalCtx, setState) {
            return Container(
              height: MediaQuery.of(ctx).size.height * 0.85,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E212A) : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                border: Border(top: BorderSide(color: isDark ? AppColors.darkGlassBorder : AppColors.lightGlassBorder)),
              ),
              child: Column(
                children: [
                  Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(color: isDark ? Colors.white24 : Colors.black12, borderRadius: BorderRadius.circular(2)),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.goldPrimary),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          setState(() => list.add(const MultilingualParagraph()));
                        },
                        icon: const Icon(Icons.add_rounded, size: 16),
                        label: const Text('Add Paragraph', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                  const Divider(),
                  Expanded(
                    child: list.isEmpty
                        ? const Center(child: Text('No paragraphs yet. Tap Add Paragraph above.', style: TextStyle(fontSize: 12, color: Colors.grey)))
                        : ListView.builder(
                            itemCount: list.length,
                            itemBuilder: (itemCtx, idx) {
                              final item = list[idx];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                color: isDark ? Colors.black26 : Colors.black.withValues(alpha: 0.03),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                child: Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('Paragraph #${idx + 1}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                                          IconButton(
                                            icon: const Icon(Icons.delete_outline, size: 16, color: Colors.redAccent),
                                            onPressed: () => setState(() => list.removeAt(idx)),
                                          ),
                                        ],
                                      ),
                                      TextField(
                                        controller: TextEditingController(text: item.en)..selection = TextSelection.collapsed(offset: item.en.length),
                                        style: const TextStyle(fontSize: 11),
                                        decoration: const InputDecoration(labelText: 'English', isDense: true),
                                        onChanged: (val) => list[idx] = list[idx].copyWith(en: val),
                                      ),
                                      TextField(
                                        controller: TextEditingController(text: item.ur)..selection = TextSelection.collapsed(offset: item.ur.length),
                                        textDirection: TextDirection.rtl,
                                        style: const TextStyle(fontSize: 11),
                                        decoration: const InputDecoration(labelText: 'Urdu (RTL)', isDense: true),
                                        onChanged: (val) => list[idx] = list[idx].copyWith(ur: val),
                                      ),
                                      TextField(
                                        controller: TextEditingController(text: item.hi)..selection = TextSelection.collapsed(offset: item.hi.length),
                                        style: const TextStyle(fontSize: 11),
                                        decoration: const InputDecoration(labelText: 'Hindi', isDense: true),
                                        onChanged: (val) => list[idx] = list[idx].copyWith(hi: val),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      onSave(list);
                      Navigator.of(ctx).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.goldPrimary,
                      foregroundColor: Colors.black,
                      minimumSize: const Size.fromHeight(42),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Save Paragraphs', style: TextStyle(fontWeight: FontWeight.w800)),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
