import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The route is discoverable from Settings only after local Review mode is
/// active. The public pairing surface never links to it.
final localDemoScenarioRouteProvider = Provider<String?>(
  (ref) => '/demo-scenarios',
);
