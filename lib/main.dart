import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart';

import 'home_page.dart';
import 'login_page.dart';
import 'state/app_state.dart';
import 'theme/app_theme.dart';
import 'widgets/brand_mark.dart';

void main() {
  DevicePreview.enable(); // otomatis off di release build
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key, this.state});

  /// Injectable for tests; a default instance is created otherwise.
  final AppState? state;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AppState _state = widget.state ?? AppState();
  final _navigatorKey = GlobalKey<NavigatorState>();
  String? _lastUser;

  @override
  void initState() {
    super.initState();
    _state.addListener(_onSessionChanged);
    if (!_state.ready) _state.init();
  }

  /// Any route pushed on top of the auth/home root (register, detail,
  /// account…) belongs to the previous session, so clear it on sign in/out.
  void _onSessionChanged() {
    final user = _state.account?.username;
    if (user == _lastUser) return;
    _lastUser = user;
    _navigatorKey.currentState?.popUntil((route) => route.isFirst);
  }

  @override
  void dispose() {
    _state.removeListener(_onSessionChanged);
    if (widget.state == null) _state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      state: _state,
      child: MaterialApp(
        title: 'Coffee Shop',
        navigatorKey: _navigatorKey,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: ListenableBuilder(
          listenable: _state,
          builder: (context, _) {
            // No cross-fade here: two Scaffolds alive at once would both
            // render the same SnackBar. Each page animates its own entrance.
            if (!_state.ready) return const _Splash();
            if (_state.account == null) return const LoginPage();
            return HomePage(key: ValueKey(_state.account!.username));
          },
        ),
      ),
    );
  }
}

class _Splash extends StatelessWidget {
  const _Splash();

  @override
  Widget build(BuildContext context) => const Scaffold(
    backgroundColor: AppColors.espresso,
    body: Center(child: BrandMark(light: true)),
  );
}
