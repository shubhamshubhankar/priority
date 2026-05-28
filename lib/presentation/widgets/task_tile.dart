import 'package:flutter/material.dart';

import '../../data/models/task_model.dart';
import 'deadline_chip.dart';

class TaskTile extends StatelessWidget {
  const TaskTile({
    super.key,
    required this.task,
    required this.onTap,
    required this.onToggleComplete,
    required this.onDelete,
  });

  final TaskModel task;
  final VoidCallback onTap;
  final ValueChanged<bool> onToggleComplete;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCompleted = task.isCompleted;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 250),
      opacity: isCompleted ? 0.45 : 1.0,
      child: ListTile(
        dense: true,
        leading: Checkbox(
          value: isCompleted,
          onChanged: (v) => onToggleComplete(v ?? false),
        ),
        title: Text(
          task.title,
          style: theme.textTheme.bodyMedium?.copyWith(
            decoration: isCompleted ? TextDecoration.lineThrough : null,
            decorationColor: theme.colorScheme.onSurface.withOpacity(0.5),
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: task.deadline != null
            ? Padding(
                padding: const EdgeInsets.only(top: 4),
                child: DeadlineChip(deadline: task.deadline!),
              )
            : null,
        trailing: IconButton(
          icon: const Icon(Icons.more_vert, size: 18),
          onPressed: () => _showMenu(context),
          visualDensity: VisualDensity.compact,
        ),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      ),
    );
  }

  void _showMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Edit'),
              onTap: () { Navigator.pop(context); onTap(); },
            ),
            ListTile(
              leading: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
              title: Text('Delete', style: TextStyle(color: Theme.of(context).colorScheme.error)),
              onTap: () { Navigator.pop(context); onDelete(); },
            ),
          ],
        ),
      ),
    );
  }
}
