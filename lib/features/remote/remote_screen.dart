import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/providers.dart';
import 'ac_remote.dart';
import 'projector_remote.dart';
import 'dvd_remote.dart';

class RemoteScreen extends ConsumerWidget {
  final String remoteId;
  const RemoteScreen({super.key, required this.remoteId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remotesAsync = ref.watch(savedRemotesProvider);

    return remotesAsync.when(
      data: (remotes) {
        final remote = remotes.where((r) => r.id == remoteId).toList();
        if (remote.isEmpty) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Remote not found')),
          );
        }
        final r = remote.first;
        switch (r.type) {
          case 'ac':
            return AcRemoteScreen(remote: r);
          case 'projector':
            return ProjectorRemoteScreen(remote: r);
          case 'dvd':
          case 'bluray':
            return DvdRemoteScreen(remote: r);
          default:
            return Scaffold(
              appBar: AppBar(title: Text(r.name)),
              body: const Center(child: Text('Unknown remote type')),
            );
        }
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
    );
  }
}
