import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../providers/providers.dart';
import '../../data/models/saved_remote.dart';

class SaveRemoteScreen extends ConsumerStatefulWidget {
  const SaveRemoteScreen({super.key});

  @override
  ConsumerState<SaveRemoteScreen> createState() => _SaveRemoteScreenState();
}

class _SaveRemoteScreenState extends ConsumerState<SaveRemoteScreen> {
  final _nameController = TextEditingController();
  String _room = 'Living Room';
  String? _customRoom;
  static const _rooms = ['Living Room', 'Bedroom', 'Kitchen', 'Office', 'Meeting Room'];

  @override
  void initState() {
    super.initState();
    final flow = ref.read(addFlowProvider);
    _nameController.text = '${flow.brand ?? ''} ${_typeLabel(flow.deviceType ?? '')}';
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  String _typeLabel(String type) {
    switch (type) {
      case 'ac':
        return 'AC';
      case 'projector':
        return 'Projector';
      case 'dvd':
        return 'DVD';
      case 'bluray':
        return 'Blu-ray';
      default:
        return type;
    }
  }

  Future<void> _save() async {
    final flow = ref.read(addFlowProvider);
    final repo = ref.read(irRepositoryProvider);
    final type = flow.deviceType ?? '';
    final codeSets = repo.codeSetsFor(type, flow.brand ?? '');
    if (codeSets.isEmpty) return;

    final idx = flow.codeSetIndex % codeSets.length;
    final codeSet = codeSets[idx];
    final room = _customRoom?.isNotEmpty == true ? _customRoom! : _room;

    final remote = SavedRemote(
      id: const Uuid().v4(),
      name: _nameController.text.trim().isEmpty
          ? '${flow.brand} ${_typeLabel(type)}'
          : _nameController.text.trim(),
      room: room,
      type: type,
      brand: flow.brand ?? '',
      codeSetId: codeSet.id,
      createdAt: DateTime.now(),
    );

    await ref.read(savedRemotesProvider.notifier).addRemote(remote);
    ref.read(addFlowProvider.notifier).reset();
    if (mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Save Remote')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Remote Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            Text('Room', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                for (final r in _rooms)
                  ChoiceChip(
                    label: Text(r),
                    selected: _room == r && (_customRoom?.isEmpty ?? true),
                    onSelected: (_) => setState(() {
                      _room = r;
                      _customRoom = null;
                    }),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Custom room name',
                border: OutlineInputBorder(),
                hintText: 'Or type a custom room...',
              ),
              onChanged: (v) => setState(() => _customRoom = v),
            ),
            const Spacer(),
            FilledButton(
              onPressed: _save,
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Save Remote', style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
