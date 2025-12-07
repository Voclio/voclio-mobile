import 'package:dartz/dartz.dart';
import 'package:voclio_app/core/errors/failures.dart';
import 'package:voclio_app/features/tasks/data/datasources/mock-data-tasks.dart';
import 'package:voclio_app/features/tasks/domain/entities/task_entity.dart';
import 'package:voclio_app/features/tasks/domain/repositories/task_repository.dart';

class GetAllTasksUseCase {
  final TaskRepository taskRepository;

  GetAllTasksUseCase(this.taskRepository);

  Future<Either<Failure, List<TaskEntity>>> call() async {
    return await Right(List<TaskEntity>.from(mockTasks));
  }
}
