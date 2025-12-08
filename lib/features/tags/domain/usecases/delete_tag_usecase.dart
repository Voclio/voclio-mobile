import 'package:dartz/dartz.dart';
import 'package:voclio_app/core/errors/failures.dart';
import '../repositories/tag_repository.dart';

class DeleteTagUseCase {
  final TagRepository repository;

  DeleteTagUseCase(this.repository);

  Future<Either<Failure, void>> call(String id) async {
    return await repository.deleteTag(id);
  }
}
