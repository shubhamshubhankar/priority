import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../data/models/note_model.dart';
import '../../data/models/note_item_model.dart';

class NoteCard extends StatelessWidget {
  const NoteCard({
    super.key,
    required this.note,
    required this.items,
    required this.onTap,
    required this.onLongPress,
    required this.onPinToggle,
  });

  final NoteModel note;
  final List<NoteItemModel> items;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onPinToggle;

  Color _cardColor(BuildContext context) {
    if (note.color != null && kNoteColors.containsKey(note.color)) {
      final base = kNoteColors[note.color]!;
      return Theme.of(context).brightness == Brightness.dark
          ? HSLColor.fromColor(base).withLightness(0.25).toColor()
          : base;
    }
    return Theme.of(context).colorScheme.surfaceContainerLow;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = _cardColor(context);
    final showItems = items.isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.colorScheme.outlineVariant, width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  if (note.title.isNotEmpty)
                    Expanded(
                      child: Text(
                        note.title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  if (note.isPinned)
                    Icon(Icons.push_pin, size: 14, color: theme.colorScheme.primary),
                ],
              ),
              if (note.title.isNotEmpty && showItems) const SizedBox(height: 6),
              if (showItems) ...[
                ...items.take(5).map(
                  (item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 1),
                    child: Row(
                      children: [
                        Icon(
                          item.isChecked ? Icons.check_box : Icons.check_box_outline_blank,
                          size: 14,
                          color: item.isChecked
                              ? theme.colorScheme.onSurface.withOpacity(0.35)
                              : theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            item.text,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: item.isChecked
                                  ? theme.colorScheme.onSurface.withOpacity(0.35)
                                  : null,
                              decoration: item.isChecked ? TextDecoration.lineThrough : null,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (items.length > 5)
                  Text(
                    '+${items.length - 5} more',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
              ],
              if (note.title.isEmpty && !showItems)
                Text(
                  'Empty note',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.4),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
