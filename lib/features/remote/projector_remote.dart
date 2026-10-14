import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../../data/models/saved_remote.dart';
import '../../data/models/ir_signal.dart';
import '../../providers/providers.dart';
import 'widgets.dart';

class ProjectorRemoteScreen extends ConsumerWidget {
  final SavedRemote remote;
  const ProjectorRemoteScreen({super.key, required this.remote});

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

    return Scaffold(
      appBar: RemoteAppBar(remote: remote),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                RemoteButton(
                  // label: 'PWR',
                  icon: Icons.power_settings_new,
                  size: 72,
                  color: Color(Colors.red.value),
                  onPressed: codeSet?.buttons.containsKey(Btn.power) == true
                      ? () => _send(ref, Btn.power, context)
                      : null,
                ),
                RemoteButton(
                  label: 'MUTE',
                  size: 56,
                  onPressed: codeSet?.buttons.containsKey(Btn.mute) == true
                      ? () => _send(ref, Btn.mute, context)
                      : null,
                ),
                RemoteButton(
                  label: 'SRC',
                  size: 56,
                  onPressed: codeSet?.buttons.containsKey(Btn.source) == true
                      ? () => _send(ref, Btn.source, context)
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RemoteButton(
                  label: 'V-',
                  size: 56,
                  longPress: true,
                  onPressed: codeSet?.buttons.containsKey(Btn.volDown) == true
                      ? () => _send(ref, Btn.volDown, context)
                      : null,
                ),
                const SizedBox(width: 32),
                RemoteButton(
                  label: 'V+',
                  size: 56,
                  longPress: true,
                  onPressed: codeSet?.buttons.containsKey(Btn.volUp) == true
                      ? () => _send(ref, Btn.volUp, context)
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildDPad(context, ref, codeSet),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                RemoteButton(
                  label: 'MENU',
                  size: 56,
                  onPressed: codeSet?.buttons.containsKey(Btn.menu) == true
                      ? () => _send(ref, Btn.menu, context)
                      : null,
                ),
                RemoteButton(
                  label: 'BACK',
                  size: 56,
                  onPressed: codeSet?.buttons.containsKey(Btn.back) == true
                      ? () => _send(ref, Btn.back, context)
                      : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDPad(BuildContext context, WidgetRef ref, IrCodeSet? codeSet) {
    bool has(String b) => codeSet?.buttons.containsKey(b) == true;

    return SizedBox(
      width: 200,
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
          ),
          Positioned(
            top: 8,
            child: RemoteButton(
              icon: Icons.arrow_drop_up,
              size: 48,
              onPressed: has(Btn.up) ? () => _send(ref, Btn.up, context) : null,
            ),
          ),
          Positioned(
            bottom: 8,
            child: RemoteButton(
              icon: Icons.arrow_drop_down,
              size: 48,
              onPressed: has(Btn.down) ? () => _send(ref, Btn.down, context) : null,
            ),
          ),
          Positioned(
            left: 8,
            child: RemoteButton(
              icon: Icons.arrow_left,
              size: 48,
              onPressed: has(Btn.left) ? () => _send(ref, Btn.left, context) : null,
            ),
          ),
          Positioned(
            right: 8,
            child: RemoteButton(
              icon: Icons.arrow_right,
              size: 48,
              onPressed: has(Btn.right) ? () => _send(ref, Btn.right, context) : null,
            ),
          ),
          RemoteButton(
            label: 'OK',
            size: 56,
            onPressed: has(Btn.ok) ? () => _send(ref, Btn.ok, context) : null,
          ),
        ],
      ),
    );
  }
}
