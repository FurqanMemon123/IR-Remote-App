import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/providers.dart';

class DeviceTypeScreen extends ConsumerWidget {
  const DeviceTypeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final types = [
      ('ac', 'Air Conditioner', Icons.ac_unit),
      ('projector', 'Projector', Icons.present_to_all),
      ('dvd', 'DVD Player', Icons.album),
      ('bluray', 'Blu-ray Player', Icons.blur_on),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Select Device Type')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          children: [
            for (final (type, label, icon) in types)
              Card(
                child: InkWell(
                  onTap: () {
                    ref.read(addFlowProvider.notifier).setType(type);
                    context.push('/add/brand');
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, size: 48),
                      const SizedBox(height: 12),
                      Text(label, style: Theme.of(context).textTheme.titleMedium),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
