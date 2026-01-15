class ApiResponse<T> {
  final int statusCode;
  final List<String>? message;
  final String? error;
  final T? data;
  final PaginationData? pagination;

  ApiResponse({
    required this.statusCode,
    this.message,
    this.error,
    this.data,
    this.pagination,
  });

  factory ApiResponse.fromJson(
    dynamic json,
    T Function(dynamic) fromJsonT,
  ) {
    final Map<String, dynamic> jsonMap = json as Map<String, dynamic>;
    return ApiResponse<T>(
      statusCode: jsonMap['statusCode'] ?? 200,
      message: jsonMap['message'] != null
          ? List<String>.from(jsonMap['message'])
          : null,
      error: jsonMap['error'],
      data: jsonMap['data'] != null ? fromJsonT(jsonMap['data']) : null,
      pagination: jsonMap['pagination'] != null
          ? PaginationData.fromJson(jsonMap['pagination'] as Map<String, dynamic>)
          : null,
    );
  }

  bool get isSuccess => statusCode >= 200 && statusCode < 300;
}

class PaginationData {
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  PaginationData({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory PaginationData.fromJson(Map<String, dynamic> json) {
    return PaginationData(
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 10,
      total: json['total'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
    );
  }
}

