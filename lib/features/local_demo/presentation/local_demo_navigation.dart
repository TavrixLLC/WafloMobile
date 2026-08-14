import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Null in product roots. The local scenario route is injected only by the
/// development/staging debug composition root.
final localDemoScenarioRouteProvider = Provider<String?>((ref) => null);
