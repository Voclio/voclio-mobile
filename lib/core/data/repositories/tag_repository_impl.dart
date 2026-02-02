import 'package:dartz/dartz.dart';
import 'package:voclio_app/core/errors/failures.dart';
import 'package:voclio_app/core/domain/entities/tag_entity.dart';
import 'package:voclio_app/core/domain/repositories/tag_repository.dart';
import 'package:voclio_app/core/data/datasources/tag_remote_data_source.dart';

class TagRepositoryImpl implements TagRepository {
  final TagRemoteDataSource remoteDataSource;

  TagRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<TagEntity>>> getTags() async {
    try {
      final tags = await remoteDataSource.getTags();
      return Right(tags.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
