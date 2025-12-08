import 'package:dartz/dartz.dart';
import 'package:voclio_app/core/errors/failures.dart';
import '../entities/tag_entity.dart';

abstract class TagRepository {
  Future<Either<Failure, List<TagEntity>>> getTags();
  Future<Either<Failure, TagEntity>> getTag(String id);
  Future<Either<Failure, TagEntity>> createTag(TagEntity tag);
  Future<Either<Failure, TagEntity>> updateTag(TagEntity tag);
  Future<Either<Failure, void>> deleteTag(String id);
}
