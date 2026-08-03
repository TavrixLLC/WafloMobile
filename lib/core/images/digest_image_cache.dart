import 'dart:collection';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';

final class ImageIntegrityException implements Exception {
  const ImageIntegrityException(this.code);

  final String code;

  @override
  String toString() => 'ImageIntegrityException($code)';
}

abstract interface class StampImageLoader {
  String cacheKey(String digest);

  Future<Uint8List> load({
    required Uri url,
    required String digest,
    required bool allowInsecure,
  });
}

final class DigestImageCache implements StampImageLoader {
  DigestImageCache(
    this._dio, {
    this.maximumEntries = 24,
    this.maximumTotalBytes = 4 * 1024 * 1024,
    this.maximumAssetBytes = 512 * 1024,
  });

  final Dio _dio;
  final int maximumEntries;
  final int maximumTotalBytes;
  final int maximumAssetBytes;
  final LinkedHashMap<String, Uint8List> _cache = LinkedHashMap();
  final Map<String, Future<Uint8List>> _inFlight = {};
  int _totalBytes = 0;

  @override
  String cacheKey(String digest) {
    final normalized = digest.toLowerCase();
    if (!RegExp(r'^[a-f0-9]{64}$').hasMatch(normalized)) {
      throw const ImageIntegrityException('IMAGE_DIGEST_INVALID');
    }
    return normalized;
  }

  @override
  Future<Uint8List> load({
    required Uri url,
    required String digest,
    required bool allowInsecure,
  }) {
    final key = cacheKey(digest);
    if (!allowInsecure && url.scheme != 'https') {
      throw const ImageIntegrityException('IMAGE_HTTPS_REQUIRED');
    }
    final cached = _cache.remove(key);
    if (cached != null) {
      _cache[key] = cached;
      return Future.value(cached);
    }
    return _inFlight.putIfAbsent(
      key,
      () => _load(url, key).whenComplete(() => _inFlight.remove(key)),
    );
  }

  Future<Uint8List> _load(Uri url, String expectedDigest) async {
    final response = await _dio.get<List<int>>(
      url.toString(),
      options: Options(
        responseType: ResponseType.bytes,
        receiveTimeout: const Duration(seconds: 10),
        headers: const {'accept': 'image/*'},
      ),
    );
    final bytes = response.data;
    if (bytes == null || bytes.isEmpty || bytes.length > maximumAssetBytes) {
      throw const ImageIntegrityException('IMAGE_SIZE_INVALID');
    }
    final contentType = response.headers.value(Headers.contentTypeHeader) ?? '';
    if (!contentType.toLowerCase().startsWith('image/')) {
      throw const ImageIntegrityException('IMAGE_CONTENT_TYPE_INVALID');
    }
    final immutable = Uint8List.fromList(bytes);
    final actual = sha256.convert(immutable).toString();
    if (actual != expectedDigest) {
      _cache.remove(expectedDigest);
      throw const ImageIntegrityException('IMAGE_DIGEST_MISMATCH');
    }
    _cache[expectedDigest] = immutable;
    _totalBytes += immutable.length;
    _evictIfNeeded();
    return immutable;
  }

  void _evictIfNeeded() {
    while (_cache.length > maximumEntries || _totalBytes > maximumTotalBytes) {
      final oldestKey = _cache.keys.first;
      final removed = _cache.remove(oldestKey);
      if (removed != null) {
        _totalBytes -= removed.length;
      }
    }
  }

  void clearCorrupted(String digest) {
    final removed = _cache.remove(cacheKey(digest));
    if (removed != null) {
      _totalBytes -= removed.length;
    }
  }

  void clear() {
    _cache.clear();
    _totalBytes = 0;
  }
}
