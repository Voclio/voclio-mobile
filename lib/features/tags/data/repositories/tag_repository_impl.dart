import 'package:dartz/dartz.dart';
import 'package:voclio_app/core/errors/failures.dart';
import 'package:voclio_app/features/tags/domain/entities/tag_entity.dart';
import '../../domain/repositories/tag_repository.dart';
import '../datasources/tag_remote_datasource.dart';
import '../models/tag_model.dart';

class TagRepositoryImpl implements TagRepository {
  final TagRemoteDataSource remoteDataSource;

  TagRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<TagEntity>>> getTags() async {
    try {
      final tags = await remoteDataSource.getTags();
      return Right(tags.map((tag) => tag.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, TagEntity>> getTag(String id) async {
    try {
      final tag = await remoteDataSource.getTag(id);
      return Right(tag.toEntity());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, TagEntity>> createTag(TagEntity tag) async {
    try {
      final tagModel = TagModel.fromEntity(tag);
      final createdTag = await remoteDataSource.createTag(tagModel);
      return Right(createdTag.toEntity());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, TagEntity>> updateTag(TagEntity tag) async {
    try {
      final tagModel = TagModel.fromEntity(tag);
      final updatedTag = await remoteDataSource.updateTag(tag.id, tagModel);
      return Right(updatedTag.toEntity());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deleteTag(String id) async {
    try {
      await remoteDataSource.deleteTag(id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}
