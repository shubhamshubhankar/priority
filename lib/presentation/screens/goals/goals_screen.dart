import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/models/goal_model.dart';
import '../../../data/models/milestone_model.dart';
import '../../../presentation/providers/providers.dart';
import '../../../presentation/widgets/empty_state.dart';
import '../../../presentation/widgets/goal_tile.dart';
import '../../../presentation/widgets/loading_shimmer.dart';
import 'goals_bloc.dart';
import 'goals_event.dart';
import 'goals_state.dart';

class GoalsScreen extends ConsumerStatefulWidget {
  const GoalsScreen({super.key});

  @override
  ConsumerState<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends ConsumerState<GoalsScreen> {
  late final GoalsBloc _bloc;
  final Map<String, List<MilestoneModel>> _milestoneCache = {};
  final Map<String, StreamSubscription> _milestoneSubs = {};

  @override
  void initState() {
    super.initState();
    _bloc = GoalsBloc(ref.read(goalsRepositoryProvider));
    final uid = ref.read(currentUidProvider);
    if (uid != null) _bloc.add(GoalsSubscribed(uid));
  }

  @override
  void dispose() {
    _bloc.close();
    for (final sub in _milestoneSubs.values) {
      sub.cancel();
    }
    super.dispose();
  }

  void _subscribeToMilestones(String uid, String goalId) {
    if (_milestoneSubs.containsKey(goalId)) return;
    final repo = ref.read(goalsRepositoryProvider);
    _milestoneSubs[goalId] = repo.watchMilestones(uid, goalId).listen(
      (m) => setState(() => _milestoneCache[goalId] = m),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = ref.watch(currentUidProvider);
    final theme = Theme.of(context);

    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        appBar: AppBar(title: const Text('Goals')),
        body: BlocBuilder<GoalsBloc, GoalsState>(
          builder: (context, state) {
            if (state is GoalsLoading || state is GoalsInitial) return const LoadingShimmer();
            if (state is GoalsError) return Center(child: Text(state.message));
            if (state is GoalsLoaded) {
              final shortTerm = state.shortTerm;
              final longTerm = state.longTerm;

              if (uid != null) {
                for (final g in state.goals) { _subscribeToMilestones(uid, g.id); }
              }

              if (state.goals.isEmpty) {
                return const EmptyState(
                  icon: Icons.flag_outlined,
                  title: 'No goals yet',
                  subtitle: 'Add short-term and long-term goals\nto track your progress',
                );
              }

              return ListView(
                padding: const EdgeInsets.only(bottom: 80),
                children: [
                  if (shortTerm.isNotEmpty) ...[
                    _SectionHeader(
                      label: 'SHORT-TERM GOALS',
                      icon: Icons.bolt,
                      color: theme.colorScheme.primary,
                      onAdd: () => context.push('/goals/new?horizon=shortTerm'),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: shortTerm.map((g) => _buildGoalTile(g, uid)).toList(),
                      ),
                    ),
                  ],
                  if (longTerm.isNotEmpty) ...[
                    _SectionHeader(
                      label: 'LONG-TERM GOALS',
                      icon: Icons.flag,
                      color: theme.colorScheme.secondary,
                      onAdd: () => context.push('/goals/new?horizon=longTerm'),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: longTerm.map((g) => _buildGoalTile(g, uid)).toList(),
                      ),
                    ),
                  ],
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => context.push('/goals/new'),
          icon: const Icon(Icons.add),
          label: const Text('New goal'),
        ),
      ),
    );
  }

  Widget _buildGoalTile(GoalModel goal, String? uid) {
    return GoalTile(
      key: ValueKey(goal.id),
      goal: goal,
      milestones: _milestoneCache[goal.id] ?? [],
      onTap: () => context.push('/goals/${goal.id}'),
      onToggleComplete: (v) {
        if (uid != null) _bloc.add(GoalCompleteToggled(uid: uid, goalId: goal.id, isCompleted: v));
      },
      onMilestoneToggle: (milestoneId, v) async {
        if (uid != null) {
          await ref.read(goalsRepositoryProvider).toggleMilestoneComplete(uid, goal.id, milestoneId, v);
          // Recompute progress
          final milestones = _milestoneCache[goal.id] ?? [];
          final done = milestones.where((m) => m.id == milestoneId ? v : m.isCompleted).length;
          final total = milestones.length;
          if (total > 0) {
            await ref.read(goalsRepositoryProvider).updateProgress(uid, goal.id, ((done / total) * 100).round());
          }
        }
      },
      onDelete: () {
        if (uid != null) _bloc.add(GoalDeleted(uid: uid, goalId: goal.id));
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label, required this.icon, required this.color, required this.onAdd});
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 8, 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          TextButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Add', style: TextStyle(fontSize: 12)),
            style: TextButton.styleFrom(foregroundColor: color, padding: const EdgeInsets.symmetric(horizontal: 8)),
          ),
        ],
      ),
    );
  }
}
