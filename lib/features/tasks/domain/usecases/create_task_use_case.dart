import 'package:dartz/dartz.dart';
import 'package:voclio_app/core/errors/failures.dart';
import 'package:voclio_app/features/tasks/domain/entities/task_entity.dart';
import 'package:voclio_app/features/tasks/domain/repositories/task_repository.dart';

class CreateTaskUseCase {
  final TaskRepository taskRepository;

  CreateTaskUseCase(this.taskRepository);

  Future<Either<Failure, TaskEntity>> call(TaskEntity task) async {
    try {
      await taskRepository.createTask(task);
      return Right(task);
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}
