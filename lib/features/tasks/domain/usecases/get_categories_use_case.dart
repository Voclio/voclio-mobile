import 'package:dartz/dartz.dart';
import 'package:voclio_app/core/errors/failures.dart';
import 'package:voclio_app/features/tasks/domain/entities/task_extensions.dart';
import 'package:voclio_app/features/tasks/domain/repositories/task_repository.dart';

class GetCategoriesUseCase {
  final TaskRepository repository;

  GetCategoriesUseCase(this.repository);

  Future<Either<Failure, List<TaskCategoryEntity>>> call() async {
    return await repository.getCategories();
  }
}
