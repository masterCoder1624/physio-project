import 'dart:io';
import 'package:http/http.dart' as http;
import 'token_interceptor.dart';

class MultipartService {
  MultipartService({required this.tokenInterceptor});

  final TokenInterceptor tokenInterceptor;

  Future<http.StreamedResponse> uploadFile({
    required String url,
    required File file,
    required String fileFieldName,
    Map<String, String>? fields,
  }) async {
    final uri = Uri.parse(url);
    final request = http.MultipartRequest('POST', uri);

    final headers = await tokenInterceptor.getHeaders(isMultipart: true);
    request.headers.addAll(headers);

    if (fields != null) {
      request.fields.addAll(fields);
    }

    final multipartFile = await http.MultipartFile.fromPath(
      fileFieldName,
      file.path,
    );
    request.files.add(multipartFile);

    return await request.send();
  }
}
