import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:staff_app/core/utils/app_logger.dart';

/// Central BLoC State Observer (staffRULES.md Rule 3.1).
/// Tracks all event dispatches, state transitions, and unhandled errors across the entire app.
class AppBlocObserver extends BlocObserver {
  const AppBlocObserver();

  @override
  void onEvent(Bloc<dynamic, dynamic> bloc, Object? event) {
    super.onEvent(bloc, event);
    AppLogger.debug('[BLOC EVENT] ${bloc.runtimeType} -> $event');
  }

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    AppLogger.debug(
      '[BLOC CHANGE] ${bloc.runtimeType}: '
      '${change.currentState.runtimeType} -> ${change.nextState.runtimeType}',
    );
  }

  @override
  void onTransition(Bloc<dynamic, dynamic> bloc, Transition<dynamic, dynamic> transition) {
    super.onTransition(bloc, transition);
    AppLogger.debug(
      '[BLOC TRANSITION] ${bloc.runtimeType}: '
      '${transition.currentState.runtimeType} -> ${transition.nextState.runtimeType}',
    );
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    AppLogger.error('[BLOC ERROR] in ${bloc.runtimeType}', error, stackTrace);
    super.onError(bloc, error, stackTrace);
  }
}
