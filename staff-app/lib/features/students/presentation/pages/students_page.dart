import 'package:flutter/material.dart';
import 'package:staff_app/features/ebooks/presentation/pages/ebooks_page.dart';

export 'package:staff_app/features/ebooks/presentation/pages/ebooks_page.dart';

/// Screen Adapter for Tab 2 (E-Books & Academic Curriculum) (< 25 lines).
/// Renders the ultra-luxury EbooksPage with cascading filters & dual-book cards.
class StudentsPage extends StatelessWidget {
  const StudentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const EbooksPage();
  }
}
