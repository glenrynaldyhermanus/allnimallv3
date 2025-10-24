import 'package:flutter_riverpod/flutter_riverpod.dart';

class PetEditState {
  final bool isLoading;
  final String? error;

  const PetEditState({this.isLoading = false, this.error});

  PetEditState copyWith({bool? isLoading, String? error}) {
    return PetEditState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class PetEditStateNotifier extends StateNotifier<PetEditState> {
  PetEditStateNotifier() : super(const PetEditState());

  void setLoading(bool isLoading) {
    state = state.copyWith(isLoading: isLoading);
  }

  void setError(String? error) {
    state = state.copyWith(error: error, isLoading: false);
  }

  void reset() {
    state = const PetEditState();
  }
}

final petEditStateProvider =
    StateNotifierProvider<PetEditStateNotifier, PetEditState>((ref) {
      return PetEditStateNotifier();
    });
