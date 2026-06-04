import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_profile.dart';
import '../providers/providers.dart';
import 'auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final authSessionProvider = StreamProvider<Session?>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return repo.authStateChanges.map((event) => event.session);
});

final currentAuthUserProvider = Provider<User?>((ref) {
  return ref.watch(authSessionProvider).valueOrNull?.user;
});

final isSignedInProvider = Provider<bool>((ref) {
  return ref.watch(currentAuthUserProvider) != null;
});

final userProfileProvider = FutureProvider<UserProfile?>((ref) async {
  final signedIn = ref.watch(isSignedInProvider);
  if (!signedIn) return null;
  final repo = ref.read(authRepositoryProvider);
  try {
    return await repo.fetchMyProfile();
  } catch (_) {
    return null;
  }
});

/// After sign-in, link active room participant when still a guest seat.
final authParticipantLinkProvider =
    Provider<Future<void> Function()>((ref) {
  return () async {
    final signedIn = ref.read(isSignedInProvider);
    if (!signedIn) return;
    final session = ref.read(sessionProvider).valueOrNull;
    if (session == null) return;
    final roomState = ref.read(roomStateProvider).valueOrNull;
    if (roomState == null) return;
    final participant = roomState.participants
        .where((p) => p.id == session.participantId)
        .firstOrNull;
    if (participant == null) return;
    await ref.read(authRepositoryProvider).linkParticipantToUser(
          session.participantId,
        );
    await ref.read(roomStateProvider.notifier).refresh();
  };
});
