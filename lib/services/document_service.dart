import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:printing/printing.dart';
import '../core/config/api_config.dart';
import '../core/network/api_client.dart';
import '../core/network/token_interceptor.dart';
import '../models/document_model.dart';

class DocumentService {
  static final DocumentService _instance = DocumentService._internal();
  factory DocumentService() => _instance;
  DocumentService._internal();

  final ApiClient _apiClient = ApiClient();
  final TokenInterceptor _interceptor = TokenInterceptor();

  List<DocumentModel> _cachedDocuments = [];
  List<DocumentModel> get cachedDocuments => _cachedDocuments;

  Future<List<DocumentModel>> getMyDocuments({String? category, int page = 1, int size = 50}) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'size': size.toString(),
      };
      if (category != null && category.isNotEmpty && category != 'All') {
        queryParams['category'] = category;
      }

      final response = await _apiClient.get<List<DocumentModel>>(
        '/patients/me/documents',
        queryParameters: queryParams,
        fromJson: (json) {
          if (json is List) {
            return json
                .map((e) => DocumentModel.fromJson(Map<String, dynamic>.from(e as Map)))
                .toList();
          }
          return <DocumentModel>[];
        },
      );

      if (response.success && response.data != null) {
        _cachedDocuments = response.data!;
        return response.data!;
      }
    } catch (e) {
      dev.log('DocumentService.getMyDocuments error: $e');
    }

    return _cachedDocuments;
  }

  Future<List<DocumentModel>> getPatientDocuments(
    String patientId, {
    String? category,
    int page = 1,
    int size = 50,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'size': size.toString(),
      };
      if (category != null && category.isNotEmpty && category != 'All') {
        queryParams['category'] = category;
      }

      final response = await _apiClient.get<List<DocumentModel>>(
        '/patients/$patientId/documents',
        queryParameters: queryParams,
        fromJson: (json) {
          if (json is List) {
            return json
                .map((e) => DocumentModel.fromJson(Map<String, dynamic>.from(e as Map)))
                .toList();
          }
          return <DocumentModel>[];
        },
      );

      if (response.success && response.data != null) {
        return response.data!;
      }
    } catch (e) {
      dev.log('DocumentService.getPatientDocuments error for $patientId: $e');
    }

    return <DocumentModel>[];
  }

  Future<DocumentModel?> uploadDocument({
    required String patientId,
    required List<int> fileBytes,
    required String fileName,
    String category = 'Reports',
    String? description,
    String? appointmentId,
    String? clinicalNoteId,
    String? assessmentId,
  }) async {
    try {
      final isSelf = patientId == 'me';
      final path = isSelf ? '/api/v1/patients/me/documents' : '/api/v1/patients/$patientId/documents';
      final uri = Uri.parse('${_apiClient.baseUrl.replaceAll('/api/v1', '')}$path');

      final request = http.MultipartRequest('POST', uri);
      final headers = await _interceptor.getHeaders(isMultipart: true);
      request.headers.addAll(headers);

      request.fields['category'] = category;
      if (description != null && description.isNotEmpty) {
        request.fields['description'] = description;
      }
      if (appointmentId != null && appointmentId.isNotEmpty) {
        request.fields['appointment_id'] = appointmentId;
      }
      if (clinicalNoteId != null && clinicalNoteId.isNotEmpty) {
        request.fields['clinical_note_id'] = clinicalNoteId;
      }
      if (assessmentId != null && assessmentId.isNotEmpty) {
        request.fields['assessment_id'] = assessmentId;
      }

      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          fileBytes,
          filename: fileName,
        ),
      );

      final streamedResponse = await request.send().timeout(ApiConfig.timeoutDuration);
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final body = jsonDecode(response.body);
        final data = body is Map && body.containsKey('data') ? body['data'] : body;
        if (data != null && data is Map) {
          final created = DocumentModel.fromJson(Map<String, dynamic>.from(data));
          _cachedDocuments.insert(0, created);
          return created;
        }
      }
    } catch (e) {
      dev.log('DocumentService.uploadDocument error: $e');
    }

    return null;
  }

  Future<Uint8List?> downloadDocumentBytes(String patientId, String documentId) async {
    try {
      final isSelf = patientId == 'me';
      final path = isSelf
          ? '/patients/me/documents/$documentId/download'
          : '/patients/$patientId/documents/$documentId/download';
      final uri = Uri.parse('${_apiClient.baseUrl}$path');

      final headers = await _interceptor.getHeaders();
      final response = await http.get(uri, headers: headers).timeout(ApiConfig.timeoutDuration);

      if (response.statusCode == 200) {
        return response.bodyBytes;
      }
    } catch (e) {
      dev.log('DocumentService.downloadDocumentBytes error: $e');
    }
    return null;
  }

  Future<bool> deleteDocument(String patientId, String documentId) async {
    try {
      final response = await _apiClient.delete<Map<String, dynamic>>(
        '/patients/$patientId/documents/$documentId',
      );
      if (response.success) {
        _cachedDocuments.removeWhere((d) => d.id == documentId || d.fileId == documentId);
        return true;
      }
    } catch (e) {
      dev.log('DocumentService.deleteDocument error: $e');
    }
    return false;
  }

  Future<void> openOrShareDocument(Uint8List bytes, String fileName) async {
    try {
      await Printing.sharePdf(bytes: bytes, filename: fileName);
    } catch (e) {
      dev.log('DocumentService.openOrShareDocument error: $e');
    }
  }
}
