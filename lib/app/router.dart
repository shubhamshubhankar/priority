import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../presentation/screens/auth/sign_in_screen.dart';
import '../presentation/screens/auth/totp_setup_screen.dart';
import '../presentation/screens/auth/totp_verify_screen.dart';
import '../presentation/screens/notes/notes_screen.dart';
import '../presentation/screens/matrix/matrix_screen.dart';
import '../presentation/screens/goals/goals_screen.dart';
import '../presentation/screens/notes/note_editor_screen.dart';
import '../presentation/screens/matrix/task_editor_screen.dart';
import '../presentation/screens/goals/goal_editor_screen.dart';
import '../presentation/widgets/main_shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authStream = FirebaseAuth.instance.authStateChanges();

  return GoRouter(
    initialLocation: '/notes',
    redirect: (context, state) async {
      final user = FirebaseAuth.instance.currentUser;
      final isOnAuthPath = state.matchedLocation.startsWith('/auth');

      if (user == null && !isOnAuthPath) {
        return '/auth/sign-in';
      }
      if (user != null && isOnAuthPath) {
        return '/notes';
      }
      return null;
    },
    refreshListenable: GoRouterRefreshStream(authStream),
    routes: [
      // Auth routes
      GoRoute(
        path: '/auth/sign-in',
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(
        path: '/auth/totp-setup',
        builder: (context, state) => const TotpSetupScreen(),
      ),
      GoRoute(
        path: '/auth/totp-verify',
        builder: (context, state) {
          final resolver = state.extra as MultiFactorResolver?;
          return TotpVerifyScreen(resolver: resolver);
        },
      ),

      // Main shell with bottom navigation
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/notes',
            builder: (context, state) => const NotesScreen(),
            routes: [
              GoRoute(
                path: 'new',
                builder: (context, state) => const NoteEditorScreen(),
              ),
              GoRoute(
                path: ':noteId',
                builder: (context, state) {
                  return NoteEditorScreen(noteId: state.pathParameters['noteId']);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/matrix',
            builder: (context, state) => const MatrixScreen(),
            routes: [
              GoRoute(
                path: 'new',
                builder: (context, state) {
                  final quadrant = state.uri.queryParameters['quadrant'];
                  return TaskEditorScreen(initialQuadrant: quadrant);
                },
              ),
              GoRoute(
                path: ':taskId',
                builder: (context, state) {
                  return TaskEditorScreen(taskId: state.pathParameters['taskId']);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/goals',
            builder: (context, state) => const GoalsScreen(),
            routes: [
              GoRoute(
                path: 'new',
                builder: (context, state) {
                  final horizon = state.uri.queryParameters['horizon'];
                  return GoalEditorScreen(initialHorizon: horizon);
                },
              ),
              GoRoute(
                path: ':goalId',
                builder: (context, state) {
                  return GoalEditorScreen(goalId: state.pathParameters['goalId']);
                },
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

// Makes GoRouter react to Firebase auth stream changes
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _sub = stream.listen((_) => notifyListeners());
  }

  late final dynamic _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
