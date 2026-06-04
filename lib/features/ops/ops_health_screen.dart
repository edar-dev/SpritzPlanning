import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/l10n_extensions.dart';
import '../../core/plan/plan_gate.dart';
import '../../core/plan/plan_tier.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/audit_event.dart';
import '../../data/providers/providers.dart';

class OpsHealthScreen extends ConsumerStatefulWidget {
  const OpsHealthScreen({super.key});

  @override
  ConsumerState<OpsHealthScreen> createState() => _OpsHealthScreenState();
}

class _OpsHealthScreenState extends ConsumerState<OpsHealthScreen> {
  OpsHealthSnapshot? _snapshot;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final snap =
          await ref.read(roomRepositoryProvider).fetchOpsHealthSnapshot();
      if (!mounted) return;
      setState(() {
        _snapshot = snap;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final connection = ref.watch(connectionStatusProvider).valueOrNull;

    if (!planAllows(ref, (t) => t.canUseOpsHealth)) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.opsHealthTitle)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(l10n.planFeatureLocked),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.opsHealthTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.canPop() ? context.pop() : context.go('/'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loading ? null : _load,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    if (connection != null)
                      _MetricCard(
                        label: l10n.opsHealthRealtime,
                        value: connection.name,
                      ),
                    if (_snapshot != null) ...[
                      _MetricCard(
                        label: l10n.opsHealthActiveRooms1h,
                        value: '${_snapshot!.activeRooms1h}',
                      ),
                      _MetricCard(
                        label: l10n.opsHealthActiveRooms24h,
                        value: '${_snapshot!.activeRooms24h}',
                      ),
                      _MetricCard(
                        label: l10n.opsHealthAudit24h,
                        value: '${_snapshot!.auditEvents24h}',
                      ),
                      _MetricCard(
                        label: l10n.opsHealthExternalLinks,
                        value: '${_snapshot!.externalLinksTotal}',
                      ),
                      _MetricCard(
                        label: l10n.opsHealthStoriesDone24h,
                        value: '${_snapshot!.storiesDone24h}',
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.opsHealthCheckedAt(
                          _snapshot!.checkedAt.toLocal().toString(),
                        ),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: const Color(AppColors.textSecondary),
                            ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Text(
                      l10n.opsHealthAlertHint,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(label),
        trailing: Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: const Color(AppColors.spritzOrange),
              ),
        ),
      ),
    );
  }
}
