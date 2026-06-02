import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

import '../di/injection.dart';
import '../network/connectivity_service.dart';
import 'no_internet_screen.dart';

/// Blocks the app UI when offline; shows [NoInternetScreen] until connection returns.
class ConnectivityGate extends StatefulWidget {
  const ConnectivityGate({super.key, required this.child});

  final Widget child;

  @override
  State<ConnectivityGate> createState() => _ConnectivityGateState();
}

class _ConnectivityGateState extends State<ConnectivityGate> {
  late final ConnectivityService _connectivity;
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _isOnline = true;
  bool _checking = false;

  @override
  void initState() {
    super.initState();
    _connectivity = sl<ConnectivityService>();
    _refreshStatus();
    _subscription = _connectivity.onConnectivityChanged.listen((_) {
      _refreshStatus();
    });
  }

  Future<void> _refreshStatus() async {
    final online = await _connectivity.isConnected;
    if (mounted) setState(() => _isOnline = online);
  }

  Future<void> _retry() async {
    setState(() => _checking = true);
    await _refreshStatus();
    if (mounted) setState(() => _checking = false);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        if (!_isOnline)
          NoInternetScreen(
            onRetry: _retry,
            isRetrying: _checking,
          ),
      ],
    );
  }
}
