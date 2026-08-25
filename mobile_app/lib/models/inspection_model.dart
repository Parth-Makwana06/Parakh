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
    // Helper: returns non-null, non-empty, non-'Missing' value from multiple keys
    String? pick(List<String> keys) {
      for (final k in keys) {
        final v = json[k]?.toString();
        if (v != null && v.isNotEmpty && v.toLowerCase() != 'missing') return v;
      }
      return null;
    }

    return ExtractedFields(
      // Gemini returns "MRP"; also handles legacy keys
      mrp: pick(['MRP', 'mrp', 'price']),
      // Gemini returns "Net_Quantity"
      netQty: pick(['Net_Quantity', 'net_qty', 'net_quantity', 'quantity']),
      // Gemini returns "Mfg_Date"
      mfgDate: pick(['Mfg_Date', 'mfg_date', 'mfg', 'date']),
      // Gemini returns "Consumer_Care" as single field (phone + email combined)
      consumerPhone: pick(['Consumer_Care', 'consumer_phone', 'care', 'phone']),
      consumerEmail: pick(['consumer_email', 'email']),
      // Gemini returns "Manufacturer"
      mfgDeclaration: json['mfg_declaration'] == true ||
          (json['Manufacturer'] != null &&
              json['Manufacturer'].toString().isNotEmpty &&
              json['Manufacturer'].toString().toLowerCase() != 'missing') ||
          json['mfg'] != null ||
          json['address'] != null,
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
