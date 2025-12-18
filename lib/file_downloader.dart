import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

Future<void> downloadPdf(
  BuildContext context,
  String url,
  String fileName,
) async {
  try {
    // ✅ Fix URL
    final downloadUrl =
        url.startsWith('http') ? url : 'https://school.edusathi.in/$url';

    // 📥 Download file
    final response = await http.get(Uri.parse(downloadUrl));
    if (response.statusCode != 200) {
      throw Exception('Failed to download file');
    }

    // ✅ App-safe directory (iOS + Android)
    final Directory dir = await getApplicationDocumentsDirectory();
    final String filePath = '${dir.path}/$fileName';

    final File file = File(filePath);
    await file.writeAsBytes(response.bodyBytes, flush: true);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Downloaded to $filePath")),
    );

    // 📂 Open file
    await OpenFile.open(filePath);
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Download failed")),
    );
    debugPrint("❌ Download error: $e");
  }
}
