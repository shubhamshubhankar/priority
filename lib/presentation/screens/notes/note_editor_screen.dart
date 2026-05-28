import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/models/note_item_model.dart';
import '../../../data/models/note_model.dart';
import '../../../data/repositories/notes_repository.dart';
import '../../../presentation/providers/providers.dart';
import '../../../presentation/widgets/checklist_item.dart';

class NoteEditorScreen extends ConsumerStatefulWidget {
  const NoteEditorScreen({super.key, this.noteId});

  final String? noteId;

  @override
  ConsumerState<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends ConsumerState<NoteEditorScreen> {
  NoteModel? _note;
  List<NoteItemModel> _items = [];
  StreamSubscription? _itemsSub;
  late final TextEditingController _titleCtrl;
  bool _loading = true;
  String? _uid;
  NotesRepository? _repo;
  Timer? _saveTimer;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _init());
  }

  @override
  void dispose() {
    // Flush any pending title save synchronously before leaving
    _saveTimer?.cancel();
    if (_note != null && _uid != null && _repo != null) {
      final title = _titleCtrl.text;
      if (title != _note!.title) {
        _repo!.updateNote(_uid!, _note!.copyWith(title: title, updatedAt: DateTime.now()));
      }
    }
    _itemsSub?.cancel();
    _titleCtrl.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    _uid = ref.read(currentUidProvider);
    _repo = ref.read(notesRepositoryProvider);
    if (_uid == null || _repo == null) return;

    if (widget.noteId == null) {
      // New note: create document first, then edit
      final note = await _repo!.createNote(_uid!, title: '');
      if (!mounted) return;
      setState(() { _note = note; _loading = false; });
      _subscribeItems(note.id);
    } else {
      // Existing note: fetch current metadata to populate the title field
      final doc = await FirebaseFirestore.instance
          .collection('users/$_uid/notes')
          .doc(widget.noteId!)
          .get();
      if (!mounted) return;
      if (doc.exists) {
        final data = doc.data()!;
        final note = NoteModel.fromJson({
          ...data,
          'id': doc.id,
          if (data['createdAt'] is Timestamp)
            'createdAt': (data['createdAt'] as Timestamp).toDate().toIso8601String(),
          if (data['updatedAt'] is Timestamp)
            'updatedAt': (data['updatedAt'] as Timestamp).toDate().toIso8601String(),
        });
        setState(() {
          _note = note;
          _titleCtrl.text = note.title;
          _loading = false;
        });
      } else {
        setState(() => _loading = false);
      }
      _subscribeItems(widget.noteId!);
    }
  }

  void _subscribeItems(String noteId) {
    _itemsSub?.cancel();
    _itemsSub = _repo!.watchItems(_uid!, noteId).listen((items) {
      if (mounted) setState(() => _items = items);
    });
  }

  void _onTitleChanged(String v) {
    // Keep _note in sync so dispose() always saves the latest value
    if (_note != null) _note = _note!.copyWith(title: v);
    // Debounce the actual Firestore write
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 600), () {
      if (_note != null && _uid != null) {
        _repo?.updateNote(_uid!, _note!.copyWith(title: v, updatedAt: DateTime.now()));
      }
    });
  }

  Future<void> _addItem() async {
    if (_note == null || _uid == null) return;
    final position = _items.isEmpty ? 1.0 : _items.last.position + 1.0;
    await _repo?.createItem(_uid!, _note!.id, text: '', position: position);
    // Firestore stream delivers the new item; autofocus is set via _lastAddedId
    setState(() => _lastAddedPosition = position);
  }

  double? _lastAddedPosition;

  Future<void> _toggleItem(NoteItemModel item, bool checked) async {
    if (_uid == null || _note == null) return;
    await _repo?.toggleItemChecked(_uid!, _note!.id, item.id, checked);
  }

  Future<void> _updateItemText(NoteItemModel item, String text) async {
    if (_uid == null || _note == null) return;
    await _repo?.updateItem(_uid!, _note!.id, item.copyWith(text: text));
  }

  Future<void> _deleteItem(NoteItemModel item) async {
    if (_uid == null || _note == null) return;
    await _repo?.deleteItem(_uid!, _note!.id, item.id);
  }

  Future<void> _togglePin() async {
    if (_note == null || _uid == null) return;
    final updated = _note!.copyWith(isPinned: !_note!.isPinned);
    setState(() => _note = updated);
    await _repo?.togglePin(_uid!, _note!.id, updated.isPinned);
  }

  Future<void> _delete() async {
    if (_note == null || _uid == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete note?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed == true) {
      _saveTimer?.cancel(); // don't save a deleted note
      await _repo?.deleteNote(_uid!, _note!.id);
      _note = null;
      if (mounted) context.pop();
    }
  }

  void _showColorPicker() {
    showModalBottomSheet(
      context: context,
      builder: (_) => _ColorPicker(
        selected: _note?.color,
        onSelected: (color) async {
          Navigator.pop(context);
          if (_note != null && _uid != null) {
            final updated = _note!.copyWith(color: color);
            setState(() => _note = updated);
            await _repo?.updateNote(_uid!, updated);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final noteColor = _note?.color != null && kNoteColors.containsKey(_note!.color)
        ? kNoteColors[_note!.color]!
        : null;

    return Scaffold(
      backgroundColor: noteColor ?? theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: noteColor ?? theme.colorScheme.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Note', style: TextStyle(fontSize: 16)),
        actions: [
          if (_note != null)
            IconButton(
              icon: Icon(_note!.isPinned ? Icons.push_pin : Icons.push_pin_outlined),
              onPressed: _togglePin,
              tooltip: _note!.isPinned ? 'Unpin' : 'Pin',
            ),
          if (_note != null)
            IconButton(
              icon: const Icon(Icons.palette_outlined),
              onPressed: _showColorPicker,
              tooltip: 'Change color',
            ),
          if (_note != null)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _delete,
              tooltip: 'Delete',
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: TextField(
                    controller: _titleCtrl,
                    onChanged: _onTitleChanged,
                    decoration: const InputDecoration(
                      hintText: 'Title',
                      border: InputBorder.none,
                      filled: false,
                      contentPadding: EdgeInsets.zero,
                    ),
                    style: theme.textTheme.headlineSmall,
                    maxLines: null,
                    autofocus: widget.noteId == null,
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.only(bottom: 80),
                    children: [
                      ..._items.map(
                        (item) => ChecklistItem(
                          key: ValueKey(item.id),
                          text: item.text,
                          isChecked: item.isChecked,
                          onCheckedChanged: (v) => _toggleItem(item, v),
                          onTextChanged: (v) => _updateItemText(item, v),
                          onDelete: () => _deleteItem(item),
                          onSubmit: _addItem,
                          autofocus: item.position == _lastAddedPosition,
                        ),
                      ),
                      ListTile(
                        leading: const Icon(Icons.add, size: 20),
                        title: const Text('Add item', style: TextStyle(fontSize: 14)),
                        onTap: _addItem,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _ColorPicker extends StatelessWidget {
  const _ColorPicker({required this.selected, required this.onSelected});

  final String? selected;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Note color', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _ColorCircle(color: null, selected: selected == null, onTap: () => onSelected(null)),
                ...kNoteColors.entries.map(
                  (e) => _ColorCircle(
                    color: e.value,
                    selected: selected == e.key,
                    onTap: () => onSelected(e.key),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ColorCircle extends StatelessWidget {
  const _ColorCircle({required this.color, required this.selected, required this.onTap});
  final Color? color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color ?? Theme.of(context).colorScheme.surface,
          shape: BoxShape.circle,
          border: Border.all(
            color: selected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outlineVariant,
            width: selected ? 3 : 1,
          ),
        ),
        child: color == null
            ? const Icon(Icons.block, size: 18)
            : selected
                ? const Icon(Icons.check, size: 16)
                : null,
      ),
    );
  }
}
