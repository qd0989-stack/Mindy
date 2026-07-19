import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/consent.dart';
import '../../services/storage_service.dart';

// Events
abstract class AppEvent extends Equatable {
  const AppEvent();

  @override
  List<Object?> get props => [];
}

class AppInitialize extends AppEvent {
  const AppInitialize();
}

class AppUserLoaded extends AppEvent {
  final User user;
  const AppUserLoaded(this.user);

  @override
  List<Object?> get props => [user];
}

class AppConsentUpdated extends AppEvent {
  final ConsentRecord consent;
  const AppConsentUpdated(this.consent);

  @override
  List<Object?> get props => [consent];
}

class AppDisclaimerAcknowledged extends AppEvent {
  const AppDisclaimerAcknowledged();
}

class AppUserUpdated extends AppEvent {
  final User user;
  const AppUserUpdated(this.user);

  @override
  List<Object?> get props => [user];
}

class AppUserLoggedOut extends AppEvent {
  const AppUserLoggedOut();
}

// States
abstract class AppState extends Equatable {
  const AppState();

  @override
  List<Object?> get props => [];
}

class AppInitial extends AppState {
  const AppInitial();
}

class AppLoading extends AppState {
  const AppLoading();
}

class AppReady extends AppState {
  final User? user;
  final ConsentRecord? consent;
  final bool disclaimerAcknowledged;
  final bool onboardingComplete;

  const AppReady({
    this.user,
    this.consent,
    this.disclaimerAcknowledged = false,
    this.onboardingComplete = false,
  });

  bool get hasUser => user != null;
  bool get isOnboarded => hasUser && onboardingComplete;

  @override
  List<Object?> get props => [user, consent, disclaimerAcknowledged, onboardingComplete];

  AppReady copyWith({
    User? user,
    ConsentRecord? consent,
    bool? disclaimerAcknowledged,
    bool? onboardingComplete,
  }) {
    return AppReady(
      user: user ?? this.user,
      consent: consent ?? this.consent,
      disclaimerAcknowledged: disclaimerAcknowledged ?? this.disclaimerAcknowledged,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
    );
  }
}

class AppError extends AppState {
  final String message;
  const AppError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class AppBloc extends Bloc<AppEvent, AppState> {
  final StorageService _storage;

  AppBloc(this._storage) : super(const AppInitial()) {
    on<AppInitialize>(_onInitialize);
    on<AppUserLoaded>(_onUserLoaded);
    on<AppConsentUpdated>(_onConsentUpdated);
    on<AppDisclaimerAcknowledged>(_onDisclaimerAcknowledged);
    on<AppUserUpdated>(_onUserUpdated);
    on<AppUserLoggedOut>(_onUserLoggedOut);
  }

  Future<void> _onInitialize(
    AppInitialize event,
    Emitter<AppState> emit,
  ) async {
    emit(const AppLoading());

    try {
      final user = await _storage.getUserProfile();
      final consent = await _storage.getConsentRecord();
      final disclaimerAcknowledged = await _storage.isDisclaimerAcknowledged();
      final onboardingComplete = await _storage.isOnboardingComplete();

      emit(AppReady(
        user: user,
        consent: consent,
        disclaimerAcknowledged: disclaimerAcknowledged,
        onboardingComplete: onboardingComplete,
      ));
    } catch (e) {
      emit(AppError(e.toString()));
    }
  }

  Future<void> _onUserLoaded(
    AppUserLoaded event,
    Emitter<AppState> emit,
  ) async {
    final currentState = state;
    if (currentState is AppReady) {
      await _storage.saveUserProfile(event.user);
      emit(currentState.copyWith(user: event.user));
    }
  }

  Future<void> _onConsentUpdated(
    AppConsentUpdated event,
    Emitter<AppState> emit,
  ) async {
    final currentState = state;
    if (currentState is AppReady) {
      await _storage.saveConsentRecord(event.consent);
      emit(currentState.copyWith(consent: event.consent));
    }
  }

  Future<void> _onDisclaimerAcknowledged(
    AppDisclaimerAcknowledged event,
    Emitter<AppState> emit,
  ) async {
    final currentState = state;
    if (currentState is AppReady) {
      await _storage.setDisclaimerAcknowledged(true);
      emit(currentState.copyWith(disclaimerAcknowledged: true));
    }
  }

  Future<void> _onUserUpdated(
    AppUserUpdated event,
    Emitter<AppState> emit,
  ) async {
    final currentState = state;
    if (currentState is AppReady) {
      await _storage.saveUserProfile(event.user);
      emit(currentState.copyWith(user: event.user));
    }
  }

  Future<void> _onUserLoggedOut(
    AppUserLoggedOut event,
    Emitter<AppState> emit,
  ) async {
    emit(const AppReady(
      user: null,
      consent: null,
      disclaimerAcknowledged: false,
      onboardingComplete: false,
    ));
  }
}
