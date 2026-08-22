import 'package:flutter/material.dart';
import '../../constants/patient_theme.dart';
import 'patient_components.dart';

/// Screen 14 — Documents & Reports Screen (matching media_1787385006975.jpg)
class PatientDocumentsScreen extends StatefulWidget {
  const PatientDocumentsScreen({super.key});

  @override
  State<PatientDocumentsScreen> createState() => _PatientDocumentsScreenState();
}

class _PatientDocumentsScreenState extends State<PatientDocumentsScreen> {
  String _selectedCategory = 'All';

  final List<Map<String, String>> _documents = [
    {
      'title': 'X-Ray Report',
      'date': '15 Aug 2026',
      'size': '2.4 MB',
      'category': 'Reports',
    },
    {
      'title': 'MRI Report',
      'date': '10 Aug 2026',
      'size': '3.1 MB',
      'category': 'Reports',
    },
    {
      'title': 'Blood Test Report',
      'date': '05 Aug 2026',
      'size': '1.8 MB',
      'category': 'Reports',
    },
    {
      'title': 'Prescription - Aug',
      'date': '06 Aug 2026',
      'size': '1.2 MB',
      'category': 'Prescriptions',
    },
    {
      'title': 'Exercise Guide',
      'date': '01 Aug 2026',
      'size': '2.7 MB',
      'category': 'Others',
    },
  ];

  List<Map<String, String>> get _filteredDocs {
    if (_selectedCategory == 'All') return _documents;
    return _documents.where((d) => d['category'] == _selectedCategory).toList();
  }

  void _downloadDoc(String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Downloading $title...'),
        backgroundColor: PatientTheme.primaryTeal,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PatientTheme.pageBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: PatientTheme.textDark),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'My Documents',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: PatientTheme.textDark),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Filter Chips Row
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['All', 'Reports', 'Prescriptions', 'Others'].map((cat) {
                  final isSelected = _selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(cat),
                      selected: isSelected,
                      selectedColor: PatientTheme.primaryTeal,
                      backgroundColor: PatientTheme.inputBg,
                      labelStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected ? Colors.white : PatientTheme.textDark,
                      ),
                      side: BorderSide(
                        color: isSelected ? PatientTheme.primaryTeal : PatientTheme.border,
                      ),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      onSelected: (val) {
                        if (val) setState(() => _selectedCategory = cat);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Document List (matching screenshot)
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _filteredDocs.length,
              itemBuilder: (context, index) {
                final doc = _filteredDocs[index];
                return PatientCard(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      // Document Icon Box
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: PatientTheme.primaryTealLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.picture_as_pdf_rounded,
                          color: PatientTheme.primaryTeal,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 14),

                      // Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              doc['title']!,
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.bold,
                                color: PatientTheme.textDark,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '${doc['date']} • ${doc['size']}',
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: PatientTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Download Action
                      IconButton(
                        icon: const Icon(Icons.download_rounded, color: PatientTheme.primaryTeal, size: 20),
                        onPressed: () => _downloadDoc(doc['title']!),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
