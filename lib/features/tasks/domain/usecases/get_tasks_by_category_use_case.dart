import 'package:dartz/dartz.dart';
import 'package:voclio_app/core/errors/failures.dart';
import 'package:voclio_app/features/tasks/domain/entities/task_entity.dart';
import 'package:voclio_app/features/tasks/domain/repositories/task_repository.dart';

class GetTasksByCategoryUseCase {
  final TaskRepository repository;

  GetTasksByCategoryUseCase(this.repository);

  Future<Either<Failure, List<TaskEntity>>> call(String categoryId) async {
    return await repository.getTasksByCategory(categoryId);
  }
}
