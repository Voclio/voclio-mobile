import 'package:dartz/dartz.dart';
import 'package:voclio_app/core/errors/failures.dart';
import '../../domain/entities/tag_entity.dart';
import '../../domain/repositories/tag_repository.dart';
import '../datasources/tag_remote_datasource.dart';

class TagRepositoryImpl implements TagRepository {
  final TagRemoteDataSource remoteDataSource;

  TagRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<TagEntity>>> getTags() async {
    try {
      final tags = await remoteDataSource.getTags();
      return Right(tags.map((t) => t.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, TagEntity>> createTag(
    String name,
    String color,
  ) async {
    try {
      final tag = await remoteDataSource.createTag(name, color);
      return Right(tag.toEntity());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, TagEntity>> updateTag(
    String id,
    String name,
    String color,
  ) async {
    try {
      final tag = await remoteDataSource.updateTag(id, name, color);
      return Right(tag.toEntity());
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
