import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class OfflineBanner extends StatefulWidget {
  const OfflineBanner({super.key});

  @override
  State<OfflineBanner> createState() => _OfflineBannerState();
}

class _OfflineBannerState extends State<OfflineBanner> {
  bool _isOffline = false;

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    Connectivity().onConnectivityChanged.listen((results) {
      _updateStatus(results);
    });
  }

  Future<void> _checkConnectivity() async {
    final results = await Connectivity().checkConnectivity();
    _updateStatus(results);
  }

  void _updateStatus(List<ConnectivityResult> results) {
    final offline = results.isEmpty ||
        results.every((r) => r == ConnectivityResult.none);
    if (mounted) setState(() => _isOffline = offline);
  }

  @override
  Widget build(BuildContext context) {
    if (!_isOffline) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      color: Colors.grey[800],
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      child: const Row(children: [
        Icon(Icons.wifi_off, color: Colors.white, size: 16),
        SizedBox(width: 8),
        Text("You're offline. Showing cached content.",
            style: TextStyle(color: Colors.white, fontSize: 12)),
      ]),
    );
  }
}
