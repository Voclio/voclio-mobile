import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:voclio_app/core/errors/failures.dart';
import 'package:voclio_app/core/api/api_client.dart';
import '../../domain/repositories/voice_repository.dart';
import '../../domain/entities/voice_recording.dart';
import '../../domain/entities/voice_extraction.dart';
import '../datasources/voice_remote_datasource.dart';

class VoiceRepositoryImpl implements VoiceRepository {
  final VoiceRemoteDataSource remoteDataSource;

  VoiceRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<VoiceRecording>>> getVoiceRecordings() async {
    try {
      final result = await remoteDataSource.getVoiceRecordings();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, VoiceRecording>> uploadVoice(File file) async {
    try {
      final result = await remoteDataSource.uploadVoice(file);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteVoice(String id) async {
    try {
      await remoteDataSource.deleteVoice(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> createNoteFromVoice(String id) async {
    try {
      await remoteDataSource.createNoteFromVoice(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> createTasksFromVoice(String id) async {
    try {
      await remoteDataSource.createTasksFromVoice(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> transcribe(String id) async {
    try {
      final result = await remoteDataSource.transcribe(id);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, VoiceExtraction>> previewExtraction(String transcription) async {
    try {
      final result = await remoteDataSource.previewExtraction(transcription);
      
      // Parse tasks
      final tasksData = result['tasks'] as List? ?? [];
      final tasks = tasksData.asMap().entries.map((entry) {
        return ExtractedTask.fromJson(entry.value as Map<String, dynamic>, entry.key);
      }).toList();

      // Parse notes
      final notesData = result['notes'] as List? ?? [];
      final notes = notesData.asMap().entries.map((entry) {
        return ExtractedNote.fromJson(entry.value as Map<String, dynamic>, entry.key);
      }).toList();

      return Right(VoiceExtraction(tasks: tasks, notes: notes));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> createFromPreview({
    required List<ExtractedTask> tasks,
    required List<ExtractedNote> notes,
  }) async {
    try {
      final tasksJson = tasks.where((t) => t.isSelected).map((t) => t.toJson()).toList();
      final notesJson = notes.where((n) => n.isSelected).map((n) => n.toJson()).toList();
      
      await remoteDataSource.createFromPreview(tasksJson, notesJson);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
