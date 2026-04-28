import 'package:json_annotation/json_annotation.dart';

part 'api_response.g.dart';

@JsonSerializable(genericArgumentFactories: true)
class ApiResponse<T> {
  final bool success;
  final T? data;
  final ApiError? error;
  final String? message;
  final PaginationInfo? pagination;

  const ApiResponse({
    required this.success,
    this.data,
    this.error,
    this.message,
    this.pagination,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) =>
      _$ApiResponseFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object Function(T value) toJsonT) =>
      _$ApiResponseToJson(this, toJsonT);

  factory ApiResponse.success(T data, {String? message, PaginationInfo? pagination}) {
    return ApiResponse<T>(
      success: true,
      data: data,
      message: message,
      pagination: pagination,
    );
  }

  factory ApiResponse.error(String message, {int? code, List<String>? details}) {
    return ApiResponse<T>(
      success: false,
      error: ApiError(code: code ?? 500, message: message, details: details),
    );
  }
}

@JsonSerializable()
class ApiError {
  final int code;
  final String message;
  final List<String>? details;

  const ApiError({
    required this.code,
    required this.message,
    this.details,
  });

  factory ApiError.fromJson(Map<String, dynamic> json) => _$ApiErrorFromJson(json);
  Map<String, dynamic> toJson() => _$ApiErrorToJson(this);
}

@JsonSerializable()
class PaginationInfo {
  final int page;
  final int limit;
  final int total;
  final int totalPages;
  final bool hasNext;
  final bool hasPrev;

  const PaginationInfo({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrev,
  });

  factory PaginationInfo.fromJson(Map<String, dynamic> json) => _$PaginationInfoFromJson(json);
  Map<String, dynamic> toJson() => _$PaginationInfoToJson(this);
}
