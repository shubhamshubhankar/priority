import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/models/goal_model.dart';
import '../../../data/models/milestone_model.dart';
import '../../../data/repositories/goals_repository.dart';
import '../../../presentation/providers/providers.dart';

class GoalEditorScreen extends ConsumerStatefulWidget {
  const GoalEditorScreen({super.key, this.goalId, this.initialHorizon});

  final String? goalId;
  final String? initialHorizon;

  @override
  ConsumerState<GoalEditorScreen> createState() => _GoalEditorScreenState();
}

class _GoalEditorScreenState extends ConsumerState<GoalEditorScreen> {
  GoalModel? _goal;
  List<MilestoneModel> _milestones = [];
  StreamSubscription? _milestoneSub;
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late GoalHorizon _horizon;
  DateTime? _targetDate;
  bool _loading = false;
  String? _uid;
  GoalsRepository? _repo;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController();
    _descCtrl = TextEditingController();
    _horizon = _parseHorizon(widget.initialHorizon) ?? GoalHorizon.shortTerm;
    WidgetsBinding.instance.addPostFrameCallback((_) => _init());
  }

  GoalHorizon? _parseHorizon(String? name) {
    return GoalHorizon.values.where((h) => h.name == name).firstOrNull;
  }

  @override
  void dispose() {
    _milestoneSub?.cancel();
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    _uid = ref.read(currentUidProvider);
    _repo = ref.read(goalsRepositoryProvider);
    if (_uid == null || _repo == null) return;

    if (widget.goalId != null) {
      _milestoneSub = _repo!.watchMilestones(_uid!, widget.goalId!).listen(
        (m) => setState(() => _milestones = m),
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

    if (_goal == null) {
      await _repo!.createGoal(_uid!, title: title, horizon: _horizon, description: _descCtrl.text.trim(), targetDate: _targetDate);
    } else {
      await _repo!.updateGoal(_uid!, _goal!.copyWith(title: title, description: _descCtrl.text.trim(), horizon: _horizon, targetDate: _targetDate, updatedAt: DateTime.now()));
    }
    if (mounted) context.pop();
  }

  Future<void> _addMilestone() async {
    if (_goal == null || _uid == null || _repo == null) return;
    final pos = _milestones.isEmpty ? 1.0 : _milestones.last.position + 1.0;
    await _repo!.createMilestone(_uid!, _goal!.id, title: '', position: pos);
  }

  Future<void> _pickTargetDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _targetDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
    );
    if (picked != null) setState(() => _targetDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEdit = _goal != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit goal' : 'New goal'),
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
                  decoration: const InputDecoration(labelText: 'Goal title *'),
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
                Text('Horizon', style: theme.textTheme.labelMedium),
                const SizedBox(height: 8),
                SegmentedButton<GoalHorizon>(
                  segments: const [
                    ButtonSegment(value: GoalHorizon.shortTerm, label: Text('Short-term'), icon: Icon(Icons.bolt)),
                    ButtonSegment(value: GoalHorizon.longTerm,  label: Text('Long-term'),  icon: Icon(Icons.flag)),
                  ],
                  selected: {_horizon},
                  onSelectionChanged: (s) => setState(() => _horizon = s.first),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: Text(_targetDate == null
                      ? 'Set target date (optional)'
                      : 'Target: ${_targetDate!.day}/${_targetDate!.month}/${_targetDate!.year}'),
                  trailing: _targetDate != null
                      ? IconButton(icon: const Icon(Icons.clear), onPressed: () => setState(() => _targetDate = null))
                      : null,
                  onTap: _pickTargetDate,
                  contentPadding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  tileColor: theme.colorScheme.surfaceContainerLow,
                ),
                if (isEdit) ...[
                  const SizedBox(height: 24),
                  Text('Milestones', style: theme.textTheme.labelMedium),
                  const SizedBox(height: 8),
                  ..._milestones.map(
                    (m) => CheckboxListTile(
                      key: ValueKey(m.id),
                      value: m.isCompleted,
                      onChanged: (v) => _repo?.toggleMilestoneComplete(_uid!, _goal!.id, m.id, v ?? false),
                      title: Text(m.title),
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.add, size: 20),
                    title: const Text('Add milestone', style: TextStyle(fontSize: 14)),
                    onTap: _addMilestone,
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
