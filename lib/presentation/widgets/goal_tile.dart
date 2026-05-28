import 'package:flutter/material.dart';

import '../../core/extensions/datetime_ext.dart';
import '../../data/models/goal_model.dart';
import '../../data/models/milestone_model.dart';

class GoalTile extends StatefulWidget {
  const GoalTile({
    super.key,
    required this.goal,
    required this.milestones,
    required this.onTap,
    required this.onToggleComplete,
    required this.onMilestoneToggle,
    required this.onDelete,
  });

  final GoalModel goal;
  final List<MilestoneModel> milestones;
  final VoidCallback onTap;
  final ValueChanged<bool> onToggleComplete;
  final void Function(String milestoneId, bool isCompleted) onMilestoneToggle;
  final VoidCallback onDelete;

  @override
  State<GoalTile> createState() => _GoalTileState();
}

class _GoalTileState extends State<GoalTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final goal = widget.goal;
    final completedCount = widget.milestones.where((m) => m.isCompleted).length;
    final totalCount = widget.milestones.length;
    final progress = totalCount > 0 ? completedCount / totalCount : 0.0;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 250),
      opacity: goal.isCompleted ? 0.55 : 1.0,
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: Column(
          children: [
            ListTile(
              leading: Checkbox(
                value: goal.isCompleted,
                onChanged: (v) => widget.onToggleComplete(v ?? false),
              ),
              title: Text(
                goal.title,
                style: theme.textTheme.titleSmall?.copyWith(
                  decoration: goal.isCompleted ? TextDecoration.lineThrough : null,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (goal.targetDate != null)
                    Text(
                      'Due: ${goal.targetDate!.deadlineLabel}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: goal.targetDate!.isOverdueOrFalse
                            ? theme.colorScheme.error
                            : theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: LinearProgressIndicator(
                          value: progress,
                          borderRadius: BorderRadius.circular(4),
                          minHeight: 6,
                          backgroundColor: theme.colorScheme.surfaceContainerHighest,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$completedCount/$totalCount',
                        style: theme.textTheme.labelSmall,
                      ),
                    ],
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (totalCount > 0)
                    IconButton(
                      icon: AnimatedRotation(
                        duration: const Duration(milliseconds: 200),
                        turns: _expanded ? 0.5 : 0,
                        child: const Icon(Icons.expand_more),
                      ),
                      onPressed: () => setState(() => _expanded = !_expanded),
                      visualDensity: VisualDensity.compact,
                    ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    onPressed: widget.onTap,
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ),
            if (_expanded) ...[
              const Divider(height: 1),
              ...widget.milestones.map(
                (m) => CheckboxListTile(
                  dense: true,
                  value: m.isCompleted,
                  onChanged: (v) => widget.onMilestoneToggle(m.id, v ?? false),
                  title: Text(
                    m.title,
                    style: theme.textTheme.bodySmall?.copyWith(
                      decoration: m.isCompleted ? TextDecoration.lineThrough : null,
                      color: m.isCompleted
                          ? theme.colorScheme.onSurface.withOpacity(0.4)
                          : null,
                    ),
                  ),
                  subtitle: m.targetDate != null
                      ? Text(m.targetDate!.deadlineLabel, style: theme.textTheme.labelSmall)
                      : null,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
