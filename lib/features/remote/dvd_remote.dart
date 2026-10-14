import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../../data/models/saved_remote.dart';
import '../../data/models/ir_signal.dart';
import '../../providers/providers.dart';
import 'widgets.dart';

class DvdRemoteScreen extends ConsumerWidget {
  final SavedRemote remote;
  const DvdRemoteScreen({super.key, required this.remote});

  IrCodeSet? _codeSet(WidgetRef ref) =>
      ref.read(irRepositoryProvider).codeSetById(remote.codeSetId);

  Future<void> _send(WidgetRef ref, String button, BuildContext context) async {
    final signal = _codeSet(ref)?.buttons[button];
    if (signal == null) return;
    HapticFeedback.lightImpact();
    try {
      final t = signal.toTransmission();
      await ref.read(irServiceProvider).transmit(t.freq, t.pattern);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('IR error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final codeSet = _codeSet(ref);
    bool has(String b) => codeSet?.buttons.containsKey(b) == true;

    return Scaffold(
      appBar: RemoteAppBar(remote: remote),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                RemoteButton(
                  // label: 'PWR',
                  icon: Icons.power_settings_new,
                  size: 64,
                  color: Color(Colors.red.value),
                  onPressed: has(Btn.power) ? () => _send(ref, Btn.power, context) : null,
                ),
                RemoteButton(
                  label: 'EJECT',
                  size: 56,
                  icon: Icons.eject,
                  onPressed: has(Btn.eject) ? () => _send(ref, Btn.eject, context) : null,
                ),
                RemoteButton(
                  label: 'MENU',
                  size: 56,
                  onPressed: has(Btn.menu) ? () => _send(ref, Btn.menu, context) : null,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  RemoteButton(
                    icon: Icons.fast_rewind,
                    size: 48,
                    longPress: true,
                    onPressed: has(Btn.rew) ? () => _send(ref, Btn.rew, context) : null,
                  ),
                  RemoteButton(
                    icon: Icons.skip_previous,
                    size: 48,
                    onPressed: has(Btn.prev) ? () => _send(ref, Btn.prev, context) : null,
                  ),
                  RemoteButton(
                    icon: Icons.play_arrow,
                    size: 48,
                    onPressed: has(Btn.play) ? () => _send(ref, Btn.play, context) : null,
                  ),
                  RemoteButton(
                    icon: Icons.pause,
                    size: 48,
                    onPressed: has(Btn.pause) ? () => _send(ref, Btn.pause, context) : null,
                  ),
                  RemoteButton(
                    icon: Icons.stop,
                    size: 48,
                    onPressed: has(Btn.stop) ? () => _send(ref, Btn.stop, context) : null,
                  ),
                  RemoteButton(
                    icon: Icons.skip_next,
                    size: 48,
                    onPressed: has(Btn.next) ? () => _send(ref, Btn.next, context) : null,
                  ),
                  RemoteButton(
                    icon: Icons.fast_forward,
                    size: 48,
                    longPress: true,
                    onPressed: has(Btn.ff) ? () => _send(ref, Btn.ff, context) : null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildDPad(context, ref, codeSet),
            const SizedBox(height: 24),
            _buildNumberPad(context, ref, codeSet),
          ],
        ),
      ),
    );
  }

  Widget _buildDPad(BuildContext context, WidgetRef ref, IrCodeSet? codeSet) {
    bool has(String b) => codeSet?.buttons.containsKey(b) == true;

    return SizedBox(
      width: 180,
      height: 180,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
          ),
          Positioned(
            top: 4,
            child: RemoteButton(
              icon: Icons.arrow_drop_up,
              size: 44,
              onPressed: has(Btn.up) ? () => _send(ref, Btn.up, context) : null,
            ),
          ),
          Positioned(
            bottom: 4,
            child: RemoteButton(
              icon: Icons.arrow_drop_down,
              size: 44,
              onPressed: has(Btn.down) ? () => _send(ref, Btn.down, context) : null,
            ),
          ),
          Positioned(
            left: 4,
            child: RemoteButton(
              icon: Icons.arrow_left,
              size: 44,
              onPressed: has(Btn.left) ? () => _send(ref, Btn.left, context) : null,
            ),
          ),
          Positioned(
            right: 4,
            child: RemoteButton(
              icon: Icons.arrow_right,
              size: 44,
              onPressed: has(Btn.right) ? () => _send(ref, Btn.right, context) : null,
            ),
          ),
          RemoteButton(
            label: 'OK',
            size: 100,
            onPressed: has(Btn.ok) ? () => _send(ref, Btn.ok, context) : null,
          ),
        ],
      ),
    );
  }

  Widget _buildNumberPad(BuildContext context, WidgetRef ref, IrCodeSet? codeSet) {
    bool has(String b) => codeSet?.buttons.containsKey(b) == true;
    final keys = [Btn.n1, Btn.n2, Btn.n3, Btn.n4, Btn.n5, Btn.n6, Btn.n7, Btn.n8, Btn.n9, null, Btn.n0, null];

    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 1.5,
      children: [
        for (final k in keys)
          if (k == null)
            const SizedBox.shrink()
          else
            RemoteButton(
              label: k,
              size: 100,
              onPressed: has(k) ? () => _send(ref, k, context) : null,
            ),
      ],
    );
  }
}
