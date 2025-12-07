import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/tag_repository.dart';

class UpdateTagUseCase {
  final TagRepository repository;

  UpdateTagUseCase(this.repository);

  Future<Either<Failure, void>> call(
    String id,
    String name,
    String color,
  ) async {
    return await repository.updateTag(id, name, color);
  }
}
