import 'package:dartz/dartz.dart';
import 'package:voclio_app/core/errors/failures.dart';
import '../entities/tag_entity.dart';

abstract class TagRepository {
  Future<Either<Failure, List<TagEntity>>> getTags();
  Future<Either<Failure, TagEntity>> createTag(String name, String color);
  Future<Either<Failure, TagEntity>> updateTag(
    String id,
    String name,
    String color,
  );
  Future<Either<Failure, void>> deleteTag(String id);
}
