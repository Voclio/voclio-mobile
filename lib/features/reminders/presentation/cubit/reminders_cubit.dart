import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/reminder_entity.dart';
import '../../domain/usecases/get_reminders_usecase.dart';
import '../../domain/usecases/create_reminder_usecase.dart';
import '../../domain/usecases/update_reminder_usecase.dart';
import '../../domain/usecases/delete_reminder_usecase.dart';
import '../../domain/usecases/snooze_reminder_usecase.dart';

part 'reminders_state.dart';

class RemindersCubit extends Cubit<RemindersState> {
  final GetRemindersUseCase getRemindersUseCase;
  final CreateReminderUseCase createReminderUseCase;
  final UpdateReminderUseCase updateReminderUseCase;
  final DeleteReminderUseCase deleteReminderUseCase;
  final SnoozeReminderUseCase snoozeReminderUseCase;

  RemindersCubit({
    required this.getRemindersUseCase,
    required this.createReminderUseCase,
    required this.updateReminderUseCase,
    required this.deleteReminderUseCase,
    required this.snoozeReminderUseCase,
  }) : super(RemindersInitial());

  Future<void> loadReminders() async {
    emit(RemindersLoading());
    final result = await getRemindersUseCase();
    result.fold(
      (failure) => emit(RemindersError(failure.toString())),
      (reminders) => emit(RemindersLoaded(reminders)),
    );
  }

  Future<void> createReminder(ReminderEntity reminder) async {
    final result = await createReminderUseCase(reminder);
    result.fold(
      (failure) => emit(RemindersError(failure.toString())),
      (_) => loadReminders(),
    );
  }

  Future<void> updateReminder(ReminderEntity reminder) async {
    final result = await updateReminderUseCase(reminder);
    result.fold(
      (failure) => emit(RemindersError(failure.toString())),
      (_) => loadReminders(),
    );
  }

  Future<void> deleteReminder(String id) async {
    final result = await deleteReminderUseCase(id);
    result.fold(
      (failure) => emit(RemindersError(failure.toString())),
      (_) => loadReminders(),
    );
  }

  Future<void> snoozeReminder(String id, int minutes) async {
    final result = await snoozeReminderUseCase(id, minutes);
    result.fold(
      (failure) => emit(RemindersError(failure.toString())),
      (_) => loadReminders(),
    );
  }
}
