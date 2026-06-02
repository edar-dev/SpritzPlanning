import '../voting/vote_stats.dart';
import 'session_report.dart';
import 'session_report_stats.dart';

/// Localized copy for executive report generation (IT/EN from l10n).
class ExecutiveReportLabels {
  const ExecutiveReportLabels({
    required this.title,
    required this.overviewHeading,
    required this.roomLabel,
    required this.codeLabel,
    required this.exportedAtLabel,
    required this.kpiHeading,
    required this.completedLabel,
    required this.spikesLabel,
    required this.meanLabel,
    required this.medianLabel,
    required this.varianceLabel,
    required this.revisionRateLabel,
    required this.avgTimeLabel,
    required this.uncertainHeading,
    required this.uncertaintyScoreLabel,
    required this.revisionsLabel,
    required this.actionsHeading,
    required this.backlogHeading,
    required this.estimateColumn,
    required this.noUncertainStories,
    required this.noSuggestedActions,
    required this.actionSpike,
    required this.actionRevised,
    required this.actionReference,
    required this.actionHighVariance,
    required this.actionFacilitatorNote,
    required this.actionPublicComment,
    required this.retroHeading,
    required this.minutesSuffix,
    required this.percentSuffix,
    required this.spikeKind,
  });

  final String title;
  final String overviewHeading;
  final String roomLabel;
  final String codeLabel;
  final String exportedAtLabel;
  final String kpiHeading;
  final String completedLabel;
  final String spikesLabel;
  final String meanLabel;
  final String medianLabel;
  final String varianceLabel;
  final String revisionRateLabel;
  final String avgTimeLabel;
  final String uncertainHeading;
  final String uncertaintyScoreLabel;
  final String revisionsLabel;
  final String actionsHeading;
  final String backlogHeading;
  final String estimateColumn;
  final String noUncertainStories;
  final String noSuggestedActions;
  final String actionSpike;
  final String actionRevised;
  final String actionReference;
  final String actionHighVariance;
  final String actionFacilitatorNote;
  final String actionPublicComment;
  final String retroHeading;
  final String minutesSuffix;
  final String percentSuffix;
  final String spikeKind;

  String revisedStory(String title, String history) =>
      actionRevised.replaceAll('{title}', title).replaceAll('{history}', history);

  String spikeStory(String title) => actionSpike.replaceAll('{title}', title);

  String referenceStory(String title) =>
      actionReference.replaceAll('{title}', title);

  String facilitatorNote(String title, String note) => actionFacilitatorNote
      .replaceAll('{title}', title)
      .replaceAll('{note}', note);

  String publicComment(String title, String comment) => actionPublicComment
      .replaceAll('{title}', title)
      .replaceAll('{comment}', comment);
}

class UncertainStoryInsight {
  const UncertainStoryInsight({
    required this.row,
    required this.score,
  });

  final SessionReportRow row;
  final int score;
}

class ExecutiveReport {
  ExecutiveReport({
    required this.report,
    required this.stats,
    required this.labels,
    this.retroNotes = '',
    this.topUncertainLimit = 5,
  });

  final SessionReport report;
  final SessionReportStats stats;
  final ExecutiveReportLabels labels;
  final String retroNotes;
  final int topUncertainLimit;

  List<UncertainStoryInsight> get topUncertainStories {
    final ranked = report.rows
        .map(
          (row) => UncertainStoryInsight(
            row: row,
            score: _uncertaintyScore(row),
          ),
        )
        .where((item) => item.score > 0)
        .toList()
      ..sort((a, b) => b.score.compareTo(a.score));
    return ranked.take(topUncertainLimit).toList();
  }

  List<String> get suggestedActions {
    final actions = <String>[];

    if (stats.variancePoints != null && stats.variancePoints! >= 2) {
      actions.add(labels.actionHighVariance);
    }

    for (final insight in topUncertainStories) {
      final row = insight.row;
      if (row.isSpike) {
        actions.add(labels.spikeStory(row.title));
      } else if (_hasRevisions(row)) {
        actions.add(labels.revisedStory(row.title, row.estimateHistorySummary));
      }
      if (row.isReference) {
        actions.add(labels.referenceStory(row.title));
      }
      if (report.includeFacilitatorNotes && row.facilitatorNote.isNotEmpty) {
        actions.add(labels.facilitatorNote(row.title, row.facilitatorNote));
      }
      if (row.publicComment.isNotEmpty) {
        actions.add(labels.publicComment(row.title, row.publicComment));
      }
    }

    if (retroNotes.trim().isNotEmpty) {
      actions.add('${labels.retroHeading}: ${retroNotes.trim()}');
    }

    final unique = <String>{};
    return actions.where(unique.add).toList();
  }

  String toMarkdown() {
    final l = labels;
    final buffer = StringBuffer()
      ..writeln('# ${l.title}')
      ..writeln()
      ..writeln('## ${l.overviewHeading}')
      ..writeln('- **${l.roomLabel}:** ${report.roomName}')
      ..writeln('- **${l.codeLabel}:** `${report.roomCode}`')
      ..writeln(
        '- **${l.exportedAtLabel}:** ${report.exportedAt.toIso8601String()}',
      )
      ..writeln('- **${l.completedLabel}:** ${stats.completedCount}')
      ..writeln()
      ..writeln('## ${l.kpiHeading}');

    _appendKpiLine(buffer, l.completedLabel, '${stats.completedCount}');
    if (stats.spikeCount > 0) {
      _appendKpiLine(buffer, l.spikesLabel, '${stats.spikeCount}');
    }
    if (stats.meanPoints != null) {
      _appendKpiLine(buffer, l.meanLabel, stats.meanPoints!.toStringAsFixed(1));
    }
    if (stats.medianPoints != null) {
      _appendKpiLine(
        buffer,
        l.medianLabel,
        stats.medianPoints!.toStringAsFixed(1),
      );
    }
    if (stats.variancePoints != null) {
      _appendKpiLine(
        buffer,
        l.varianceLabel,
        stats.variancePoints!.toStringAsFixed(1),
      );
    }
    if (stats.revisionRatePercent != null) {
      _appendKpiLine(
        buffer,
        l.revisionRateLabel,
        '${stats.revisionRatePercent!.round()}${l.percentSuffix}',
      );
    }
    if (stats.avgMinutesPerStory != null) {
      _appendKpiLine(
        buffer,
        l.avgTimeLabel,
        '${stats.avgMinutesPerStory!.round()} ${l.minutesSuffix}',
      );
    }

    buffer.writeln();
    buffer.writeln('## ${l.uncertainHeading}');
    final uncertain = topUncertainStories;
    if (uncertain.isEmpty) {
      buffer.writeln(l.noUncertainStories);
    } else {
      for (var i = 0; i < uncertain.length; i++) {
        final item = uncertain[i];
        final row = item.row;
        buffer.write('${i + 1}. **${_escapeMd(row.title)}**');
        buffer.write(' — ${l.estimateColumn}: ${row.estimate}');
        buffer.write(
          ', ${l.uncertaintyScoreLabel}: ${item.score}',
        );
        if (_hasRevisions(row)) {
          buffer.write(', ${l.revisionsLabel}: ${row.estimateHistorySummary}');
        }
        if (row.isSpike) {
          buffer.write(' (${l.spikeKind})');
        }
        buffer.writeln();
      }
    }

    buffer.writeln();
    buffer.writeln('## ${l.actionsHeading}');
    final actions = suggestedActions;
    if (actions.isEmpty) {
      buffer.writeln(l.noSuggestedActions);
    } else {
      for (final action in actions) {
        buffer.writeln('- ${_escapeMd(action)}');
      }
    }

    buffer.writeln();
    buffer.writeln('## ${l.backlogHeading}');
    buffer
      ..writeln('| ${l.backlogHeading} | ${l.estimateColumn} |')
      ..writeln('|--------|-------|');
    for (final row in report.rows) {
      buffer.writeln(
        '| ${_escapeMd(row.title)} | ${row.estimate} |',
      );
    }

    return buffer.toString();
  }

  String toBusinessCsv() {
    final buffer = StringBuffer('section,metric,value\n');
    void summary(String metric, String value) {
      buffer.writeln('summary,$metric,${_csvField(value)}');
    }

    summary('room_name', report.roomName);
    summary('room_code', report.roomCode);
    summary('exported_at', report.exportedAt.toIso8601String());
    summary('completed_stories', '${stats.completedCount}');
    summary('spikes', '${stats.spikeCount}');
    if (stats.meanPoints != null) {
      summary('mean_points', stats.meanPoints!.toStringAsFixed(1));
    }
    if (stats.medianPoints != null) {
      summary('median_points', stats.medianPoints!.toStringAsFixed(1));
    }
    if (stats.variancePoints != null) {
      summary('variance_points', stats.variancePoints!.toStringAsFixed(1));
    }
    if (stats.revisionRatePercent != null) {
      summary(
        'revision_rate_percent',
        stats.revisionRatePercent!.round().toString(),
      );
    }
    if (stats.avgMinutesPerStory != null) {
      summary(
        'avg_minutes_per_story',
        stats.avgMinutesPerStory!.round().toString(),
      );
    }

    buffer.writeln(
      'story,title,estimate,uncertainty_score,revisions,is_spike,is_reference',
    );
    for (final row in report.rows) {
      buffer.writeln([
        'story',
        _csvField(row.title),
        _csvField(row.estimate),
        '${_uncertaintyScore(row)}',
        _csvField(row.estimateHistorySummary),
        row.isSpike ? 'true' : 'false',
        row.isReference ? 'true' : 'false',
      ].join(','));
    }

    buffer.writeln('action,priority,text');
    final actions = suggestedActions;
    for (var i = 0; i < actions.length; i++) {
      buffer.writeln(
        'action,${i + 1},${_csvField(actions[i])}',
      );
    }

    return buffer.toString();
  }

  String toPrintHtml() {
    final l = labels;
    final uncertain = topUncertainStories;
    final actions = suggestedActions;

    final kpiRows = <String>[
      _htmlRow(l.completedLabel, '${stats.completedCount}'),
      if (stats.spikeCount > 0) _htmlRow(l.spikesLabel, '${stats.spikeCount}'),
      if (stats.meanPoints != null)
        _htmlRow(l.meanLabel, stats.meanPoints!.toStringAsFixed(1)),
      if (stats.medianPoints != null)
        _htmlRow(l.medianLabel, stats.medianPoints!.toStringAsFixed(1)),
      if (stats.variancePoints != null)
        _htmlRow(l.varianceLabel, stats.variancePoints!.toStringAsFixed(1)),
      if (stats.revisionRatePercent != null)
        _htmlRow(
          l.revisionRateLabel,
          '${stats.revisionRatePercent!.round()}${l.percentSuffix}',
        ),
      if (stats.avgMinutesPerStory != null)
        _htmlRow(
          l.avgTimeLabel,
          '${stats.avgMinutesPerStory!.round()} ${l.minutesSuffix}',
        ),
    ].join();

    final uncertainHtml = uncertain.isEmpty
        ? '<p>${_escapeHtml(l.noUncertainStories)}</p>'
        : '<ol>${uncertain.map((item) {
            final row = item.row;
            final parts = <String>[
              '<strong>${_escapeHtml(row.title)}</strong>',
              '${_escapeHtml(l.estimateColumn)}: ${_escapeHtml(row.estimate)}',
              '${_escapeHtml(l.uncertaintyScoreLabel)}: ${item.score}',
            ];
            if (_hasRevisions(row)) {
              parts.add(
                '${_escapeHtml(l.revisionsLabel)}: ${_escapeHtml(row.estimateHistorySummary)}',
              );
            }
            return '<li>${parts.join(' · ')}</li>';
          }).join()}</ol>';

    final actionsHtml = actions.isEmpty
        ? '<p>${_escapeHtml(l.noSuggestedActions)}</p>'
        : '<ul>${actions.map((a) => '<li>${_escapeHtml(a)}</li>').join()}</ul>';

    final backlogRows = report.rows
        .map(
          (row) =>
              '<tr><td>${_escapeHtml(row.title)}</td><td>${_escapeHtml(row.estimate)}</td></tr>',
        )
        .join();

    return '''
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <title>${_escapeHtml(l.title)} — ${_escapeHtml(report.roomName)}</title>
  <style>
    :root { color-scheme: light; }
    body {
      font-family: "Segoe UI", system-ui, sans-serif;
      color: #1f2933;
      margin: 2rem auto;
      max-width: 820px;
      line-height: 1.5;
    }
    h1 { color: #c45c26; margin-bottom: 0.25rem; }
    h2 {
      color: #3d5a45;
      border-bottom: 1px solid #e5e7eb;
      padding-bottom: 0.25rem;
      margin-top: 1.75rem;
    }
    .meta { color: #6b7280; margin-bottom: 1.5rem; }
    table { width: 100%; border-collapse: collapse; margin-top: 0.75rem; }
    th, td { border: 1px solid #e5e7eb; padding: 0.5rem 0.75rem; text-align: left; }
    th { background: #f7f3ef; }
    @media print {
      body { margin: 0.75in; }
      h1, h2 { page-break-after: avoid; }
      table { page-break-inside: avoid; }
    }
  </style>
</head>
<body>
  <h1>${_escapeHtml(l.title)}</h1>
  <p class="meta">${_escapeHtml(report.roomName)} · ${_escapeHtml(report.roomCode)} · ${_escapeHtml(report.exportedAt.toIso8601String())}</p>

  <h2>${_escapeHtml(l.overviewHeading)}</h2>
  <table>
    ${_htmlRow(l.roomLabel, report.roomName)}
    ${_htmlRow(l.codeLabel, report.roomCode)}
    ${_htmlRow(l.exportedAtLabel, report.exportedAt.toIso8601String())}
    ${_htmlRow(l.completedLabel, '${stats.completedCount}')}
  </table>

  <h2>${_escapeHtml(l.kpiHeading)}</h2>
  <table>$kpiRows</table>

  <h2>${_escapeHtml(l.uncertainHeading)}</h2>
  $uncertainHtml

  <h2>${_escapeHtml(l.actionsHeading)}</h2>
  $actionsHtml

  <h2>${_escapeHtml(l.backlogHeading)}</h2>
  <table>
    <thead><tr><th>${_escapeHtml(l.backlogHeading)}</th><th>${_escapeHtml(l.estimateColumn)}</th></tr></thead>
    <tbody>$backlogRows</tbody>
  </table>
</body>
</html>
''';
  }

  static int _uncertaintyScore(SessionReportRow row) {
    var score = 0;
    if (row.isSpike) score += 100;
    if (row.estimate == '?' || !isNumericDeckValue(row.estimate)) score += 50;
    final revisions = row.estimateHistorySummary
        .split(' → ')
        .where((part) => part.trim().isNotEmpty)
        .length;
    if (revisions > 1) score += 30 * (revisions - 1);
    if (row.publicComment.isNotEmpty) score += 10;
    if (row.isReference) score += 5;
    return score;
  }

  static bool _hasRevisions(SessionReportRow row) =>
      row.estimateHistorySummary.contains('→');

  static void _appendKpiLine(StringBuffer buffer, String label, String value) {
    buffer.writeln('- **$label:** $value');
  }

  static String _escapeMd(String value) =>
      value.replaceAll('|', '\\|').replaceAll('\n', ' ');

  static String _escapeHtml(String value) => value
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;');

  static String _htmlRow(String label, String value) =>
      '<tr><th>${_escapeHtml(label)}</th><td>${_escapeHtml(value)}</td></tr>';

  static String _csvField(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }
}
