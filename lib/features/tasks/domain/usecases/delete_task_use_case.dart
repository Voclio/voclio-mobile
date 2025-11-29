import 'package:dartz/dartz.dart';
import 'package:voclio_app/core/errors/failures.dart';
import 'package:voclio_app/features/tasks/domain/repositories/task_repository.dart';

class DeleteTaskUseCase {
  final TaskRepository taskRepository;

  DeleteTaskUseCase(this.taskRepository);

  Future<Either<Failure, void>> call(String taskId) async {
    try {
      await taskRepository.deleteTask(taskId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}
