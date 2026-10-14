import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/providers.dart';
import '../../core/constants.dart';

class TestCodeScreen extends ConsumerStatefulWidget {
  const TestCodeScreen({super.key});

  @override
  ConsumerState<TestCodeScreen> createState() => _TestCodeScreenState();
}

class _TestCodeScreenState extends ConsumerState<TestCodeScreen> {
  bool _sending = false;

  Future<void> _sendPower() async {
    final flow = ref.read(addFlowProvider);
    final repo = ref.read(irRepositoryProvider);
    final ir = ref.read(irServiceProvider);
    final type = flow.deviceType ?? '';
    final codeSets = repo.codeSetsFor(type, flow.brand ?? '');
    if (codeSets.isEmpty) return;

    final idx = flow.codeSetIndex % codeSets.length;
    final cs = codeSets[idx];
    final signal = cs.buttons[Btn.power];
    if (signal == null) return;

    setState(() => _sending = true);
    try {
      final t = signal.toTransmission();
      await ir.transmit(t.freq, t.pattern);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('IR error: $e')),
        );
      }
    }
    if (mounted) setState(() => _sending = false);
  }

  @override
  Widget build(BuildContext context) {
    final flow = ref.watch(addFlowProvider);
    final repo = ref.watch(irRepositoryProvider);
    final ir = ref.watch(irServiceProvider);
    final type = flow.deviceType ?? '';
    final codeSets = repo.codeSetsFor(type, flow.brand ?? '');
    final total = codeSets.length;
    final idx = total > 0 ? flow.codeSetIndex % total : 0;
    final current = total > 0 ? codeSets[idx] : null;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Test Code')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            if (current?.sample == true)
              Container(
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: cs.secondaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.info_outline, size: 16),
                    const SizedBox(width: 8),
                    const Flexible(
                      child: Text('Sample data — not verified against real devices'),
                    ),
                  ],
                ),
              ),
            Text('Code set ${total > 0 ? idx + 1 : 0} of $total',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('${flow.brand} ${_typeLabel(type)}',
                style: Theme.of(context).textTheme.bodyLarge),
            const Spacer(),
            SizedBox(
              width: 160,
              height: 160,
              child: _sending
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _sendPower,
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        backgroundColor: cs.primary,
                        foregroundColor: cs.onPrimary,
                        elevation: 4,
                      ),
                      // child:  Text('POWER',
                      //     style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      child: const Icon(Icons.power_settings_new, size: 48),
                    ),
            ),
            const Spacer(),
            if (ir.demoMode && ir.lastPattern != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Demo: ${ir.lastFreq}',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(
                        'Pulses: ${ir.lastPattern!.length}, first: ${ir.lastPattern!.take(6).toList()}...'),
                  ],
                ),
              ),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      ref.read(addFlowProvider.notifier).nextCodeSet();
                      if (total > 0 && flow.codeSetIndex % total == 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Tried all code sets, starting over')),
                        );
                      }
                    },
                    child: const Text('Try Next Code'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: FilledButton(
                    onPressed: () {
                      if (current == null) return;
                      context.push('/add/save');
                    },
                    child: const Text('It Worked!'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
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
}
