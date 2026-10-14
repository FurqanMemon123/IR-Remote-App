import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/providers.dart';
import '../../data/models/saved_remote.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remotesAsync = ref.watch(savedRemotesProvider);
    final ir = ref.watch(irServiceProvider);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('IR Remote'),
        actions: [
          if (ir.demoMode)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Chip(
                avatar: const Icon(Icons.wifi_off, size: 16),
                label: const Text('Demo'),
                backgroundColor: cs.secondaryContainer,
              ),
            ),
        ],
      ),
      body: remotesAsync.when(
        data: (remotes) {
          if (remotes.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.settings_remote, size: 80, color: cs.outline),
                    const SizedBox(height: 16),
                    Text('No remotes yet',
                        style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 8),
                    Text(
                      'Tap + to add your first remote control',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            );
          }
          final grouped = <String, List<SavedRemote>>{};
          for (final r in remotes) {
            grouped.putIfAbsent(r.room, () => []).add(r);
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              for (final entry in grouped.entries) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(entry.key,
                      style: Theme.of(context).textTheme.titleMedium),
                ),
                for (final r in entry.value) _RemoteCard(remote: r),
              ],
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ref.read(addFlowProvider.notifier).reset();
          context.push('/add/type');
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Remote'),
      ),
    );
  }
}

class _RemoteCard extends ConsumerWidget {
  final SavedRemote remote;
  const _RemoteCard({required this.remote});

  IconData _iconFor(String type) {
    switch (type) {
      case 'ac':
        return Icons.ac_unit;
      case 'projector':
        return Icons.present_to_all;
      case 'dvd':
      return Icons.album;
      case 'bluray':
        return Icons.blur_on_outlined;
      default:
        return Icons.settings_remote;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(_iconFor(remote.type), size: 32),
        title: Text(remote.name),
        subtitle: Text('${remote.brand} · ${remote.room}'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push('/remote/${remote.id}'),
        onLongPress: () => _showOptions(context, ref),
      ),
    );
  }

  void _showOptions(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(remote.name),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _showRename(context, ref);
            },
            child: const Text('Rename'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _confirmDelete(context, ref);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
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
        content: Text('Remove "${remote.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              ref.read(savedRemotesProvider.notifier).deleteRemote(remote.id);
              Navigator.pop(ctx);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showRename(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController(text: remote.name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rename'),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              final updated = remote.copyWith(name: controller.text);
              ref.read(savedRemotesProvider.notifier).updateRemote(updated);
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
