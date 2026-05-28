import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/debouncer.dart';
import '../../../data/models/note_item_model.dart';
import '../../../presentation/providers/providers.dart';
import '../../../presentation/widgets/empty_state.dart';
import '../../../presentation/widgets/loading_shimmer.dart';
import '../../../presentation/widgets/note_card.dart';
import 'notes_bloc.dart';
import 'notes_event.dart';
import 'notes_state.dart';

class NotesScreen extends ConsumerStatefulWidget {
  const NotesScreen({super.key});

  @override
  ConsumerState<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends ConsumerState<NotesScreen> {
  late final NotesBloc _bloc;
  final _debouncer = Debouncer();
  final _searchCtrl = TextEditingController();

  // Cache items per note from Firestore streams (simplified: we load items on demand)
  final Map<String, List<NoteItemModel>> _itemCache = {};

  @override
  void initState() {
    super.initState();
    final uid = ref.read(currentUidProvider);
    _bloc = NotesBloc(ref.read(notesRepositoryProvider));
    if (uid != null) _bloc.add(NotesSubscribed(uid));
  }

  @override
  void dispose() {
    _bloc.close();
    _debouncer.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearchChanged(String q) {
    _debouncer(() => _bloc.add(NoteSearched(q)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final uid = ref.watch(currentUidProvider);

    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Notes'),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: TextField(
                controller: _searchCtrl,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: 'Search notes...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchCtrl.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchCtrl.clear();
                            _bloc.add(const NoteSearched(''));
                          },
                        )
                      : null,
                ),
              ),
            ),
          ),
          actions: [
            _UserAvatar(uid: uid),
            const SizedBox(width: 8),
          ],
        ),
        body: BlocBuilder<NotesBloc, NotesState>(
          builder: (context, state) {
            if (state is NotesLoading || state is NotesInitial) {
              return const LoadingShimmer();
            }
            if (state is NotesError) {
              return Center(child: Text(state.message));
            }
            if (state is NotesLoaded) {
              final pinned = state.pinned;
              final unpinned = state.unpinned;

              if (pinned.isEmpty && unpinned.isEmpty) {
                return EmptyState(
                  icon: Icons.sticky_note_2_outlined,
                  title: state.searchQuery.isNotEmpty
                      ? 'No notes match "${state.searchQuery}"'
                      : 'No notes yet',
                  subtitle: 'Tap + to create your first note',
                );
              }

              return CustomScrollView(
                slivers: [
                  if (pinned.isNotEmpty) ...[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                        child: Text(
                          'PINNED',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.5),
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      sliver: SliverMasonryGrid.count(
                        crossAxisCount: 2,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        childCount: pinned.length,
                        itemBuilder: (_, i) => _buildCard(context, pinned[i], uid),
                      ),
                    ),
                  ],
                  if (unpinned.isNotEmpty) ...[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                        child: Text(
                          pinned.isNotEmpty ? 'OTHERS' : 'NOTES',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.5),
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 80),
                      sliver: SliverMasonryGrid.count(
                        crossAxisCount: 2,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        childCount: unpinned.length,
                        itemBuilder: (_, i) => _buildCard(context, unpinned[i], uid),
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
          onPressed: () => context.push('/notes/new'),
          icon: const Icon(Icons.add),
          label: const Text('New note'),
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, note, String? uid) {
    return NoteCard(
      note: note,
      items: _itemCache[note.id] ?? [],
      onTap: () => context.push('/notes/${note.id}'),
      onLongPress: () => _showNoteOptions(context, note, uid),
      onPinToggle: () {
        if (uid != null) {
          _bloc.add(NotePinToggled(uid: uid, noteId: note.id, isPinned: !note.isPinned));
        }
      },
    );
  }

  void _showNoteOptions(BuildContext context, note, String? uid) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(note.isPinned ? Icons.push_pin_outlined : Icons.push_pin),
              title: Text(note.isPinned ? 'Unpin' : 'Pin'),
              onTap: () {
                Navigator.pop(context);
                if (uid != null) {
                  _bloc.add(NotePinToggled(uid: uid, noteId: note.id, isPinned: !note.isPinned));
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
              title: Text('Delete', style: TextStyle(color: Theme.of(context).colorScheme.error)),
              onTap: () {
                Navigator.pop(context);
                if (uid != null) _bloc.add(NoteDeleted(uid: uid, noteId: note.id));
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _UserAvatar extends ConsumerWidget {
  const _UserAvatar({this.uid});
  final String? uid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    if (user == null) return const SizedBox.shrink();
    return PopupMenuButton<String>(
      child: CircleAvatar(
        radius: 16,
        backgroundImage: user.photoURL != null ? NetworkImage(user.photoURL!) : null,
        child: user.photoURL == null ? const Icon(Icons.person, size: 16) : null,
      ),
      onSelected: (v) {
        if (v == 'sign_out') {
          ref.read(authRepositoryProvider).signOut();
        }
      },
      itemBuilder: (_) => [
        const PopupMenuItem(
          value: 'sign_out',
          child: Row(children: [
            Icon(Icons.logout),
            SizedBox(width: 8),
            Text('Sign out'),
          ]),
        ),
      ],
    );
  }
}
