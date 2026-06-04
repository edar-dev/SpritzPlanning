import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors/user_facing_error.dart';
import '../../core/l10n/l10n_extensions.dart';
import '../../core/preferences/preferences_providers.dart';
import '../../core/theme/app_colors.dart';
import '../../data/auth/auth_providers.dart';
import '../../data/providers/providers.dart';
import 'sign_in_sheet.dart';

class ProfileSheet extends ConsumerStatefulWidget {
  const ProfileSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: const ProfileSheet(),
      ),
    );
  }

  @override
  ConsumerState<ProfileSheet> createState() => _ProfileSheetState();
}

class _ProfileSheetState extends ConsumerState<ProfileSheet> {
  final _nameController = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final l10n = context.l10n;
    final name = _nameController.text.trim();
    if (name.length < 2) {
      setState(() => _error = l10n.nicknameLabel);
      return;
    }
    final locale = ref.read(localeProvider).valueOrNull ?? const Locale('it');
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref.read(authRepositoryProvider).upsertMyProfile(
            displayName: name,
            preferredLocale: locale.languageCode,
          );
      ref.invalidate(userProfileProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.accountProfileSaved)),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = userFacingMessage(e, l10n: l10n));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _signOut() async {
    await ref.read(authRepositoryProvider).signOut();
    ref.invalidate(userProfileProvider);
    if (mounted) Navigator.pop(context);
  }

  Future<void> _linkParticipant() async {
    final l10n = context.l10n;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref.read(authParticipantLinkProvider)();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.accountLinkParticipantSuccess)),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = userFacingMessage(e, l10n: l10n));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final signedIn = ref.watch(isSignedInProvider);
    final profileAsync = ref.watch(userProfileProvider);
    final session = ref.watch(sessionProvider).valueOrNull;

    if (!signedIn) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.accountAuthRequired),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () {
                  Navigator.pop(context);
                  unawaited(SignInSheet.show(context));
                },
                child: Text(l10n.accountSignIn),
              ),
            ],
          ),
        ),
      );
    }

    final profile = profileAsync.valueOrNull;
    if (profile != null && _nameController.text.isEmpty) {
      _nameController.text = profile.displayName;
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.accountProfile,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: l10n.accountDisplayNameLabel,
              ),
              enabled: !_loading,
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _loading ? null : _saveProfile,
              child: Text(l10n.accountSaveProfile),
            ),
            if (session != null) ...[
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: _loading ? null : _linkParticipant,
                child: Text(l10n.accountLinkParticipantAction),
              ),
            ],
            const SizedBox(height: 16),
            TextButton(
              onPressed: _loading ? null : _signOut,
              style: TextButton.styleFrom(
                foregroundColor: const Color(AppColors.textSecondary),
              ),
              child: Text(l10n.accountSignOut),
            ),
          ],
        ),
      ),
    );
  }
}
