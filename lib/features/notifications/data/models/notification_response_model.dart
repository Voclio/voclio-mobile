import 'notification_model.dart';

class NotificationResponseModel {
  final bool success;
  final List<NotificationModel> data;
  final PaginationModel pagination;

  NotificationResponseModel({
    required this.success,
    required this.data,
    required this.pagination,
  });

  factory NotificationResponseModel.fromJson(Map<String, dynamic> json) {
    return NotificationResponseModel(
      success: json['success'] as bool,
      data:
          (json['data'] as List<dynamic>)
              .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
              .toList(),
      pagination: PaginationModel.fromJson(
        json['pagination'] as Map<String, dynamic>,
      ),
    );
  }
}

class PaginationModel {
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  PaginationModel({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory PaginationModel.fromJson(Map<String, dynamic> json) {
    return PaginationModel(
      page: json['page'] as int,
      limit: json['limit'] as int,
      total: json['total'] as int,
      totalPages: json['totalPages'] as int,
    );
  }
}
