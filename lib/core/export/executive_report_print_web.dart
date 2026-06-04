// Web-only implementation loaded via conditional export.
// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:html' as html;

Future<bool> openExecutiveReportPrint(String reportHtml) async {
  final blob = html.Blob([reportHtml], 'text/html');
  final url = html.Url.createObjectUrlFromBlob(blob);
  html.window.open(url, '_blank');
  html.Url.revokeObjectUrl(url);
  return true;
}
