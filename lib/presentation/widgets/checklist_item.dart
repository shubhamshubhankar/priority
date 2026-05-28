import 'package:flutter/material.dart';

class ChecklistItem extends StatefulWidget {
  const ChecklistItem({
    super.key,
    required this.text,
    required this.isChecked,
    required this.onCheckedChanged,
    required this.onTextChanged,
    required this.onDelete,
    required this.onSubmit,
    this.autofocus = false,
  });

  final String text;
  final bool isChecked;
  final ValueChanged<bool> onCheckedChanged;
  final ValueChanged<String> onTextChanged;
  final VoidCallback onDelete;
  // Called when user presses Enter/Next — creates a new item below this one
  final VoidCallback onSubmit;
  final bool autofocus;

  @override
  State<ChecklistItem> createState() => _ChecklistItemState();
}

class _ChecklistItemState extends State<ChecklistItem> {
  late final TextEditingController _ctrl;
  late final FocusNode _focus;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.text);
    _focus = FocusNode();
    if (widget.autofocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _focus.requestFocus());
    }
  }

  @override
  void didUpdateWidget(ChecklistItem old) {
    super.didUpdateWidget(old);
    // Keep the controller in sync when text changes externally (e.g. after hot reload)
    if (old.text != widget.text && _ctrl.text != widget.text && !_focus.hasFocus) {
      _ctrl.text = widget.text;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isChecked = widget.isChecked;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: isChecked ? 0.45 : 1.0,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Checkbox(
            value: isChecked,
            onChanged: (v) => widget.onCheckedChanged(v ?? false),
            visualDensity: VisualDensity.compact,
          ),
          Expanded(
            child: TextField(
              controller: _ctrl,
              focusNode: _focus,
              style: theme.textTheme.bodyMedium?.copyWith(
                decoration: isChecked ? TextDecoration.lineThrough : null,
                decorationColor: theme.colorScheme.onSurface.withOpacity(0.4),
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                filled: false,
                contentPadding: EdgeInsets.symmetric(vertical: 10),
              ),
              onChanged: widget.onTextChanged,
              // Enter key creates a new item — delete is only via the × button
              textInputAction: TextInputAction.next,
              onSubmitted: (_) => widget.onSubmit(),
            ),
          ),
          // Delete button — only way to remove an item (not Enter)
          IconButton(
            icon: Icon(Icons.close, size: 16, color: theme.colorScheme.onSurface.withOpacity(0.35)),
            onPressed: widget.onDelete,
            visualDensity: VisualDensity.compact,
            splashRadius: 16,
            tooltip: 'Remove item',
          ),
        ],
      ),
    );
  }
}
