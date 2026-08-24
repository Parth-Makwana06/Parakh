class Violation {
  final String rule;
  final String severity;
  final String description;

  Violation({
    required this.rule,
    required this.severity,
    required this.description,
  });

  factory Violation.fromJson(Map<String, dynamic> json) {
    return Violation(
      rule: json['rule'] ?? 'Unknown Rule',
      severity: json['severity'] ?? 'MEDIUM',
      description: json['description'] ?? '',
    );
  }
}

class ExtractedFields {
  final String? mrp;
  final String? netQty;
  final String? mfgDate;
  final String? consumerPhone;
  final String? consumerEmail;
  final bool mfgDeclaration;

  ExtractedFields({
    this.mrp,
    this.netQty,
    this.mfgDate,
    this.consumerPhone,
    this.consumerEmail,
    this.mfgDeclaration = false,
  });

  factory ExtractedFields.fromJson(Map<String, dynamic> json) {
    return ExtractedFields(
      mrp: json['mrp'],
      netQty: json['net_qty'],
      mfgDate: json['mfg_date'],
      consumerPhone: json['consumer_phone'],
      consumerEmail: json['consumer_email'],
      mfgDeclaration: json['mfg_declaration'] ?? false,
    );
  }
}

class InspectionResult {
  final int? inspectionId;
  final String status;
  final int totalViolations;
  final List<Violation> violations;
  final ExtractedFields extractedFields;

  InspectionResult({
    this.inspectionId,
    required this.status,
    required this.totalViolations,
    required this.violations,
    required this.extractedFields,
  });

  factory InspectionResult.fromJson(Map<String, dynamic> json) {
    final rawList = (json['violations'] as List?) ?? (json['violations_list'] as List?) ?? [];
    final vList = rawList.map((v) => Violation.fromJson(v)).toList();

    return InspectionResult(
      inspectionId: json['inspection_id'] is int ? json['inspection_id'] : int.tryParse(json['inspection_id']?.toString() ?? ''),
      status: json['status'] ?? 'UNKNOWN',
      totalViolations: json['total_violations'] ?? 0,
      violations: vList,
      extractedFields: ExtractedFields.fromJson(json['extracted_fields'] ?? {}),
    );
  }
}
