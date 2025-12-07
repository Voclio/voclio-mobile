import 'package:equatable/equatable.dart';
import 'package:voclio_app/features/dashboard/domain/entities/dashboard_stats_entity.dart';
import 'package:voclio_app/features/dashboard/domain/entities/quick_stats_entity.dart';

abstract class DashboardState extends Equatable {
  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardStatsLoaded extends DashboardState {
  final DashboardStatsEntity stats;

  DashboardStatsLoaded(this.stats);

  @override
  List<Object?> get props => [stats];
}

class QuickStatsLoaded extends DashboardState {
  final QuickStatsEntity stats;

  QuickStatsLoaded(this.stats);

  @override
  List<Object?> get props => [stats];
}

class DashboardError extends DashboardState {
  final String message;

  DashboardError(this.message);

  @override
  List<Object?> get props => [message];
}
