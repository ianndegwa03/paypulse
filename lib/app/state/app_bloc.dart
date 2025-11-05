// lib/app/state/app_bloc.dart
@freezed
class AppEvent with _$AppEvent {
  const factory AppEvent.authStateChanged(AuthState authState) = AuthStateChanged;
  const factory AppEvent.themeChanged(AppTheme theme) = ThemeChanged;
  const factory AppEvent.connectivityChanged(ConnectivityStatus status) = ConnectivityChanged;
  const factory AppEvent.appLifecycleChanged(AppLifecycleState state) = AppLifecycleChanged;
  const factory AppEvent.userPreferencesUpdated(UserPreferences prefs) = UserPreferencesUpdated;
}

@freezed
class AppState with _$AppState {
  const factory AppState({
    required AuthState authState,
    required AppTheme theme,
    required ConnectivityStatus connectivity,
    required AppLifecycleState lifecycle,
    required UserPreferences preferences,
    required Map<String, dynamic> featureFlags,
  }) = _AppState;
}

class AppBloc extends Bloc<AppEvent, AppState> {
  AppBloc() : super(AppState.initial()) {
    on<AuthStateChanged>(_onAuthStateChanged);
    on<ThemeChanged>(_onThemeChanged);
    on<ConnectivityChanged>(_onConnectivityChanged);
    on<AppLifecycleChanged>(_onAppLifecycleChanged);
    on<UserPreferencesUpdated>(_onUserPreferencesUpdated);
  }
}