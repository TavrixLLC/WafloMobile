import 'package:uuid/uuid.dart';

abstract interface class BusinessCommandIdGenerator {
  String next();
}

final class UuidBusinessCommandIdGenerator
    implements BusinessCommandIdGenerator {
  const UuidBusinessCommandIdGenerator({Uuid uuid = const Uuid()})
    : // Public named parameters intentionally initialize private fields.
      // ignore: prefer_initializing_formals
      _uuid = uuid;

  final Uuid _uuid;

  @override
  String next() => _uuid.v4();
}

final class FixedBusinessCommandIdGenerator
    implements BusinessCommandIdGenerator {
  FixedBusinessCommandIdGenerator(Iterable<String> values)
    : _values = values.iterator;

  final Iterator<String> _values;

  @override
  String next() {
    if (!_values.moveNext()) {
      throw StateError('No fixed business command IDs remain.');
    }
    return _values.current;
  }
}

bool isBusinessCommandId(String value) => RegExp(
  r'^[0-9a-f]{8}-[0-9a-f]{4}-[1-8][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
  caseSensitive: false,
).hasMatch(value);
