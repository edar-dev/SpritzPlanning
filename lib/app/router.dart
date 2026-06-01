import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/providers/providers.dart';
import '../features/help/help_screen.dart';
import '../features/home/home_screen.dart';
import '../features/lobby/room_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/help',
        builder: (context, state) => const HelpScreen(),
      ),
      GoRoute(
        path: '/room/:roomId',
        builder: (context, state) {
          final roomId = state.pathParameters['roomId']!;
          return RoomScreen(roomId: roomId);
        },
      ),
    ],
    redirect: (context, state) {
      final session = ref.read(sessionProvider).valueOrNull;
      final path = state.matchedLocation;
      final joinCode = state.uri.queryParameters['code'];

      if (session != null && path == '/' && (joinCode == null || joinCode.isEmpty)) {
        return '/room/${session.roomId}';
      }
      return null;
    },
  );
});
