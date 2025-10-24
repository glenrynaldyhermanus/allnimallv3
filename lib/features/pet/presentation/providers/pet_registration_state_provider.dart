import 'package:flutter_riverpod/flutter_riverpod.dart';

class PetRegistrationState {
  final bool isLoading;
  final String? error;

  const PetRegistrationState({this.isLoading = false, this.error});

  PetRegistrationState copyWith({bool? isLoading, String? error}) {
    return PetRegistrationState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class PetRegistrationStateNotifier extends StateNotifier<PetRegistrationState> {
  PetRegistrationStateNotifier() : super(const PetRegistrationState());

  void setLoading(bool isLoading) {
    state = state.copyWith(isLoading: isLoading);
  }

  void setError(String? error) {
    state = state.copyWith(error: error, isLoading: false);
  }

  void reset() {
    state = const PetRegistrationState();
  }
}

final petRegistrationStateProvider =
    StateNotifierProvider<PetRegistrationStateNotifier, PetRegistrationState>((
      ref,
    ) {
      return PetRegistrationStateNotifier();
    });
