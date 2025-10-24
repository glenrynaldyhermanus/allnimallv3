import 'package:flutter_riverpod/flutter_riverpod.dart';

class OtpState {
  final bool isLoading;
  final String? error;

  const OtpState({this.isLoading = false, this.error});

  OtpState copyWith({bool? isLoading, String? error}) {
    return OtpState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class OtpStateNotifier extends StateNotifier<OtpState> {
  OtpStateNotifier() : super(const OtpState());

  void setLoading(bool isLoading) {
    state = state.copyWith(isLoading: isLoading);
  }

  void setError(String? error) {
    state = state.copyWith(error: error, isLoading: false);
  }

  void reset() {
    state = const OtpState();
  }
}

final otpStateProvider = StateNotifierProvider<OtpStateNotifier, OtpState>((
  ref,
) {
  return OtpStateNotifier();
});
