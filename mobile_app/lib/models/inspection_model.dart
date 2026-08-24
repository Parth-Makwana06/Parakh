class Violation {
  final String rule;
  final String severity;
  final String description;

  Violation({
    required this.rule,
    required this.severity,
    required this.description,
  });

  factory Violation.fromJson(dynamic json) {
    if (json is String) {
      return Violation(
        rule: 'LMPC 2011 Rule Violation',
        severity: 'HIGH',
        description: json,
      );
    }
    if (json is Map) {
      return Violation(
        rule: json['rule']?.toString() ?? 'LMPC 2011 Rule',
        severity: json['severity']?.toString() ?? 'HIGH',
        description: json['description']?.toString() ?? json['message']?.toString() ?? json['desc']?.toString() ?? '',
      );
    }
    return Violation(
      rule: 'Rule Offense',
      severity: 'WARNING',
      description: json?.toString() ?? '',
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
      mrp: json['mrp']?.toString() ?? json['MRP']?.toString() ?? json['price']?.toString(),
      netQty: json['net_qty']?.toString() ?? json['Net_Quantity']?.toString() ?? json['net_quantity']?.toString() ?? json['quantity']?.toString(),
      mfgDate: json['mfg_date']?.toString() ?? json['Mfg_Date']?.toString() ?? json['mfg']?.toString() ?? json['date']?.toString(),
      consumerPhone: json['consumer_phone']?.toString() ?? json['Consumer_Care']?.toString() ?? json['care']?.toString() ?? json['phone']?.toString(),
      consumerEmail: json['consumer_email']?.toString() ?? json['email']?.toString(),
      mfgDeclaration: json['mfg_declaration'] == true || json['Manufacturer'] != null || json['mfg'] != null || json['address'] != null,
    );
  }
}

class InspectionResult {
  final dynamic inspectionId;
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
      inspectionId: json['inspection_id'] ?? json['id'] ?? 1,
      status: json['status']?.toString() ?? 'UNKNOWN',
      totalViolations: json['total_violations'] is int ? json['total_violations'] : (vList.length),
      violations: vList,
      extractedFields: ExtractedFields.fromJson(
        json['extracted_fields'] is Map<String, dynamic> ? json['extracted_fields'] : {},
      ),
    );
  }
}
