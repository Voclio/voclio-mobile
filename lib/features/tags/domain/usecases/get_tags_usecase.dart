import 'package:dartz/dartz.dart';
import 'package:voclio_app/core/errors/failures.dart';
import '../entities/tag_entity.dart';
import '../repositories/tag_repository.dart';

class GetTagsUseCase {
  final TagRepository repository;

  GetTagsUseCase(this.repository);

  Future<Either<Failure, List<TagEntity>>> call() async {
    return await repository.getTags();
  }
}
