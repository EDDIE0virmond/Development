import 'package:flutter/material.dart';
import 'core/network/app_api.dart';
import 'core/theme/app_theme.dart';
import 'features/portal/client_portal.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  final AppApi? api;
  const MyApp({super.key, this.api});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AppApi api = widget.api ?? AppApi();
  @override
  void dispose() {
    if (widget.api == null) api.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Rinnovare | Minha energia',
    debugShowCheckedModeBanner: false,
    theme: AppTheme.dark,
    // Unknown/deprecated administrative URLs always resolve to the client gate.
    onGenerateInitialRoutes: (_) => [
      MaterialPageRoute(builder: (_) => ClientPortal(api: api)),
    ],
    onGenerateRoute: (_) =>
        MaterialPageRoute(builder: (_) => ClientPortal(api: api)),
  );
}
