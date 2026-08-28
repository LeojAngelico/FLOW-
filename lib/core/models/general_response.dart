class GeneralResponseDto {
  final String message;
  final bool status;
  final String statusCode;

  // Some APIs may return this when the request
  // contains validation errors.
  final bool hasRequirements;

  // Example:
  //
  // {
  //   "firstname": ["Field is required."],
  //   "email": ["Invalid email."]
  // }
  final Map<String, List<String>> errors;

  const GeneralResponseDto({
    required this.message,
    required this.status,
    required this.statusCode,
    this.hasRequirements = false,
    this.errors = const {},
  });

  factory GeneralResponseDto.fromJson(Map<String, dynamic> json) {
    final rawErrors = json['errors'];

    final parsedErrors = <String, List<String>>{};

    // The API may or may not provide "errors".
    if (rawErrors is Map<String, dynamic>) {
      rawErrors.forEach((key, value) {
        if (value is List) {
          parsedErrors[key] = value.map((error) => error.toString()).toList();
        }
      });
    }

    return GeneralResponseDto(
      message: json['msg'] as String? ?? '',
      status: json['status'] as bool? ?? false,
      statusCode: json['status_code'] as String? ?? '',
      hasRequirements: json['has_requirements'] as bool? ?? false,
      errors: parsedErrors,
    );
  }
}
