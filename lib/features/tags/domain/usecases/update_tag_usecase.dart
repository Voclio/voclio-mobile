import 'package:dartz/dartz.dart';
import 'package:voclio_app/core/errors/failures.dart';
import '../entities/tag_entity.dart';
import '../repositories/tag_repository.dart';

class UpdateTagUseCase {
  final TagRepository repository;

  UpdateTagUseCase(this.repository);

  Future<Either<Failure, TagEntity>> call(TagEntity tag) async {
    return await repository.updateTag(tag);
  }
}
