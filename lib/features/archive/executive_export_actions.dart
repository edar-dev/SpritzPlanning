import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/export/executive_report.dart';
import '../../core/plan/plan_gate.dart';
import '../../core/plan/plan_tier.dart';
import '../../core/export/executive_report_print.dart';
import '../../core/export/session_report.dart';
import '../../core/export/session_report_stats.dart';
import '../../core/l10n/l10n_extensions.dart';

class ExecutiveReportLabelsX {
  static ExecutiveReportLabels fromL10n(dynamic l10n) {
    return ExecutiveReportLabels(
      title: l10n.executiveReportTitle,
      overviewHeading: l10n.executiveReportOverview,
      roomLabel: l10n.executiveReportRoomLabel,
      codeLabel: l10n.executiveReportCodeLabel,
      exportedAtLabel: l10n.executiveReportExportedAtLabel,
      kpiHeading: l10n.executiveReportKpi,
      completedLabel: l10n.reportCompleted,
      spikesLabel: l10n.reportSpikes,
      meanLabel: l10n.reportMean,
      medianLabel: l10n.reportMedian,
      varianceLabel: l10n.reportVariance,
      revisionRateLabel: l10n.reportRevisionRate,
      avgTimeLabel: l10n.reportAvgTimePerStory,
      uncertainHeading: l10n.executiveReportUncertainStories,
      uncertaintyScoreLabel: l10n.executiveReportUncertaintyScore,
      revisionsLabel: l10n.estimateHistoryLabel,
      actionsHeading: l10n.executiveReportActions,
      backlogHeading: l10n.executiveReportBacklog,
      estimateColumn: l10n.executiveReportEstimateColumn,
      noUncertainStories: l10n.executiveReportNoUncertainStories,
      noSuggestedActions: l10n.executiveReportNoSuggestedActions,
      actionSpike: l10n.executiveReportActionSpike,
      actionRevised: l10n.executiveReportActionRevised,
      actionReference: l10n.executiveReportActionReference,
      actionHighVariance: l10n.executiveReportActionHighVariance,
      actionFacilitatorNote: l10n.executiveReportActionFacilitatorNote,
      actionPublicComment: l10n.executiveReportActionPublicComment,
      retroHeading: l10n.sessionCloseRetroLabel,
      minutesSuffix: l10n.executiveReportMinutesSuffix,
      percentSuffix: l10n.executiveReportPercentSuffix,
      spikeKind: l10n.storyKindSpike,
    );
  }
}

class ExecutiveExportActions {
  static ExecutiveReport build({
    required SessionReport report,
    required SessionReportStats stats,
    required BuildContext context,
    String retroNotes = '',
  }) {
    return ExecutiveReport(
      report: report,
      stats: stats,
      labels: ExecutiveReportLabelsX.fromL10n(context.l10n),
      retroNotes: retroNotes,
    );
  }

  static Future<void> copyMarkdown(
    BuildContext context,
    WidgetRef ref, {
    required SessionReport report,
    required SessionReportStats stats,
    String retroNotes = '',
  }) async {
    if (!await ensurePlanFeature(
      context,
      ref,
      feature: (t) => t.canUseExecutiveReport,
      minimumTier: PlanTier.pro,
    )) {
      return;
    }
    if (!context.mounted) return;
    final executive = build(
      context: context,
      report: report,
      stats: stats,
      retroNotes: retroNotes,
    );
    await _copyText(context, executive.toMarkdown());
  }

  static Future<void> copyCsv(
    BuildContext context,
    WidgetRef ref, {
    required SessionReport report,
    required SessionReportStats stats,
    String retroNotes = '',
  }) async {
    if (!await ensurePlanFeature(
      context,
      ref,
      feature: (t) => t.canUseExecutiveReport,
      minimumTier: PlanTier.pro,
    )) {
      return;
    }
    if (!context.mounted) return;
    final executive = build(
      context: context,
      report: report,
      stats: stats,
      retroNotes: retroNotes,
    );
    await _copyText(context, executive.toBusinessCsv());
  }

  static Future<void> printPdf(
    BuildContext context,
    WidgetRef ref, {
    required SessionReport report,
    required SessionReportStats stats,
    String retroNotes = '',
  }) async {
    if (!await ensurePlanFeature(
      context,
      ref,
      feature: (t) => t.canUseExecutiveReport,
      minimumTier: PlanTier.pro,
    )) {
      return;
    }
    if (!context.mounted) return;
    final executive = build(
      context: context,
      report: report,
      stats: stats,
      retroNotes: retroNotes,
    );
    final opened = await printExecutiveReportHtml(executive.toPrintHtml());
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          opened
              ? context.l10n.executiveReportPrintOpened
              : context.l10n.executiveReportPrintUnavailable,
        ),
      ),
    );
  }

  static Future<void> _copyText(BuildContext context, String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.reportCopied)),
      );
    }
  }
}
