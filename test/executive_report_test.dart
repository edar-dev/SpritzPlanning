import 'package:flutter_test/flutter_test.dart';
import 'package:spritz_planning/core/export/executive_report.dart';
import 'package:spritz_planning/core/export/session_report.dart';
import 'package:spritz_planning/core/export/session_report_stats.dart';

const _labels = ExecutiveReportLabels(
  title: 'Executive report',
  overviewHeading: 'Overview',
  roomLabel: 'Room',
  codeLabel: 'Code',
  exportedAtLabel: 'Exported at',
  kpiHeading: 'KPI',
  completedLabel: 'Completed',
  spikesLabel: 'Spikes',
  meanLabel: 'Mean',
  medianLabel: 'Median',
  varianceLabel: 'Variance',
  revisionRateLabel: 'Revisions',
  avgTimeLabel: 'Avg time',
  uncertainHeading: 'Uncertain stories',
  uncertaintyScoreLabel: 'Score',
  revisionsLabel: 'History',
  actionsHeading: 'Actions',
  backlogHeading: 'Story',
  estimateColumn: 'Estimate',
  noUncertainStories: 'None',
  noSuggestedActions: 'None',
  actionSpike: 'Spike {title}',
  actionRevised: 'Revise {title} ({history})',
  actionReference: 'Ref {title}',
  actionHighVariance: 'High variance',
  actionFacilitatorNote: '{title}: {note}',
  actionPublicComment: '{title}: {comment}',
  retroHeading: 'Retro',
  minutesSuffix: 'min',
  percentSuffix: '%',
  spikeKind: 'Spike',
);

SessionReport _sampleReport() {
  return SessionReport(
    roomName: 'Bar Sprint',
    roomCode: 'ABCD',
    exportedAt: DateTime.utc(2026, 6, 2),
    includeFacilitatorNotes: true,
    rows: [
      SessionReportRow(
        title: 'Checkout flow',
        estimate: '5',
        description: '',
        facilitatorNote: 'Needs UX review',
        publicComment: '',
        isReference: false,
        estimateHistorySummary: '8 → 5',
        completedAt: DateTime.utc(2026, 6, 2),
        isSpike: false,
      ),
      SessionReportRow(
        title: 'Payment spike',
        estimate: '—',
        description: '',
        facilitatorNote: '',
        publicComment: 'Research needed',
        isReference: false,
        estimateHistorySummary: '—',
        completedAt: DateTime.utc(2026, 6, 2),
        isSpike: true,
      ),
      SessionReportRow(
        title: 'Login',
        estimate: '3',
        description: '',
        facilitatorNote: '',
        publicComment: '',
        isReference: true,
        estimateHistorySummary: '',
        completedAt: DateTime.utc(2026, 6, 2),
        isSpike: false,
      ),
    ],
  );
}

SessionReportStats _sampleStats() {
  return const SessionReportStats(
    completedCount: 3,
    spikeCount: 1,
    meanPoints: 4,
    medianPoints: 4,
    bars: [],
    variancePoints: 2.5,
    revisionRatePercent: 33,
    avgMinutesPerStory: 12,
  );
}

void main() {
  test('executive markdown includes overview, KPI, uncertainty and actions', () {
    final report = ExecutiveReport(
      report: _sampleReport(),
      stats: _sampleStats(),
      labels: _labels,
    );

    final md = report.toMarkdown();

    expect(md, contains('# Executive report'));
    expect(md, contains('## Overview'));
    expect(md, contains('Bar Sprint'));
    expect(md, contains('## KPI'));
    expect(md, contains('33%'));
    expect(md, contains('Checkout flow'));
    expect(md, contains('8 → 5'));
    expect(md, contains('## Actions'));
    expect(md, contains('Payment spike'));
    expect(md, contains('Login'));
  });

  test('business csv includes summary and story rows', () {
    final csv = ExecutiveReport(
      report: _sampleReport(),
      stats: _sampleStats(),
      labels: _labels,
    ).toBusinessCsv();

    expect(csv, contains('section,metric,value'));
    expect(csv, contains('summary,room_name,Bar Sprint'));
    expect(csv, contains('story,title,estimate,uncertainty_score'));
    expect(csv, contains('Checkout flow'));
    expect(csv, contains('action,priority,text'));
  });

  test('print html is self-contained and escaped', () {
    final html = ExecutiveReport(
      report: _sampleReport(),
      stats: _sampleStats(),
      labels: _labels,
    ).toPrintHtml();

    expect(html, contains('<!DOCTYPE html>'));
    expect(html, contains('Executive report'));
    expect(html, contains('@media print'));
    expect(html, contains('Checkout flow'));
    expect(html, isNot(contains('<script')));
  });

  test('top uncertain stories ranks spike and revised story first', () {
    final uncertain = ExecutiveReport(
      report: _sampleReport(),
      stats: _sampleStats(),
      labels: _labels,
    ).topUncertainStories;

    expect(uncertain.first.row.title, 'Payment spike');
    expect(uncertain.any((s) => s.row.title == 'Checkout flow'), isTrue);
  });
}
