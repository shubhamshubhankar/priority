import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/models/task_model.dart';
import '../../../presentation/providers/providers.dart';
import '../../../presentation/widgets/empty_state.dart';
import '../../../presentation/widgets/loading_shimmer.dart';
import '../../../presentation/widgets/quadrant_container.dart';
import '../../../presentation/widgets/task_tile.dart';
import 'matrix_bloc.dart';
import 'matrix_event.dart';
import 'matrix_state.dart';

class MatrixScreen extends ConsumerStatefulWidget {
  const MatrixScreen({super.key});

  @override
  ConsumerState<MatrixScreen> createState() => _MatrixScreenState();
}

class _MatrixScreenState extends ConsumerState<MatrixScreen> {
  late final MatrixBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = MatrixBloc(ref.read(tasksRepositoryProvider));
    final uid = ref.read(currentUidProvider);
    if (uid != null) _bloc.add(MatrixSubscribed(uid));
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uid = ref.watch(currentUidProvider);

    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        appBar: AppBar(title: const Text('Priority Matrix')),
        body: BlocBuilder<MatrixBloc, MatrixState>(
          builder: (context, state) {
            if (state is MatrixLoading || state is MatrixInitial) {
              return const LoadingShimmer();
            }
            if (state is MatrixError) {
              return Center(child: Text(state.message));
            }
            if (state is MatrixLoaded) {
              final allEmpty = state.tasks.isEmpty;
              if (allEmpty) {
                return const EmptyState(
                  icon: Icons.grid_view_outlined,
                  title: 'No tasks yet',
                  subtitle: 'Add tasks to any quadrant\nto manage your priorities',
                );
              }
              return LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 700;
                  if (isWide) {
                    return _WideMatrix(state: state, uid: uid, bloc: _bloc);
                  }
                  return _NarrowMatrix(state: state, uid: uid, bloc: _bloc);
                },
              );
            }
            return const SizedBox.shrink();
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => context.push('/matrix/new'),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

class _WideMatrix extends StatelessWidget {
  const _WideMatrix({required this.state, required this.uid, required this.bloc});
  final MatrixLoaded state;
  final String? uid;
  final MatrixBloc bloc;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          _MatrixLabel(),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Expanded(child: _QuadrantPanel(state: state, uid: uid, bloc: bloc, quadrant: Quadrant.doNow)),
                      const SizedBox(height: 8),
                      Expanded(child: _QuadrantPanel(state: state, uid: uid, bloc: bloc, quadrant: Quadrant.delegate)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    children: [
                      Expanded(child: _QuadrantPanel(state: state, uid: uid, bloc: bloc, quadrant: Quadrant.schedule)),
                      const SizedBox(height: 8),
                      Expanded(child: _QuadrantPanel(state: state, uid: uid, bloc: bloc, quadrant: Quadrant.eliminate)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NarrowMatrix extends StatelessWidget {
  const _NarrowMatrix({required this.state, required this.uid, required this.bloc});
  final MatrixLoaded state;
  final String? uid;
  final MatrixBloc bloc;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        _QuadrantPanel(state: state, uid: uid, bloc: bloc, quadrant: Quadrant.doNow),
        const SizedBox(height: 8),
        _QuadrantPanel(state: state, uid: uid, bloc: bloc, quadrant: Quadrant.schedule),
        const SizedBox(height: 8),
        _QuadrantPanel(state: state, uid: uid, bloc: bloc, quadrant: Quadrant.delegate),
        const SizedBox(height: 8),
        _QuadrantPanel(state: state, uid: uid, bloc: bloc, quadrant: Quadrant.eliminate),
        const SizedBox(height: 80),
      ],
    );
  }
}

class _MatrixLabel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(child: Center(child: Text('URGENT', style: theme.textTheme.labelSmall?.copyWith(letterSpacing: 1.2, color: theme.colorScheme.onSurface.withOpacity(0.5))))),
          Expanded(child: Center(child: Text('NOT URGENT', style: theme.textTheme.labelSmall?.copyWith(letterSpacing: 1.2, color: theme.colorScheme.onSurface.withOpacity(0.5))))),
        ],
      ),
    );
  }
}

class _QuadrantPanel extends StatelessWidget {
  const _QuadrantPanel({
    required this.state,
    required this.uid,
    required this.bloc,
    required this.quadrant,
  });

  final MatrixLoaded state;
  final String? uid;
  final MatrixBloc bloc;
  final Quadrant quadrant;

  static const _meta = {
    Quadrant.doNow:    ('DO NOW',    'Urgent + Important',     Icons.priority_high,    kQuadrantDoColor),
    Quadrant.schedule: ('SCHEDULE',  'Not Urgent + Important', Icons.calendar_today,   kQuadrantScheduleColor),
    Quadrant.delegate: ('DELEGATE',  'Urgent + Not Important', Icons.person_outline,   kQuadrantDelegateColor),
    Quadrant.eliminate:('ELIMINATE', 'Not Urgent + Not Imp.',  Icons.not_interested,   kQuadrantEliminateColor),
  };

  @override
  Widget build(BuildContext context) {
    final (title, subtitle, icon, color) = _meta[quadrant]!;
    final tasks = state.forQuadrant(quadrant);

    return QuadrantContainer(
      title: title,
      subtitle: subtitle,
      color: color,
      icon: icon,
      onAdd: () => context.push('/matrix/new?quadrant=${quadrant.name}'),
      children: tasks.map((task) => TaskTile(
        key: ValueKey(task.id),
        task: task,
        onTap: () => context.push('/matrix/${task.id}'),
        onToggleComplete: (v) {
          if (uid != null) bloc.add(MatrixTaskCompleteToggled(uid: uid!, taskId: task.id, isCompleted: v));
        },
        onDelete: () {
          if (uid != null) bloc.add(MatrixTaskDeleted(uid: uid!, taskId: task.id));
        },
      )).toList(),
    );
  }
}
