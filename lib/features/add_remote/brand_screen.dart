import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/providers.dart';

class BrandScreen extends ConsumerStatefulWidget {
  const BrandScreen({super.key});

  @override
  ConsumerState<BrandScreen> createState() => _BrandScreenState();
}

class _BrandScreenState extends ConsumerState<BrandScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final flow = ref.watch(addFlowProvider);
    final repo = ref.watch(irRepositoryProvider);
    final type = flow.deviceType ?? '';
    final allBrands = repo.brandsFor(type);
    final filtered = allBrands
        .where((b) => b.toLowerCase().contains(_query.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(title: Text('Select Brand ($type)')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search brand...',
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          Expanded(
            child: filtered.isEmpty
                ? const Center(child: Text('No brands found'))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filtered.length,
                    itemBuilder: (_, i) {
                      final brand = filtered[i];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 4),
                        child: ListTile(
                          title: Text(brand),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            ref.read(addFlowProvider.notifier).setBrand(brand);
                            context.push('/add/test');
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
