import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/tag_entity.dart';
import '../repositories/tag_repository.dart';

class CreateTagUseCase {
  final TagRepository repository;

  CreateTagUseCase(this.repository);

  Future<Either<Failure, TagEntity>> call(String name, String color) async {
    return await repository.createTag(name, color);
  }
}
