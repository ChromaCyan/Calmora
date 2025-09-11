import 'package:flutter_bloc/flutter_bloc.dart';

class NotificationState {
  final int unreadCount;
  NotificationState(this.unreadCount);
}

abstract class NotificationEvent {}

class LoadUnreadNotifications extends NotificationEvent {
  final int count;
  LoadUnreadNotifications(this.count);
}

class IncrementUnread extends NotificationEvent {}

class ResetUnread extends NotificationEvent {}

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  NotificationBloc() : super(NotificationState(0)) {
    on<LoadUnreadNotifications>((event, emit) {
      emit(NotificationState(event.count));
    });

    on<IncrementUnread>((event, emit) {
      emit(NotificationState(state.unreadCount + 1));
    });

    on<ResetUnread>((event, emit) {
      emit(NotificationState(0));
    });
  }
}
