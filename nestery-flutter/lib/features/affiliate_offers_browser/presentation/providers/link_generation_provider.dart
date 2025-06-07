import 'dart:math';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'link_generation_provider.freezed.dart';
part 'link_generation_provider.g.dart';

@freezed
class GeneratedLink with _$GeneratedLink {
  const factory GeneratedLink({
    required String trackableUrl,
    required String qrData,
  }) = _GeneratedLink;
}

@riverpod
class LinkGeneration extends _$LinkGeneration {
  @override
  FutureOr<GeneratedLink?> build() {
    return null; // Initial state is null (no link generated yet)
  }

  Future<void> generateLink(String offerId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await Future.delayed(const Duration(seconds: 1)); // Simulate network call
      final mockCode = (Random().nextInt(900000) + 100000).toString();
      final url = 'https://nestery.com/o/$offerId?ref=$mockCode';
      return GeneratedLink(trackableUrl: url, qrData: url);
    });
  }
}
