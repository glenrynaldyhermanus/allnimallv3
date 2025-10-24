import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserRegistrationState {
  final bool isLoading;
  final String? error;
  final String? name;
  final String? phone;

  const UserRegistrationState({
    this.isLoading = false,
    this.error,
    this.name,
    this.phone,
  });

  UserRegistrationState copyWith({
    bool? isLoading,
    String? error,
    String? name,
    String? phone,
  }) {
    return UserRegistrationState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      name: name ?? this.name,
      phone: phone ?? this.phone,
    );
  }
}

class UserRegistrationStateNotifier
    extends StateNotifier<UserRegistrationState> {
  UserRegistrationStateNotifier() : super(const UserRegistrationState());

  void setLoading(bool isLoading) {
    state = state.copyWith(isLoading: isLoading);
  }

  void setError(String? error) {
    state = state.copyWith(error: error, isLoading: false);
  }

  void setUserData(String name, String phone) {
    state = state.copyWith(name: name, phone: phone);
  }

  void reset() {
    state = const UserRegistrationState();
  }
}

final userRegistrationStateProvider =
    StateNotifierProvider<UserRegistrationStateNotifier, UserRegistrationState>(
      (ref) {
        return UserRegistrationStateNotifier();
      },
    );
