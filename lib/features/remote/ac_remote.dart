import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../../data/models/ac_state.dart';
import '../../data/models/saved_remote.dart';
import '../../data/models/ir_signal.dart';
import '../../providers/providers.dart';
import 'widgets.dart';

class AcRemoteScreen extends ConsumerStatefulWidget {
  final SavedRemote remote;
  const AcRemoteScreen({super.key, required this.remote});

  @override
  ConsumerState<AcRemoteScreen> createState() => _AcRemoteScreenState();
}

class _AcRemoteScreenState extends ConsumerState<AcRemoteScreen> {
  late AcState _state;
  IrCodeSet? _codeSet;

  @override
  void initState() {
    super.initState();
    _state = widget.remote.acState ?? const AcState();
    _codeSet = ref.read(irRepositoryProvider).codeSetById(widget.remote.codeSetId);
  }

  Future<void> _send(String button) async {
    final signal = _codeSet?.buttons[button];
    if (signal == null) return;
    HapticFeedback.lightImpact();
    try {
      final t = signal.toTransmission();
      await ref.read(irServiceProvider).transmit(t.freq, t.pattern);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('IR error: $e')));
      }
    }
  }

  Future<void> _updateState(void Function() mutate) async {
    setState(mutate);
    final json = {
      ..._remoteToJson(widget.remote),
      'acState': _state.toJson(),
    };
    final r = SavedRemote.fromJson(json);
    await ref.read(savedRemotesProvider.notifier).updateRemote(r);
  }

  Map<String, dynamic> _remoteToJson(SavedRemote r) => {
        'id': r.id,
        'name': r.name,
        'room': r.room,
        'type': r.type,
        'brand': r.brand,
        'codeSetId': r.codeSetId,
        'createdAt': r.createdAt.toIso8601String(),
      };

  bool _has(String btn) => _codeSet?.buttons.containsKey(btn) == true;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final modes = ['cool', 'heat', 'dry', 'fan', 'auto'];
    final fans = ['auto', 'low', 'med', 'high'];

    return Scaffold(
      appBar: RemoteAppBar(remote: widget.remote),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        RemoteButton(
                          icon: Icons.remove,
                          size: 56,
                          onPressed: _has(Btn.tempDown)
                              ? () {
                                  _send(Btn.tempDown);
                                  if (_state.temp > 16) {
                                    _updateState(
                                        () => _state = _state.copyWith(temp: _state.temp - 1));
                                  }
                                }
                              : null,
                        ),
                        const SizedBox(width: 32),
                        Column(
                          children: [
                            Text('${_state.temp}°',
                                style: Theme.of(context)
                                    .textTheme
                                    .displayLarge
                                    ?.copyWith(fontWeight: FontWeight.bold)),
                            Text(_state.power ? 'ON' : 'OFF',
                                style: TextStyle(
                                    color: _state.power ? cs.primary : cs.error,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(width: 32),
                        RemoteButton(
                          // label: '+',
                          icon: Icons.add ,
                         
                          size: 56,
                          onPressed: _has(Btn.tempUp)
                              ? () {
                                  _send(Btn.tempUp);
                                  if (_state.temp < 30) {
                                    _updateState(
                                        () => _state = _state.copyWith(temp: _state.temp + 1));
                                  }
                                }
                              : null,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(_state.mode.toUpperCase(),
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        for (final m in modes)
                          ChoiceChip(
                            label: Text(m),
                            selected: _state.mode == m,
                            onSelected: _has(Btn.mode)
                                ? (_) {
                                    _send(Btn.mode);
                                    _updateState(() => _state = _state.copyWith(mode: m));
                                  }
                                : null,
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: [
                        for (final f in fans)
                          ChoiceChip(
                            label: Text(f),
                            selected: _state.fan == f,
                            onSelected: _has(Btn.fan)
                                ? (_) {
                                    _send(Btn.fan);
                                    _updateState(() => _state = _state.copyWith(fan: f));
                                  }
                                : null,
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Swing'),
                        const SizedBox(width: 8),
                        Switch(
                          value: _state.swing,
                          onChanged: _has(Btn.swing)
                              ? (v) {
                                  _send(Btn.swing);
                                  _updateState(() => _state = _state.copyWith(swing: v));
                                }
                              : null,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 100,
              height: 100,
              child: RemoteButton(
                // label: 'PWR',
                icon: Icons.power_settings_new_outlined,
                size: 100,
                color: _state.power ? cs.primaryContainer : cs.errorContainer,
                foregroundColor:
                    _state.power ? cs.onPrimaryContainer : cs.onErrorContainer,
                onPressed: _has(Btn.power)
                    ? () {
                        _send(Btn.power);
                        _updateState(() => _state = _state.copyWith(power: !_state.power));
                      }
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
