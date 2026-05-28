import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/models/subtask_model.dart';
import '../../../data/models/task_model.dart';
import '../../../data/repositories/tasks_repository.dart';
import '../../../presentation/providers/providers.dart';

class TaskEditorScreen extends ConsumerStatefulWidget {
  const TaskEditorScreen({super.key, this.taskId, this.initialQuadrant});

  final String? taskId;
  final String? initialQuadrant;

  @override
  ConsumerState<TaskEditorScreen> createState() => _TaskEditorScreenState();
}

class _TaskEditorScreenState extends ConsumerState<TaskEditorScreen> {
  TaskModel? _task;
  List<SubtaskModel> _subtasks = [];
  StreamSubscription? _subtaskSub;
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late Quadrant _quadrant;
  DateTime? _deadline;
  bool _loading = true;
  String? _uid;
  TasksRepository? _repo;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController();
    _descCtrl = TextEditingController();
    _quadrant = _parseQuadrant(widget.initialQuadrant) ?? Quadrant.doNow;
    WidgetsBinding.instance.addPostFrameCallback((_) => _init());
  }

  Quadrant? _parseQuadrant(String? name) {
    return Quadrant.values.where((q) => q.name == name).firstOrNull;
  }

  @override
  void dispose() {
    _subtaskSub?.cancel();
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    _uid = ref.read(currentUidProvider);
    _repo = ref.read(tasksRepositoryProvider);
    if (_uid == null || _repo == null) return;

    if (widget.taskId != null) {
      // Watch subtasks only — task meta loaded separately (simplified)
      _subtaskSub = _repo!.watchSubtasks(_uid!, widget.taskId!).listen(
        (s) => setState(() => _subtasks = s),
      );
    }
    setState(() => _loading = false);
  }

  Future<void> _save() async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Title is required')));
      return;
    }
    if (_uid == null || _repo == null) return;

    if (_task == null) {
      await _repo!.createTask(
        _uid!,
        title: title,
        quadrant: _quadrant,
        description: _descCtrl.text.trim(),
        deadline: _deadline,
      );
    } else {
      await _repo!.updateTask(
        _uid!,
        _task!.copyWith(
          title: title,
          description: _descCtrl.text.trim(),
          quadrant: _quadrant,
          deadline: _deadline,
          updatedAt: DateTime.now(),
        ),
      );
    }
    if (mounted) context.pop();
  }

  Future<void> _addSubtask() async {
    if (_task == null || _uid == null || _repo == null) return;
    final pos = _subtasks.isEmpty ? 1.0 : _subtasks.last.position + 1.0;
    await _repo!.createSubtask(_uid!, _task!.id, text: '', position: pos);
  }

  Future<void> _pickDeadline() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _deadline ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) setState(() => _deadline = picked);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEdit = _task != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit task' : 'New task'),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('Save', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                TextField(
                  controller: _titleCtrl,
                  decoration: const InputDecoration(labelText: 'Title *'),
                  textCapitalization: TextCapitalization.sentences,
                  autofocus: !isEdit,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _descCtrl,
                  decoration: const InputDecoration(labelText: 'Description (optional)'),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                Text('Quadrant', style: theme.textTheme.labelMedium),
                const SizedBox(height: 8),
                _QuadrantSelector(
                  value: _quadrant,
                  onChanged: (q) => setState(() => _quadrant = q),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.schedule),
                  title: Text(_deadline == null
                      ? 'Set deadline (optional)'
                      : 'Deadline: ${_deadline!.day}/${_deadline!.month}/${_deadline!.year}'),
                  trailing: _deadline != null
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => setState(() => _deadline = null),
                        )
                      : null,
                  onTap: _pickDeadline,
                  contentPadding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  tileColor: theme.colorScheme.surfaceContainerLow,
                ),
                if (_task != null) ...[
                  const SizedBox(height: 24),
                  Text('Subtasks', style: theme.textTheme.labelMedium),
                  const SizedBox(height: 8),
                  ..._subtasks.map(
                    (s) => CheckboxListTile(
                      key: ValueKey(s.id),
                      value: s.isCompleted,
                      onChanged: (v) => _repo?.toggleSubtaskComplete(_uid!, _task!.id, s.id, v ?? false),
                      title: Text(s.text),
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.add, size: 20),
                    title: const Text('Add subtask', style: TextStyle(fontSize: 14)),
                    onTap: _addSubtask,
                    contentPadding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
                ],
                const SizedBox(height: 80),
              ],
            ),
    );
  }
}

class _QuadrantSelector extends StatelessWidget {
  const _QuadrantSelector({required this.value, required this.onChanged});
  final Quadrant value;
  final ValueChanged<Quadrant> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _QuadrantChip(quadrant: Quadrant.doNow,    label: 'DO NOW',    selected: value == Quadrant.doNow,    color: kQuadrantDoColor,       onTap: () => onChanged(Quadrant.doNow)),
        _QuadrantChip(quadrant: Quadrant.schedule, label: 'SCHEDULE',  selected: value == Quadrant.schedule, color: kQuadrantScheduleColor,  onTap: () => onChanged(Quadrant.schedule)),
        _QuadrantChip(quadrant: Quadrant.delegate, label: 'DELEGATE',  selected: value == Quadrant.delegate, color: kQuadrantDelegateColor,  onTap: () => onChanged(Quadrant.delegate)),
        _QuadrantChip(quadrant: Quadrant.eliminate, label: 'ELIMINATE', selected: value == Quadrant.eliminate, color: kQuadrantEliminateColor, onTap: () => onChanged(Quadrant.eliminate)),
      ],
    );
  }
}

class _QuadrantChip extends StatelessWidget {
  const _QuadrantChip({required this.quadrant, required this.label, required this.selected, required this.color, required this.onTap});
  final Quadrant quadrant;
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color : color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color, width: selected ? 2 : 1),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? Colors.black87 : Colors.black54,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}

// Make color constants accessible locally
const kQuadrantDoColor = Color(0xFFFFDAD6);
const kQuadrantScheduleColor = Color(0xFFD3E4FD);
const kQuadrantDelegateColor = Color(0xFFFFECB3);
const kQuadrantEliminateColor = Color(0xFFE1E1E1);
