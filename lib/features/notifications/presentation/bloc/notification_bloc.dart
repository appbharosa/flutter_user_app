import 'package:bloc/bloc.dart';
import '../../../../core/errors/failures.dart';
import '../../../../domain/entities/notification_item.dart';
import '../../../../domain/use_cases/get_notifications.dart';
import '../../../../domain/use_cases/mark_notification_read.dart';
import 'notification_event.dart';
import 'notification_state.dart';



class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final GetNotificationsUseCase getNotificationsUseCase;
  final MarkNotificationReadUseCase markNotificationReadUseCase;

// In notification_bloc.dart
  NotificationBloc({
    required this.getNotificationsUseCase,
    required this.markNotificationReadUseCase,
  }) : super(NotificationInitial()) {
    on<LoadNotifications>(_onLoadNotifications);
    on<MarkNotificationAsRead>(_onMarkAsRead); // add this line
  }

  Future<void> _onMarkAsRead(MarkNotificationAsRead event, Emitter<NotificationState> emit) async {
    // Call API
    final result = await markNotificationReadUseCase(event.notificationId, event.language);
    result.fold(
          (failure) => emit(NotificationError(_mapFailureToMessage(failure))),
          (_) {
        // Update local state
        final currentState = state;
        if (currentState is NotificationsLoaded) {
          final updatedNotifications = currentState.notifications.map((item) {
            if (item.id == event.notificationId) {
              // Create a copy with readStatus = 1
              return NotificationItem(
                id: item.id,
                title: item.title,
                message: item.message,
                readStatus: 1,
              );
            }
            return item;
          }).toList();
          final newUnreadCount = updatedNotifications.where((n) => n.readStatus == 0).length;
          emit(NotificationsLoaded(updatedNotifications, newUnreadCount));
        } else {
          // Fallback: reload if state is not ready
          add(LoadNotifications(event.language));
        }
      },
    );
  }

  Future<void> _onLoadNotifications(LoadNotifications event, Emitter<NotificationState> emit) async {
    emit(NotificationLoading());
    final result = await getNotificationsUseCase(event.language);
    result.fold(
          (failure) => emit(NotificationError(_mapFailureToMessage(failure))),
          (notifications) {
        final unreadCount = notifications.where((n) => n.readStatus == 0).length;
        emit(NotificationsLoaded(notifications, unreadCount));
      },
    );
  }


  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) return failure.message;
    if (failure is NetworkFailure) return 'No internet connection';
    return 'Unexpected error';
  }
}