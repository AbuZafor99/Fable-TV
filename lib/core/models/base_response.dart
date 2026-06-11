class BaseResponse<T> {
  final bool success;
  final String? message;
  final T? data;

  const BaseResponse({required this.success, this.message, this.data});

  factory BaseResponse.fromJson(
    Map<String, dynamic> json, {
    T Function(dynamic raw)? parser,
  }) {
    return BaseResponse<T>(
      success: json['success'] == true,
      message: json['message'] as String?,
      data: parser == null ? json['data'] as T? : parser(json),
    );
  }
}
