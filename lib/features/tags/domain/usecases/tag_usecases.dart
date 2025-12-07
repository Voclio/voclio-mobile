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

class CreateTagUseCase {
  final TagRepository repository;

  CreateTagUseCase(this.repository);

  Future<Either<Failure, TagEntity>> call(String name, String color) async {
    return await repository.createTag(name, color);
  }
}

class UpdateTagUseCase {
  final TagRepository repository;

  UpdateTagUseCase(this.repository);

  Future<Either<Failure, TagEntity>> call(
    String id,
    String name,
    String color,
  ) async {
    return await repository.updateTag(id, name, color);
  }
}

class DeleteTagUseCase {
  final TagRepository repository;

  DeleteTagUseCase(this.repository);

  Future<Either<Failure, void>> call(String id) async {
    return await repository.deleteTag(id);
  }
}
