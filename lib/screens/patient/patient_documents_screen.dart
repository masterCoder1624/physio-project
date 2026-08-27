import 'package:flutter/material.dart';
import '../../constants/patient_theme.dart';
import '../../models/document_model.dart';
import '../../services/document_service.dart';
import 'patient_components.dart';

/// Screen 14 — Documents & Reports Screen (matching media_1787385006975.jpg)
class PatientDocumentsScreen extends StatefulWidget {
  const PatientDocumentsScreen({super.key, this.patientId});

  final String? patientId;

  @override
  State<PatientDocumentsScreen> createState() => _PatientDocumentsScreenState();
}

class _PatientDocumentsScreenState extends State<PatientDocumentsScreen> {
  final DocumentService _documentService = DocumentService();
  String _selectedCategory = 'All';
  List<DocumentModel> _documents = [];
  bool _isLoading = true;
  String? _downloadingDocId;

  @override
  void initState() {
    super.initState();
    _documents = _documentService.cachedDocuments;
    _fetchDocuments();
  }

  Future<void> _fetchDocuments() async {
    setState(() => _isLoading = true);
    try {
      final docs = widget.patientId != null && widget.patientId!.isNotEmpty
          ? await _documentService.getPatientDocuments(widget.patientId!, category: _selectedCategory)
          : await _documentService.getMyDocuments(category: _selectedCategory);
      if (!mounted) return;
      setState(() {
        _documents = docs;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  List<DocumentModel> get _filteredDocs {
    if (_selectedCategory == 'All') return _documents;
    return _documents.where((d) => d.category.toLowerCase() == _selectedCategory.toLowerCase()).toList();
  }

  Future<void> _downloadDoc(DocumentModel doc) async {
    if (_downloadingDocId != null) return;
    setState(() => _downloadingDocId = doc.id);

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Downloading ${doc.originalFileName}...'),
        backgroundColor: PatientTheme.primaryTeal,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );

    try {
      final pId = widget.patientId ?? 'me';
      final bytes = await _documentService.downloadDocumentBytes(pId, doc.id);
      if (!mounted) return;
      setState(() => _downloadingDocId = null);

      if (bytes != null && bytes.isNotEmpty) {
        await _documentService.openOrShareDocument(bytes, doc.originalFileName);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to download file. Please try again.'),
            backgroundColor: Color(0xFFE74C3C),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _downloadingDocId = null);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Download failed. Please check network connection.'),
          backgroundColor: Color(0xFFE74C3C),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredDocs;

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
                children: ['All', 'Reports', 'Prescriptions', 'Imaging / Scan', 'Others'].map((cat) {
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
                        if (val) {
                          setState(() => _selectedCategory = cat);
                          _fetchDocuments();
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          if (_isLoading && _documents.isEmpty)
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(color: PatientTheme.primaryTeal),
              ),
            )
          else
            // Document List (matching screenshot)
            Expanded(
              child: RefreshIndicator(
                onRefresh: _fetchDocuments,
                color: PatientTheme.primaryTeal,
                child: filtered.isEmpty
                    ? ListView(
                        padding: const EdgeInsets.all(30),
                        children: [
                          const SizedBox(height: 60),
                          Center(
                            child: Column(
                              children: [
                                Container(
                                  width: 64,
                                  height: 64,
                                  decoration: BoxDecoration(
                                    color: PatientTheme.primaryTealLight,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Icon(
                                    Icons.folder_open_rounded,
                                    color: PatientTheme.primaryTeal,
                                    size: 32,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'No Documents Found',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: PatientTheme.textDark,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  _selectedCategory == 'All'
                                      ? 'Your uploaded medical reports, scans, and prescriptions will appear here.'
                                      : 'No $_selectedCategory documents available at this time.',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    color: PatientTheme.textMuted,
                                    height: 1.35,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final doc = filtered[index];
                          final isDownloading = _downloadingDocId == doc.id;
                          final isImage = doc.fileType == 'png' || doc.fileType == 'jpg' || doc.fileType == 'jpeg';

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
                                    color: isImage ? PatientTheme.infoBlueBg : PatientTheme.primaryTealLight,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    isImage ? Icons.image_rounded : Icons.picture_as_pdf_rounded,
                                    color: isImage ? PatientTheme.infoBlue : PatientTheme.primaryTeal,
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
                                        doc.originalFileName,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.bold,
                                          color: PatientTheme.textDark,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        '${doc.dateFormatted} • ${doc.fileSizeFormatted}',
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
                                  icon: isDownloading
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: PatientTheme.primaryTeal,
                                          ),
                                        )
                                      : const Icon(
                                          Icons.download_rounded,
                                          color: PatientTheme.primaryTeal,
                                          size: 20,
                                        ),
                                  onPressed: isDownloading ? null : () => _downloadDoc(doc),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ),
        ],
      ),
    );
  }
}
