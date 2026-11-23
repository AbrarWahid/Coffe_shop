import 'dart:async';

import 'package:flutter/widgets.dart';

/// Rebuilds [builder] periodically so simulated order statuses advance.
class LiveClock extends StatefulWidget {
  const LiveClock({super.key, required this.builder});

  final Widget Function(BuildContext context, DateTime now) builder;

  @override
  State<LiveClock> createState() => _LiveClockState();
}

class _LiveClockState extends State<LiveClock> {
  late final Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(
      const Duration(seconds: 15),
      (_) => setState(() {}),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, DateTime.now());
}
