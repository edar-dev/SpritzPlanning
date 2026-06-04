export 'executive_report_print_stub.dart'
    if (dart.library.html) 'executive_report_print_web.dart';

import 'executive_report_print_stub.dart'
    if (dart.library.html) 'executive_report_print_web.dart';

Future<bool> printExecutiveReportHtml(String html) =>
    openExecutiveReportPrint(html);
