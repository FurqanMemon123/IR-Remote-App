import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/saved_remote.dart';
import '../../providers/providers.dart';

class RemoteButton extends ConsumerWidget {
  final String? label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final double size;
  final Color? color;
  final Color? foregroundColor;
  final bool longPress;

  const RemoteButton({
    super.key,
    this.label,
    this.icon,
    this.onPressed,
    this.size = 56,
    this.color,
    this.foregroundColor,
    this.longPress = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final enabled = onPressed != null;
    final bgColor = color ?? cs.surfaceContainerHighest;
    final fgColor = enabled ? (foregroundColor ?? cs.onSurface) : cs.outline;

    return GestureDetector(
      onLongPress: longPress && enabled ? onPressed : null,
      child: Material(
        color: enabled ? bgColor : bgColor.withValues(alpha: 0.3),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: enabled ? onPressed : null,
          child: SizedBox(
            width: size,
            height: size,
            child: Center(
              child: icon != null
                  ? Icon(icon, color: fgColor, size: size * 0.4)
                  : Text(
                      label ?? '',
                      style: TextStyle(color: fgColor, fontSize: size * 0.22),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class RemoteAppBar extends ConsumerStatefulWidget
    implements PreferredSizeWidget {
  final SavedRemote remote;
  const RemoteAppBar({super.key, required this.remote});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  ConsumerState<RemoteAppBar> createState() => _RemoteAppBarState();
}

class _RemoteAppBarState extends ConsumerState<RemoteAppBar> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(widget.remote.name),
      actions: [
        PopupMenuButton<String>(
          onSelected: (v) {
            switch (v) {
              case 'rename':
                _showRename(context, ref);
              case 'delete':
                _confirmDelete(context, ref);
            }
          },
          itemBuilder: (_) => [
            const PopupMenuItem(value: 'rename', child: Text('Rename')),
            const PopupMenuItem(
              value: 'delete',
              child: Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ],
    );
  }

  void _showRename(BuildContext context, WidgetRef ref) {
    final c = TextEditingController(text: widget.remote.name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rename'),
        content: TextField(controller: c, autofocus: true),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref
                  .read(savedRemotesProvider.notifier)
                  .updateRemote(widget.remote.copyWith(name: c.text));
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Remote?'),
        content: Text('Remove "${widget.remote.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref
                  .read(savedRemotesProvider.notifier)
                  .deleteRemote(widget.remote.id);
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
